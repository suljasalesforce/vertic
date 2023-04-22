/**
 * Created by sulja on 20.04.2023.
 */
@IsTest
private class DataFabric_Test {
    @IsTest
    private static void testCreateAccounts() {
        test.startTest();
        List<Account> createdAccountList = DataFabric.createAccounts(5);
        List<Account> selectedAccountList = [
            SELECT Id
            FROM Account
        ];
        test.stopTest();
        System.assertEquals(5, createdAccountList.size());
        System.assertEquals(createdAccountList.size(), selectedAccountList.size());
    }

    @IsTest
    private static void testCreateContacts() {
        test.startTest();
        List<Contact> createdContactList = DataFabric.createContacts(5);
        List<Contact> selectedContactList = [
            SELECT Id
            FROM Contact
        ];
        test.stopTest();
        System.assertEquals(5, createdContactList.size());
        System.assertEquals(createdContactList.size(), selectedContactList.size());
    }

    @IsTest
    private static void testCreateProducts() {
        test.startTest();
        List<Product2> createdProductList = DataFabric.createProducts(5);
        List<Product2> selectedProductList = [
            SELECT Id, Name
            FROM Product2
        ];
        test.stopTest();
        System.assertEquals(5, createdProductList.size());
        System.assertEquals(createdProductList.size(), selectedProductList.size());
    }

    @IsTest
    private static void testCreatePricebookEntries() {
        test.startTest();
        List<Product2> productList = DataFabric.createProducts(5);
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> createdPricebookEntryList = DataFabric.createPricebookEntries(
            productList,
            pricebookId,
            100
        );
        List<PricebookEntry> selectedPricebookEntryList = [
            SELECT Id
            FROM PricebookEntry
        ];
        test.stopTest();
        System.assertEquals(5, productList.size());
        System.assertEquals(5, createdPricebookEntryList.size());
        System.assertEquals(createdPricebookEntryList.size(), selectedPricebookEntryList.size());
    }

    @IsTest
    private static void testCreateCasesInfoPositive(){
        test.startTest();
        List<Account> createdAccountList = DataFabric.createAccounts(5);
        List<Contact> createdContactList = DataFabric.createContacts(5);
        List<Product2> createdProductList = DataFabric.createProducts(5);
        List<CaseInfo__c> createdCaseInfoList = DataFabric.createCasesInfo(
            createdAccountList,
            createdContactList,
            createdProductList
        );
        List<CaseInfo__c> selectedCaseInfoList = [
            SELECT Id
            FROM CaseInfo__c
        ];
        test.stopTest();
        System.assertEquals(5, createdCaseInfoList.size());
        System.assertEquals(createdCaseInfoList.size(), selectedCaseInfoList.size());
    }

    @IsTest
    private static void testCreateCasesInfoNegative(){
        test.startTest();
        List<Account> createdAccountList = DataFabric.createAccounts(5);
        List<Contact> createdContactList = DataFabric.createContacts(4);
        List<Product2> createdProductList = DataFabric.createProducts(5);
        List<CaseInfo__c> createdCaseInfoList = DataFabric.createCasesInfo(
            createdAccountList,
            createdContactList,
            createdProductList
        );
        List<CaseInfo__c> selectedCaseInfoList = [
            SELECT Id
            FROM CaseInfo__c
        ];
        test.stopTest();
        System.assertEquals(0, createdCaseInfoList.size());
        System.assertEquals(createdCaseInfoList.size(), selectedCaseInfoList.size());
    }
}