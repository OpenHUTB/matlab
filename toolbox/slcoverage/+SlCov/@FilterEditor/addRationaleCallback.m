function addRationaleCallback(this,dlg,ridx,cidx,value,forCode)




    if nargin<6
        forCode=false;
    end

    c='';
    if forCode
        c='c';
    end

    propName=[c,'tableIdxMap'];

    if this.(propName).isKey(ridx)
        prop=this.(propName)(ridx);
        this.lastFilterElement.rationale={ridx,cidx,prop.Rationale,forCode};
        this.needSave=true;
        if this.isMetricProperty(prop)
            prop.value.rationale=value;
            this.setMetricPropState(prop);
        else
            prop.Rationale=value;
            this.addFilterPropToState(prop);
        end

        if forCode
            this.clastKeyAdded='';
        else
            this.lastKeyAdded='';
        end
    end

    if~isempty(dlg)
        this.hasUnappliedChanges=true;
        dlg.refresh();
        dlg.enableApplyButton(true);
    end

