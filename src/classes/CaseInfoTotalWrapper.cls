/**
 * Created by sulja on 21.04.2023.
 */

public class CaseInfoTotalWrapper {
    @AuraEnabled
    public Decimal total { get; set; }
    @AuraEnabled
    public List<CaseInfoStatusWrapper> statusCaseInfoList { get; set; }
}