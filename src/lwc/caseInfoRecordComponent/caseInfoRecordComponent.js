/**
 * Created by sulja on 21.04.2023.
 */

import {LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CaseInfoRecordComponent extends LightningElement {
	_currentRecord;
	@track id;

	@api set currentRecord(record) {
		if (record !== undefined) {
			this.id = record.id
		}
	}
	get currentRecord() {
		return this._currentRecord;
	}

	handleSuccess(event) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: 'Success',
				message: event.detail.apiName + ' created.',
				variant: 'success',
			})
		);

		this.dispatchEvent(
			new CustomEvent(
				'updatedata'
			)
		);
	}
}