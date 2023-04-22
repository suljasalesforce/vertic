/**
 * Created by sulja on 20.04.2023.
 */
@IsTest
private class CasesBulkController_Test {
    @TestSetup
    static void setup() {
        List<Account> createdAccountList = DataFabric.createAccounts(5);
        List<Contact> createdContactList = DataFabric.createContacts(5);
        List<Product2> createdProductList = DataFabric.createProducts(5);
        Id pricebookId = Test.getStandardPricebookId();
        DataFabric.createPricebookEntries(createdProductList, pricebookId, 100);
        DataFabric.createCasesInfo(
            createdAccountList,
            createdContactList,
            createdProductList
        );
    }

    @IsTest
    static void testGetCaseStatusList() {
        test.startTest();
        List<String> caseStatusList = CasesBulkController.getCaseStatusList();
        System.assertNotEquals(0, caseStatusList.size());

        Schema.DescribeFieldResult fieldResult = CaseInfo__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        System.assertEquals(pickListEntry.size(), caseStatusList.size());
        test.stopTest();

        for (Integer i = 0; i < pickListEntry.size(); i++) {
            System.assertEquals(pickListEntry.get(i).getLabel(), caseStatusList.get(i));
        }
    }

    @IsTest
    static void testGetCasesInfo() {
        test.startTest();
        List<CaseInfo__c> selectedCaseInfo1List = CasesBulkController.getCasesInfo(false, 'New');
        System.assertEquals(5, selectedCaseInfo1List.size());
        List<CaseInfo__c> selectedCaseInfo3List = CasesBulkController.getCasesInfo(true, 'New');
        System.assertEquals(0, selectedCaseInfo3List.size());
        selectedCaseInfo1List.get(0).IsCaseCreated__c = true;
        selectedCaseInfo1List.get(1).IsCaseCreated__c = true;
        update selectedCaseInfo1List;
        List<CaseInfo__c> selectedCaseInfo4List = CasesBulkController.getCasesInfo(true, 'New');
        System.assertEquals(2, selectedCaseInfo4List.size());
        selectedCaseInfo1List.get(3).Status__c = 'Working';
        selectedCaseInfo1List.get(4).Status__c = 'Working';
        update selectedCaseInfo1List;
        List<CaseInfo__c> selectedCaseInfo5List = CasesBulkController.getCasesInfo(false, 'Working');
        System.assertEquals(2, selectedCaseInfo5List.size());
        selectedCaseInfo1List.get(2).Status__c = 'Working';
        selectedCaseInfo1List.get(2).IsCaseCreated__c = true;
        update selectedCaseInfo1List;
        List<CaseInfo__c> selectedCaseInfo6List = CasesBulkController.getCasesInfo(true, 'Working');
        System.assertEquals(1, selectedCaseInfo6List.size());
        test.stopTest();
    }

    @IsTest
    static void testDeleteRecordsPositive() {
        test.startTest();
        List<CaseInfo__c> caseInfoList = [
            SELECT Id
            FROM CaseInfo__c
            LIMIT 1
        ];
        System.assertEquals(1, caseInfoList.size());
        String status = CasesBulkController.deleteCasesInfo(caseInfoList);
        System.assertEquals('Success', status);
        List<CaseInfo__c> deletedCaseInfoList = [
            SELECT Id
            FROM CaseInfo__c
            WHERE Id = :caseInfoList.get(0).Id
            LIMIT 1
        ];
        System.assertEquals(0, deletedCaseInfoList.size());
        test.stopTest();
    }

    @IsTest
    static void testDeleteRecordsNegative() {
        test.startTest();
        List<CaseInfo__c> caseInfoList = new List<CaseInfo__c>();
        CaseInfo__c caseInfo = new CaseInfo__c(
            Name = 'Name'
        );
        caseInfoList.add(caseInfo);
        try {
            CasesBulkController.deleteCasesInfo(caseInfoList);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Cannot delete records'));
        }
        test.stopTest();
    }

    @IsTest
    static void testConvertToCasePositive() {
        test.startTest();
        List<CaseInfo__c> caseInfoList = [
            SELECT
                Account__c,
                CaseOrigin__c,
                CaseReason__c,
                Contact__c,
                Id,
                IsCaseCreated__c,
                Name,
                Priority__c,
                Product__c,
                Status__c,
                Subject__c,
                Type__c
            FROM CaseInfo__c
        ];
        String status = CasesBulkController.convertToCase(caseInfoList);
        System.assertEquals('Success', status);
        List<Case> createdCaseList = [
            SELECT Id
            FROM Case
        ];
        System.assertEquals(5, caseInfoList.size());
        System.assertEquals(caseInfoList.size(), createdCaseList.size());
        List<CaseInfo__c> caseInfoWithCaseList = [
            SELECT Id, IsCaseCreated__c
            FROM CaseInfo__c
            WHERE IsCaseCreated__c = TRUE
        ];
        System.assertEquals(5, caseInfoWithCaseList.size());
        test.stopTest();
    }

    @IsTest
    static void testConvertToCaseNegative() {
        test.startTest();
        try {
            List<CaseInfo__c> caseInfoList = [
                SELECT Id
                FROM CaseInfo__c
            ];
            String status = CasesBulkController.convertToCase(caseInfoList);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Cannot create cases'));
        }
        test.stopTest();
    }

    @IsTest
    static void testThrowAuraHandledException() {
        try {
            CasesBulkController.throwAuraHandledException('My exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('My exception'));
        }
    }

    @IsTest
    static void testGetCaseInfoProducts() {
        test.startTest();
        Set<Id> caseInfoProductSet = CasesBulkController.getCaseInfoProducts();
        System.assertEquals(5, caseInfoProductSet.size());
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Product__c
            FROM CaseInfo__c
            LIMIT 2
        ];
        caseInfoList.get(0).Product__c = caseInfoList.get(1).Product__c;
        update caseInfoList;
        Set<Id> caseInfoProductNewSet = CasesBulkController.getCaseInfoProducts();
        System.assertEquals(4, caseInfoProductNewSet.size());
        test.stopTest();
    }

    @IsTest
    static void getCaseInfoProductsPrice() {
        test.startTest();
        Set<Id> caseInfoProductSet = CasesBulkController.getCaseInfoProducts();
        Map<Id, Decimal> productPriceMap = CasesBulkController.getCaseInfoProductsPrice(caseInfoProductSet);
        System.assertEquals(5, productPriceMap.size());
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Product__c
            FROM CaseInfo__c
        ];
        for (CaseInfo__c caseInfo : caseInfoList) {
            System.assert(productPriceMap.containsKey(caseInfo.Product__c));
            System.assertEquals(100, productPriceMap.get(caseInfo.Product__c));
        }
        test.stopTest();
    }

    @IsTest
    static void testGetStatusCaseInfoMap() {
        test.startTest();
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Status__c
            FROM CaseInfo__c
        ];
        caseInfoList.get(0).Status__c = 'Working';
        caseInfoList.get(1).Status__c = 'Closed';

        Set<String> statusSet = new Set<String>();
        for (CaseInfo__c caseInfo : caseInfoList) {
            statusSet.add(caseInfo.Status__c);
        }
        System.assertEquals(3, statusSet.size());

        List<String> caseStatusList = CasesBulkController.getCaseStatusList();
        Map<String, List<CaseInfo__c>> statusCaseInfoMap = CasesBulkController.getStatusCaseInfoMap(
            caseInfoList
        );
        System.assertEquals(caseStatusList.size(), statusCaseInfoMap.keySet().size());
        System.assertEquals(1, statusCaseInfoMap.get('Working').size());
        System.assertEquals(1, statusCaseInfoMap.get('Closed').size());
        System.assertEquals(3, statusCaseInfoMap.get('New').size());
        test.stopTest();
    }

    @IsTest
    private static void testWrapStatusCaseInfo() {
        test.startTest();
        Set<Id> caseInfoProductSet = CasesBulkController.getCaseInfoProducts();
        Map<Id, Decimal> productPriceMap = CasesBulkController.getCaseInfoProductsPrice(caseInfoProductSet);
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Status__c, Product__c
            FROM CaseInfo__c
        ];
        Map<String, List<CaseInfo__c>> statusCaseInfoMap = CasesBulkController.getStatusCaseInfoMap(
            caseInfoList
        );
        CaseInfoStatusWrapper statusCaseInfo = CasesBulkController.wrapStatusCaseInfo(
            'New',
            statusCaseInfoMap.get('New'),
            productPriceMap
        );
        System.assertEquals('New', statusCaseInfo.status);
        System.assertEquals(500, statusCaseInfo.summary);
        test.stopTest();
    }

    @IsTest
    private static void testRecalculateCaseInfoTotal() {
        List<CaseInfoStatusWrapper> statusCaseInfoList = new List<CaseInfoStatusWrapper>();
        for (Integer i = 0; i < 4; i++) {
            CaseInfoStatusWrapper statusCaseInfo = new CaseInfoStatusWrapper();
            statusCaseInfo.percent = 0;
            statusCaseInfo.summary = 100;
            statusCaseInfoList.add(statusCaseInfo);
        }
        CaseInfoTotalWrapper totalCaseInfo = new CaseInfoTotalWrapper();
        totalCaseInfo.total = 400;
        totalCaseInfo.statusCaseInfoList = statusCaseInfoList;

        CasesBulkController.recalculateCaseInfoTotal(totalCaseInfo);
        for (CaseInfoStatusWrapper statusCaseInfo : totalCaseInfo.statusCaseInfoList) {
            System.assertEquals(25, statusCaseInfo.percent);
        }
    }

    @IsTest
    private static void testWrapCaseInfoTotal() {
        test.startTest();
        Set<Id> caseInfoProductSet = CasesBulkController.getCaseInfoProducts();
        Map<Id, Decimal> productPriceMap = CasesBulkController.getCaseInfoProductsPrice(caseInfoProductSet);
        List<CaseInfo__c> caseInfoList = [
            SELECT Id, Status__c, Product__c
            FROM CaseInfo__c
        ];
        caseInfoList.get(2).Status__c = 'Working';
        caseInfoList.get(3).Status__c = 'Working';
        caseInfoList.get(4).Product__c = null;
        CaseInfoTotalWrapper totalCaseInfo = CasesBulkController.wrapCaseInfoTotal(
            caseInfoList,
            productPriceMap
        );
        System.assertEquals(400, totalCaseInfo.total);
        for (CaseInfoStatusWrapper statusCaseInfo : totalCaseInfo.statusCaseInfoList) {
            if (statusCaseInfo.status == 'New' || statusCaseInfo.status == 'Working') {
                System.assertEquals(200, statusCaseInfo.summary);
                System.assertEquals(50, statusCaseInfo.percent);
            }
        }
        test.stopTest();
    }

    @IsTest
    private static void getCaseInfoTotal() {
        test.startTest();
        CaseInfoTotalWrapper totalCaseInfo = CasesBulkController.getCaseInfoTotal();
        System.assertEquals(500, totalCaseInfo.total);
        test.stopTest();
    }
}