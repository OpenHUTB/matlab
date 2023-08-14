function changeFilterModeCallback(this,dlg,ridx,mode,forCode)




    if nargin<5
        forCode=false;
    end

    c='';
    if forCode
        c='c';
    end
    propName=[c,'tableIdxMap'];

    if this.(propName).isKey(ridx)
        prop=this.(propName)(ridx);

        if~this.isMetricProperty(prop)&&~this.isCodeMetricProperty(prop)
            if isfield(prop,'mode')
                this.lastFilterElement.mode={ridx,prop.mode,forCode};
                this.needSave=true;
                prop.mode=mode;
            end
            this.addFilterPropToState(prop);
        end
    end

    if~isempty(dlg)
        this.hasUnappliedChanges=true;
        dlg.refresh();
        dlg.enableApplyButton(true);
    end

