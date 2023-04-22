/**
 * Created by sulja on 22.04.2023.
 */

import {LightningElement, api, track} from 'lwc';

export default class CaseInfoProgressBarComponent extends LightningElement {
	@api percent;
	@api summary;
	@api total;
	@track progress;

	connectedCallback() {
		this.progress = "width: " + this.percent + "%";
	}
}