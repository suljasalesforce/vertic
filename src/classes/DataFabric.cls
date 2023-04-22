/**
 * Created by sulja on 20.04.2023.
 */

public class DataFabric {
    public static List<Account> createAccounts(Integer count) {
        List<Account> accountList = new List<Account>();
        for (Integer i = 1; i <= count; i++) {
            Account newAccount = new Account(
                Name = 'Account' + i
            );
            accountList.add(newAccount);
        }
        insert accountList;
        return accountList;
    }

    public static List<Contact> createContacts(Integer count) {
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 1; i <= count; i++) {
            Contact newContact = new Contact(
                LastName = 'Contact' + i
            );
            contactList.add(newContact);
        }
        insert contactList;
        return contactList;
    }

    public static List<Product2> createProducts(Integer count) {
        List<Product2> productList = new List<Product2>();
        for (Integer i = 1; i <= count; i++) {
            Product2 newProduct = new Product2(
                Name = 'Product' + i
            );
            productList.add(newProduct);
        }
        insert productList;
        return productList;
    }

    public static List<PricebookEntry> createPricebookEntries(List<Product2> productList, Id pricebookId, Decimal price) {
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for (Product2 product : productList) {
            PricebookEntry productPricebookEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = product.Id,
                UnitPrice = price,
                IsActive = true
            );
            pricebookEntryList.add(productPricebookEntry);
        }
        insert pricebookEntryList;
        return pricebookEntryList;
    }

    public static List<CaseInfo__c> createCasesInfo(
        List<Account> accountList,
        List<Contact> contactList,
        List<Product2> productList
    ) {
        List<CaseInfo__c> caseInfoList = new List<CaseInfo__c>();
        if (accountList.size() == contactList.size() && accountList.size() ==productList.size()) {
            for (Integer i = 0; i < accountList.size(); i++) {
                CaseInfo__c newCaseInfo = new CaseInfo__c(
                    Name = 'CaseInfo' + i,
                    Account__c = accountList.get(i).Id,
                    Contact__c = contactList.get(i).Id,
                    Product__c = productList.get(i).Id,
                    Type__c = 'Other',
                    CaseReason__c = 'Other',
                    Status__c = 'New',
                    Priority__c = 'Low',
                    CaseOrigin__c = 'Web',
                    Subject__c = 'Subject' + i,
                    IsCaseCreated__c = false
                );
                caseInfoList.add(newCaseInfo);
            }
            insert caseInfoList;
        }
        return caseInfoList;
    }
}