/**
 * Created by sulja on 21.04.2023.
 */

import {LightningElement, track} from 'lwc';
import getCaseInfoTotal from '@salesforce/apex/CasesBulkController.getCaseInfoTotal';

export default class CaseInfoTotalComponent extends LightningElement {
	@track totalData;

	connectedCallback() {
		setInterval(
			() => {
				this.retrieveTotalData();
			},
			4 * 1000
		);
	}

	retrieveTotalData() {
		getCaseInfoTotal().then(result => {
			this.totalData = result;
		}).catch(error => {
			console.log('Total error: ' + error.body.message);
		})
	}
}