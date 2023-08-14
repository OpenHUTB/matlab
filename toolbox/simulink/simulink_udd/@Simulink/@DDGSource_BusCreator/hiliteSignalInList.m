function hiliteSignalInList(this,dlg)





    block=this.getBlock;
    tag='signalsList';

    if~block.isHierarchyReadonly
        this.unhilite(dlg,false);


        block.UserData.lastListSelectionIdx=dlg.getWidgetValue(tag);
    end

    this.setUpDownRenameWidgetStatus(dlg,tag);

end
