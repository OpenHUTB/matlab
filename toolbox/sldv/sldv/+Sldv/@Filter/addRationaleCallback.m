function addRationaleCallback(this,dlg,ridx,cidx,rationale,forCode)




    if nargin<6
        forCode=false;
    end

    c='';
    if forCode
        c='c';
    end

    propName=[c,'tableIdxMap'];

    if~this.(propName).isKey(ridx)
        return;
    end

    prop=this.(propName)(ridx);

    this.needSave=true;

    if this.isMetricProperty(prop)||this.isRteProperty(prop)
        this.lastFilterElement.rationale={ridx,cidx,prop.value.rationale,forCode};
        prop.value.rationale=rationale;
        this.setMetricPropState(prop);
    else
        this.lastFilterElement.rationale={ridx,cidx,prop.Rationale,forCode};
        prop.Rationale=rationale;
        this.addFilterPropToState(prop);
    end

    if forCode
        this.clastKeyAdded='';
    else
        this.lastKeyAdded='';
    end

    if~isempty(dlg)
        this.hasUnappliedChanges=true;
        dlg.refresh;
        dlg.enableApplyButton(true);
    end
end
