/**
 * Created by sulja on 20.04.2023.
 */

public class CasesBulkController {
    @AuraEnabled(Cacheable=true)
    public static List<String> getCaseStatusList() {
        List<String> statusPickListValueList = new List<String>();
        Schema.DescribeFieldResult fieldResult = CaseInfo__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListValue : pickListEntry) {
            statusPickListValueList.add(pickListValue.getLabel());
        }
        return statusPickListValueList;
    }

    @AuraEnabled
    public static List<CaseInfo__c> getCasesInfo(Boolean withCreatedCase, String status) {
        return [
            SELECT
                Id,
                Name,
                Account__r.Id,
                Account__r.Name,
                Contact__r.Id,
                Contact__r.Name,
                Product__r.Id,
                Product__r.Name,
                Type__c,
                CaseReason__c,
                Status__c,
                Priority__c,
                CaseOrigin__c,
                Subject__c,
                IsCaseCreated__c
            FROM CaseInfo__c
            WHERE IsCaseCreated__c = :withCreatedCase AND Status__c = :status
        ];
    }

    @AuraEnabled
    public static String deleteCasesInfo(List<CaseInfo__c> caseInfoList) {
        try {
            delete caseInfoList;
        } catch (Exception e) {
            throwAuraHandledException('Cannot delete records: ' + e.getMessage());
        }
        return 'Success';
    }

    @AuraEnabled
    public static String convertToCase(List<CaseInfo__c> caseInfoList) {
        List<Case> caseToCreateList = new List<Case>();
        try {
            for (CaseInfo__c caseInfo : caseInfoList) {
                Case newCase = new Case(
                    AccountId = caseInfo.Account__c,
                    ContactId = caseInfo.Contact__c,
                    ProductId = caseInfo.Product__c,
                    Type = caseInfo.Type__c,
                    Reason = caseInfo.CaseReason__c,
                    Origin = caseInfo.CaseOrigin__c,
                    Priority = caseInfo.Priority__c,
                    Subject = caseInfo.Subject__c,
                    Status = caseInfo.Status__c
                );
                caseToCreateList.add(newCase);
                caseInfo.IsCaseCreated__c = true;
            }
            insert caseToCreateList;
            update caseInfoList;
        } catch (Exception e) {
            throwAuraHandledException('Cannot create cases: ' + e.getMessage());
        }
        return 'Success';
    }

    @AuraEnabled
    public static CaseInfoTotalWrapper getCaseInfoTotal() {
        Set<Id> caseInfoProductSet = getCaseInfoProducts();
        Map<Id, Decimal> productPriceMap = getCaseInfoProductsPrice(caseInfoProductSet);

        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Status__c, Product__c
            FROM CaseInfo__c
        ];

        return wrapCaseInfoTotal(caseInfoList, productPriceMap);
    }

    @TestVisible
    private static void throwAuraHandledException(String text) {
        AuraHandledException e = new AuraHandledException(text);
        e.setMessage(text);
        throw e;
    }

    @TestVisible
    private static Set<Id> getCaseInfoProducts() {
        Set<Id> productIdSet = new Set<Id>();
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Product__c
            FROM CaseInfo__c
        ];
        for (CaseInfo__c caseInfo : caseInfoList) {
            if (caseInfo.Product__c != null) {
                productIdSet.add(caseInfo.Product__c);
            }
        }

        return productIdSet;
    }

    @TestVisible
    private static Map<Id, Decimal> getCaseInfoProductsPrice(Set<Id> productIdSet) {
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();
        List<PricebookEntry> pricebookEntryList = [
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIdSet AND IsActive = TRUE
        ];
        for (PricebookEntry entry : pricebookEntryList) {
            if (!productPriceMap.containsKey(entry.Product2Id)) {
                productPriceMap.put(entry.Product2Id, entry.UnitPrice);
            }
        }
        return productPriceMap;
    }

    @TestVisible
    private static CaseInfoTotalWrapper wrapCaseInfoTotal(
        List<CaseInfo__c> caseInfoList,
        Map<Id, Decimal> productPriceMap
    ) {
        CaseInfoTotalWrapper caseInfoTotal = new CaseInfoTotalWrapper();
        caseInfoTotal.total = 0;
        caseInfoTotal.statusCaseInfoList = new List<CaseInfoStatusWrapper>();

        Map<String, List<CaseInfo__c>> statusCaseInfoMap = getStatusCaseInfoMap(caseInfoList);
        for (String status : statusCaseInfoMap.keySet()) {
            CaseInfoStatusWrapper caseInfoStatus = wrapStatusCaseInfo(
                status,
                statusCaseInfoMap.get(status),
                productPriceMap
            );
            caseInfoTotal.statusCaseInfoList.add(caseInfoStatus);
            caseInfoTotal.total += caseInfoStatus.summary;
        }

        recalculateCaseInfoTotal(caseInfoTotal);
        return caseInfoTotal;
    }

    @TestVisible
    private static Map<String, List<CaseInfo__c>> getStatusCaseInfoMap(
        List<CaseInfo__c> caseInfoList
    ) {
        List<String> caseStatusList = getCaseStatusList();
        Map<String, List<CaseInfo__c>> statusCaseInfoMap = new Map<String, List<CaseInfo__c>>();
        for (String status : caseStatusList) {
            statusCaseInfoMap.put(status, new List<CaseInfo__c>());
        }
        for (CaseInfo__c caseInfo : caseInfoList) {
            statusCaseInfoMap.get(caseInfo.Status__c).add(caseInfo);
        }
        return statusCaseInfoMap;
    }

    @TestVisible
    private static CaseInfoStatusWrapper wrapStatusCaseInfo(
        String status,
        List<CaseInfo__c> caseInfoList,
        Map<Id, Decimal> productPriceMap

    ) {
        CaseInfoStatusWrapper statusCaseInfo = new CaseInfoStatusWrapper();
        statusCaseInfo.status = status;
        statusCaseInfo.percent = 0;
        statusCaseInfo.summary = 0;

        for (CaseInfo__c caseInfo: caseInfoList) {
            if (caseInfo.Product__c != null) {
                statusCaseInfo.summary += productPriceMap.get(caseInfo.Product__c);
            }
        }

        return statusCaseInfo;
    }

    @TestVisible
    private static void recalculateCaseInfoTotal(CaseInfoTotalWrapper caseInfoTotal) {
        for (CaseInfoStatusWrapper statusCaseInfo : caseInfoTotal.statusCaseInfoList) {
            statusCaseInfo.percent = (statusCaseInfo.summary / caseInfoTotal.total * 100).setScale(2);
        }
    }
}