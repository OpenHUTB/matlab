function key=addFilterPropToState(this,prop)




    key=this.addProp(prop);
    propDesc=this.getPropertyValueDescription(prop);
    if prop.isCode



        this.clastKeyAdded=prop.value;
    else
        this.lastKeyAdded=propDesc;
    end
    this.resetCache;
    if~isempty(this.m_dlg)
        this.hasUnappliedChanges=true;
        this.m_dlg.refresh();
        this.m_dlg.enableApplyButton(true);
    end
