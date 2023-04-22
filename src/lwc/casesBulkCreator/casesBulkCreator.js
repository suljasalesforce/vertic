/**
 * Created by sulja on 20.04.2023.
 */

import { LightningElement, track, wire } from "lwc";
import getCaseStatusList from '@salesforce/apex/CasesBulkController.getCaseStatusList';
import getCasesInfo from '@salesforce/apex/CasesBulkController.getCasesInfo';
import deleteCasesInfo from '@salesforce/apex/CasesBulkController.deleteCasesInfo';
import convertToCase from '@salesforce/apex/CasesBulkController.convertToCase';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CasesBulkCreator extends NavigationMixin(LightningElement) {
    @track caseInfoList;
    @track withCreatedCase = false;
    @track selectedStatus = '';
    @track statusList = [];
    @track caseInfoList = [];
    @track isRecordModalOpen = false;
    @track currentRecord;

    @wire(getCaseStatusList) wiredStatusList({ error, data }) {
        if (data) {
            let newStatusList = [];
            data.forEach(function (status) {
                newStatusList.push(
                    {
                        label: status,
                        value: status
                    }
                );
            });
            this.statusList = newStatusList;
            this.selectedStatus = newStatusList[0].value;
            this.retrieveCaseInfoData();
        } else if (error) {
            console.log('Get status error: ' + error.body.message);
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.target.value
        this.retrieveCaseInfoData();
    }

    handleSelectCreatedCaseChange(event) {
        this.withCreatedCase = event.target.checked;
        this.retrieveCaseInfoData();
    }

    retrieveCaseInfoData() {
        getCasesInfo({
            withCreatedCase: this.withCreatedCase,
            status: this.selectedStatus
        }).then(result => {
            this.caseInfoList = [];
            result.forEach(caseInfo => {
                this.caseInfoList.push(this.convertToRecord(caseInfo));
            })
        }).catch(error => {
            console.log(error.body.message);
        })
    }

    convertToRecord(object) {
        let record = {};
        record.id = object.Id;
        record.name = object.Name;
        if (object.Account__r !== undefined) {
            record.accountId = object.Account__r.Id;
            record.accountName = object.Account__r.Name;
        } else {
            record.accountId = undefined;
            record.accountName = undefined;
        }
        if (object.Contact__r !== undefined) {
            record.contactId = object.Contact__r.Id;
            record.contactName = object.Contact__r.Name;
        } else {
            record.contactId = undefined;
            record.contactName = undefined;
        }
        if (object.Product__r !== undefined) {
            record.productId = object.Product__r.Id;
            record.productName = object.Product__r.Name;
        } else {
            record.productId = undefined;
            record.productName = undefined;
        }
        record.type = object.Type__c;
        record.caseReason = object.CaseReason__c;
        record.status = object.Status__c;
        record.priority = object.Priority__c;
        record.caseOrigin = object.CaseOrigin__c;
        record.subject = object.Subject__c;
        record.isCaseCreated = object.IsCaseCreated__c;
        record.selected = false
        return record;
    }

    convertToObject(record) {
        let object = {};
        object.Id = record.id;
        object.Name = record.name;
        if (record.accountId !== undefined) {
            object.Account__r = {};
            object.Account__c = record.accountId;
            object.Account__r.Id = record.accountId;
            object.Account__r.Name = record.accountName;
        } else {
            object.Account__c = undefined;
        }
        if (record.contactId !== undefined) {
            object.Contact__r = {};
            object.Contact__c = record.contactId;
            object.Contact__r.Id = record.contactId;
            object.Contact__r.Name = record.contactName;
        } else {
            object.Contact__c = undefined;
        }
        if (record.productId != undefined) {
            object.Product__r = {};
            object.Product__c = record.productId;
            object.Product__r.Id = record.productId;
            object.Product__r.Name = record.productName;
        } else {
            object.Product__c = undefined;
        }
        object.Type__c = record.type;
        object.CaseReason__c = record.caseReason;
        object.Status__c = record.status;
        object.Priority__c = record.priority;
        object.CaseOrigin__c = record.caseOrigin;
        object.Subject__c = record.subject;
        object.IsCaseCreated__c = record.isCaseCreated;
        return object;
    }

    findRecord(id) {
        for (let i = 0; i < this.caseInfoList.length; i++) {
            if (this.caseInfoList[i].id === id) {
                return this.caseInfoList[i];
            }
        }
    }

    handleView(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'CaseInfo__c',
                actionName: 'view'
            }
        });
    }
    handleDelete(event) {
        let record = this.findRecord(event.target.dataset.id);
        let object = this.convertToObject(record);
        let objectToDeleteList = [];
        objectToDeleteList.push(object);

        deleteCasesInfo({
            caseInfoList: objectToDeleteList
        }).then(result => {
            if (result === 'Success') {
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'The record has been delete success.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.retrieveCaseInfoData();
            }
        }).catch(error => {
            console.log(error.body.message);
        })
    }

    handleEdit(event) {
        this.currentRecord = this.findRecord(event.target.dataset.id);
        this.handleRecordModalOpen();
    }

    handleRecordModalOpen() {
        this.isRecordModalOpen = true;
    }

    handleRecordModalClose() {
        this.isRecordModalOpen = false;
    }

    handleCreateCaseInfo() {
        this.currentRecord = undefined;
        this.handleRecordModalOpen();
    }

    handleSingleSelectChange(event) {
        const id = event.target.dataset.id;
        this.caseInfoList = this.caseInfoList.map(caseInfo => {
            if (caseInfo.id === id) {
                caseInfo.selected = event.target.checked;
            }
            return caseInfo;
        });
    }
    handleAllSelectChange(event) {
        this.caseInfoList = this.caseInfoList.map(caseInfo => {
            caseInfo.selected = event.target.checked;
            return caseInfo;
        });
    }

    removeValidClass(event) {
        let classList = event.target.classList;
        if (classList.contains('failed-valid')) {
            classList.remove('failed-valid');
        }
    }

    isValidRecords(recordList) {
        let notValidRecordList = [];
        recordList.forEach(record => {
            if (
                record.subject === undefined ||
                record.status === undefined ||
                record.accountId === undefined ||
                record.contactId === undefined ||
                record.caseOrigin === undefined
            ) {
                notValidRecordList.push(record);
            }
        })

        notValidRecordList.forEach(record => {
           let item = this.template.querySelector('.case-tail[data-id=' + record.id + ']');
            item.classList.add('failed-valid');
        });

        if (notValidRecordList.length > 0) {
            return false
        } else {
            return true
        }
    }

    getSelectedRecords() {
        let selectedRecordList = [];
        this.caseInfoList.forEach(caseInfo => {
            if (caseInfo.selected) {
                selectedRecordList.push(caseInfo);
            }
        });
        return selectedRecordList;
    }

    handleConvertCase() {
        let selectedRecordList = this.getSelectedRecords();
        if (this.isValidRecords(selectedRecordList)) {
            let recordToConvertList = [];
            selectedRecordList.forEach(record => {
                recordToConvertList.push(
                    this.convertToObject(record)
                );
            });

            convertToCase({
                caseInfoList: recordToConvertList
            }).then(result => {
                if (result === 'Success') {
                    const evt = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Case created successful',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.retrieveCaseInfoData();
                }
            }).catch(error => {
                console.log(error.body.message);
            });
        } else {
            const evt = new ShowToastEvent({
                title: 'Failed!',
                message: 'Cannot convert selected records to case. There are invalid records',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }
}
