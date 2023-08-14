function DngProjectCombo_callback(this,dlg)



    selected=dlg.getWidgetValue('DngProjectCombo');
    if selected>0
        this.projName=this.allProjNames{selected};
    else
        this.projName='';
    end

    dlg.refresh();

end
