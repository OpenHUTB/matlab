function setFilterByProp(this,prop,rationale,ignoreOvereriteRule)




    if nargin<4
        ignoreOvereriteRule=false;
    end
    prop.Rationale=rationale;

    key=this.getPropKey(prop);
    map=this.filterState;
    isIn=map.isKey(key);
    if isIn&&~ignoreOvereriteRule&&~this.overwriteRules
        return;
    end
    if isIn

        this.lastFilterElement.add={prop,map(key)};
    else
        this.lastFilterElement.add=prop;
    end

    this.needSave=true;
    if~isempty(this.m_dlg)
        this.hasUnappliedChanges=true;
        this.m_dlg.refresh();
        this.m_dlg.enableApplyButton(true);
    end

    this.addFilterPropToState(prop);





