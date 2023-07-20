function info=getDesignMappingWidgets(hObj)




    groupLabel='DesignMapping';
    info.ParameterGroups={groupLabel};
    info.Parameters={};

    label=DAStudio.message('codertarget:ui:PeripheralMappingBtnLabel');
    toolTip=DAStudio.message('codertarget:ui:PeripheralMappingBtnToolTip');
    pBtn=codertarget.parameter.ParameterInfo.getDefaultParameter();
    pBtn.Name=label;
    pBtn.ToolTip=toolTip;
    pBtn.Tag='SOCB_Design_Mapping_Peripheral_Map_Btn';
    pBtn.Type='pushbutton';
    pBtn.Callback='codertarget.peripherals.utils.peripheralMapButtonCallback';
    pBtn.Visible=true;
    pBtn.Enabled=true;
    pBtn.RowSpan=[1,1];
    pBtn.ColSpan=[1,2];
    pBtn.DialogRefresh=false;
    pBtn.DoNotStore=true;
    info.Parameters{1}{1}=pBtn;
end


function ret=locIsMdlConfiguredForProcessorUnit(hObj)
    ret=false;
    if codertarget.targethardware.isProcessingUnitSelectionAvailable(hObj)
        progUnit=codertarget.data.getParameterValue(hObj,'ESB.ProcessingUnit');
        if~isequal(progUnit,'None')
            ret=true;
        end
    end
end


