function schema=showModelDataEditor(cbinfo,~)


    schema=sl_toggle_schema;
    schema.label=DAStudio.message('Simulink:studio:DataViewMenu');
    schema.tag='Simulink:DataViewMenu';
    schema.accelerator='Ctrl+Shift+E';
    schema.callback=@coder.internal.toolstrip.callback.logicalViewComponentCB;
    schema.autoDisableWhen='Never';

    if cbinfo.studio.App.hasSpotlightView()
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    ss=cbinfo.studio.getComponent('GLUE2:SpreadSheet','ModelData');
    if~isempty(ss)&&cbinfo.studio.getComponent('GLUE2:SpreadSheet','ModelData').isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end
