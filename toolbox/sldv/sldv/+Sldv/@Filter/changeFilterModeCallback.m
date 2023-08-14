function changeFilterModeCallback(this,dlg,ridx,mode,forCode)




    if nargin<5
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
    if~isfield(prop,'mode')
        return;
    end





    if(mode<0)||(mode==0)&&this.isCodeMetricProperty(prop)
        return
    end

    if this.isMetricProperty(prop)||this.isRteProperty(prop)
        if mode==0
            return;
        end

        this.lastFilterElement.mode={ridx,prop.value.mode,forCode};
        prop.value.mode=1;
        this.setMetricPropState(prop);
    else
        this.lastFilterElement.mode={ridx,prop.mode,forCode};
        prop.mode=mode;
        this.addFilterPropToState(prop);
    end

    this.needSave=true;

    if~isempty(dlg)
        this.hasUnappliedChanges=true;
        dlg.refresh;
        dlg.enableApplyButton(true);
    end
end
