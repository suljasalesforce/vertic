/**
 * Created by sulja on 21.04.2023.
 */

public class CaseInfoStatusWrapper {
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public Decimal summary { get; set; }
    @AuraEnabled
    public Decimal percent { get; set; }
}