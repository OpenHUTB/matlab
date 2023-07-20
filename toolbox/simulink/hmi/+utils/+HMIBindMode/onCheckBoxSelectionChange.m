

function success=onCheckBoxSelectionChange(HMIBlockHandle,~,bindableType,~,bindableMetaData,isChecked)


    success=false;
    widgetType=utils.getWidgetType(HMIBlockHandle);
    if(strcmp(widgetType,'DashboardScope'))
        success=utils.HMIBindMode.changeDashboardScopeBinding(HMIBlockHandle,{bindableType},{bindableMetaData},isChecked);
    end


    if(success)
        modelName=get_param(bdroot(HMIBlockHandle),'Name');
        set_param(modelName,'Dirty','on');
    end
end