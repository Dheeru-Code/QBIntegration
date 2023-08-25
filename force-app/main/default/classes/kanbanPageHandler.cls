/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class kanbanPageHandler {
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectApiNames() {
        List<String> objectApiNames = new List<String>();
        for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            objectApiNames.add(objType.getDescribe().getName());
        }
        return objectApiNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<LabelValue> getPicklistFields(String objectApiName) {
        List<LabelValue> picklistFields = new List<LabelValue>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();

        for (String fieldName : fieldsMap.keySet()) {
            String str=String.valueof(fieldsMap.get(fieldName).getDescribe().getType());
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if (str == 'PICKLIST') {
                picklistFields.add(new LabelValue(fieldDescribe.getLabel(), fieldName));
            }
        }
        return picklistFields;
    }

    public class LabelValue {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public LabelValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-11-2023 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        // Get the SObject Describe result for the object
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();

        // Get the field Describe result for the picklist field
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldApiName).getDescribe();

        List<String> pickListValuesList = new List<String>();
        // Check if the field is a picklist

            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistValues) {
                String label = entry.getLabel();
                String value = entry.getValue();
                pickListValuesList.add(label);
                System.debug('Label: ' + label + ', Value: ' + value);
            }
        return pickListValuesList;    
    }
}