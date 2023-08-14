function enableEnumTypeChanged(dlgH,obj,isSlimDialog)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    scChannel='/hmi_discrete_knob_controller_/';

    if isSlimDialog
        chkboxTag='UseEnumDataType';
        txtboxTag='EnumDataType';
    else
        chkboxTag='EnableEnumDataType';
        txtboxTag='EnumDataTypeName';
    end

    enableEnumTypeValue=dlgH.getWidgetValue(chkboxTag);
    dlgH.setEnabled(txtboxTag,enableEnumTypeValue);
    viewState=~((Simulink.HMI.isLibrary(model))...
    ||(utils.isLockedLibrary(model))...
    ||enableEnumTypeValue);

    dlgH.setEnabled('sl_hmi_RadioButtonGroupProperties',viewState);

    dlgH.setEnabled('sl_hmi_DiscretKnobProperties',viewState);

    message.publish([scChannel,'toggleEnable'],...
    {~isSlimDialog,obj.widgetId,model,viewState});
end

