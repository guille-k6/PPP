import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getUnitWrapper from '@salesforce/apex/UnitService.getUnitWrapper';
import saveAnswers from '@salesforce/apex/UnitService.saveAnswers';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UnitView extends LightningElement {
    unitId;
    data;
    error;
    value = '';
    @track selectedOption = {};
    optionResponse;
    
    @wire(CurrentPageReference) 
    currentPageReference;
    
    @api
    get recordId() {
        return this.unitId;
        // returns the trailId
    }
    
    @wire(getUnitWrapper, {unitId: '$unitId'})
    theWrapper({ error, data }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }    
    
    get recordId() {
        return this.currentPageReference && this.currentPageReference.state.recordId;
    }
    
    set recordId(value) {
        //sets boatId attribute
        this.setAttribute('unitId', value);        
        //sets boatId assignment
        this.unitId = value;
    }

    showToastMessage(cond){
        if(cond){
            const toast = new ShowToastEvent({
                title: 'Felicitaciones',
                message: 'Unidad bien respondida!',
                variant: 'success',
            });
            this.dispatchEvent(toast);          
        }else{
            const toast = new ShowToastEvent({
                title: 'Fallaste',
                message: 'Intentá de nuevo.',
                variant: 'error',
            });
            this.dispatchEvent(toast);  
        }
    }
    
    
    handleRadioChange(event) {
        // MAP <QUESTION.ID , OPTION.ID>
        const question = event.target.value;
        const answer = event.target.value2;
        this.selectedOption[question] = answer;
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = Object.keys(this.selectedOption).length
        const amountOfQuestions = this.data.questions.length;
            if(fields === amountOfQuestions){
                saveAnswers( { unitId : this.unitId, jsonAnswers : JSON.stringify(this.selectedOption) } )
                .then(result => {
                    const submitButton = this.template.querySelector('.checkButton');
                    submitButton.disabled = true;
                    setTimeout(() => {
                        if(!this.optionResponse){
                            submitButton.disabled = false;                        
                        }
                    }, 2435);
                    this.optionResponse = result;
                    this.showToastMessage(this.optionResponse);

                })
                .catch(error => {
                    this.error = error;
                    const toast = new ShowToastEvent({
                        title: 'Se rompio todo',
                        message: error,
                        variant: 'error',
                    });
                    this.dispatchEvent(toast);  
                });
            }else{
                const toast = new ShowToastEvent({
                    title: 'Elegí al menos una respuesta para cada unidad',
                    variant: 'warning',
                });
                this.dispatchEvent(toast);
            }
    }       


}