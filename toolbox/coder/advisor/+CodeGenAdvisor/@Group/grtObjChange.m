function grtObjChange(this,dlg)



    widgetval=dlg.getWidgetValue('tag_grtObjCombo');
    if widgetval==0
        this.Objectives={};
    elseif widgetval==1
        this.Objectives={'Debugging'};
    else
        this.Objectives={'Execution efficiency'};
    end

    this.refreshCheckList;
