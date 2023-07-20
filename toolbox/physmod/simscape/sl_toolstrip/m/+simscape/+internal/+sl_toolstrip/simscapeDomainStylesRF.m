function schema=simscapeDomainStylesRF(cbInfo,action)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimscapeStylingEnableDisable';
    modelName=getfullname(cbInfo.editorModel.handle);
    schema.autoDisableWhen='Never';
    try
        if(simscape.internal.styleModel(modelName))
            schema.checked='Checked';
            action.selected=true;
        else
            schema.checked='Unchecked';
            action.selected=false;
        end
    catch
    end
end

