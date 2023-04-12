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
    isPassed;
    
    
    @wire(getTrailWrapper, {trailId: '$trailId'})
    theWrapper({ error, data }) {
      if (data) {
          this.data = data;
          this.error = undefined;
        
        } else if (error) {
          this.error = error;
        }
    }
        artu(){
        myObject = this.template.querySelector(".checkIcon");
        console.log('entre a la funcion');
        console.log(myObject);
        for (let i = 0; i < data.modules.length; i++) {
            for (let j = 0; j < data.modules[i].Units__r.length; j++) {
                console.log('PEPITO');
                console.log(data.passedUnitIds);
                console.log(data.modules[i].Units__r[j].Id);
                if(data.passedUnitIds.includes(data.modules[i].Units__r[j].Id)){
                    //this.data.modules[i].Units__r[j]['isPassed'] = true;
                    console.log(data.modules[i].Units__r[j]);
                    this.myObject.style.display = 'inline';
                  //  this.myObject.classList.add("show");
                }else{
                    this.myObject.style.display = 'none';
                }
                  
            }
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


    connectedCallback(){
        //console.log('este es el TrailId:');
        //console.log(this.trailId);
        //console.log('este es el trail wrapper');
        //console.log(this.data.modules);
    }

    // JS DEL ACCORDION
    verTrail(){
        //console.log(this.data.modules);
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
    init(){
        this.artu();
    }
}