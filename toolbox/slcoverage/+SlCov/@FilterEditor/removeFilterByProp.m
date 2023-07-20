function removeFilterByProp(this,prop)



    key=this.getPropKey(prop);
    map=this.filterState;
    if map.isKey(key)
        this.lastFilterElement.remove=map(key);
        this.needSave=true;
    end
    this.removePropFromMap(map,prop);


    if~isempty(this.m_dlg)
        this.m_dlg.refresh();
        this.hasUnappliedChanges=true;
        this.m_dlg.enableApplyButton(true);
    end
