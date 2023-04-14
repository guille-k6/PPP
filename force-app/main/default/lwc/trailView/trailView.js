import { LightningElement, wire, api, track } from 'lwc';
import getTrailWrapper from '@salesforce/apex/UnitService.getTrailWrapper';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRAIL_ID_FIELD from '@salesforce/schema/Trail__c.Id';
import TRAIL_NAME_FIELD from '@salesforce/schema/Trail__c.Name';
import TRAIL_DESCRIPTION_FIELD from '@salesforce/schema/Trail__c.Description__c';
import TRAIL_POINTS_FIELD from '@salesforce/schema/Trail__c.Points__c';
import TRAIL_ESTIMATED_TIME_FIELD from '@salesforce/schema/Trail__c.Estimated_Time__c';
import { CurrentPageReference } from 'lightning/navigation';



const TRAIL_FIELDS = [TRAIL_ID_FIELD, TRAIL_NAME_FIELD, TRAIL_DESCRIPTION_FIELD, TRAIL_POINTS_FIELD, TRAIL_ESTIMATED_TIME_FIELD]

export default class TrailView extends NavigationMixin(LightningElement) {

    
    trailId;
    content;
    data;
    error;
    @track trailProgress;

    @wire(getTrailWrapper, {trailId: '$trailId'})
    theWrapper({ error, data }) {
        if (data) {
          this.data = data;
          this.error = undefined;
        
        } else if (error) {
          this.error = error;
        }
    }
    
    
    @wire(CurrentPageReference) currentPageReference;

    
    @api
    get recordId() {
        return this.TrailId;
        // returns the trailId
    }

    get trailName() {
        return getFieldValue(this.wiredRecord.data, TRAIL_NAME_FIELD);
    }
    
    get recordId() {
        return this.currentPageReference && this.currentPageReference.state.recordId;
    }
    
    set recordId(value) {
        //sets boatId attribute
        this.setAttribute('trailId', value);        
        //sets boatId assignment
        this.trailId = value;
    }
    
    @wire(getRecord, { recordId: '$trailId', fields: TRAIL_FIELDS })
    wiredRecord;

    calcularTrailProgress(){
        if(this.data.modules.length === 0){
            this.trailProgress = 0;
        }else{
            this.trailProgress = (this.data.passedModuleIds.length / this.data.modules.length)*100;
        }
    }

    showUnitChecks(){
        for (let i = 0; i < this.data.modules.length; i++) {
            for (let j = 0; j < this.data.modules[i].Units__r.length; j++) {
                if(this.data.passedUnitIds.includes(this.data.modules[i].Units__r[j].Id)){
                    let unitId = this.data.modules[i].Units__r[j].Id;
                    this.template.querySelector(`div[data-unitid=${unitId}]`).removeAttribute("hidden");
                }         
            }
        }
    }

    renderedCallback() {
        if (this.data) {
            this.showUnitChecks();
            this.showModuleChecks();
            this.calcularTrailProgress();
        } else{
            // do sth
        }
    }

    showModuleChecks(){
        for(let i = 0; i< this.data.modules.length; i++){
            if(this.data.passedModuleIds.includes(this.data.modules[i].Id)){
                let moduleId = this.data.modules[i].Id;
                this.template.querySelector(`div[data-moduleid=${moduleId}]`).removeAttribute("hidden");                
            }
        }
    }

    activeSections = ['A', 'C'];
    activeSectionsMessage = '';

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    handleClick(e){
        const unitId = e.currentTarget.dataset.unitId; // Obtén el ID de la unidad desde el evento
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: unitId,
                objectApiName: 'Unit__c',
                actionName: 'view'
            }
        });
    }
}