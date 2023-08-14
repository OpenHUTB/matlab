function schema=selectAll(cbinfo)



    schema=sl_action_schema;
    schema.tag='slmle:SelectAll';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='selectAll';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SelectAll');
    end
    schema.accelerator='Ctrl+A';

    ed=getMLFBEditor(cbinfo);


    if ed.ed.isLocked
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    schema.callback=@SelectAllCB;

    schema.autoDisableWhen='Never';

end

function SelectAllCB(cbinfo)
    ed=getMLFBEditor(cbinfo);
    ed.publish('select_all',[]);
end


function ed=getMLFBEditor(cbinfo)
    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=m.getMLFBEditorByStudioAdapter(saEd);
end


