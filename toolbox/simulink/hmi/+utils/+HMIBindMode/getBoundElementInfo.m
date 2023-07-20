

function boundElemData=getBoundElementInfo(HMIBlockHandle,modelName)


    if(Simulink.HMI.isLibrary(modelName))
        boundElemData={};
        return;
    end


    isCoreBlock=false;
    if strcmp(get_param(HMIBlockHandle,'isCoreWebBlock'),'on')
        isCoreBlock=true;
    end

    widgetID=utils.getInstanceId(get_param(HMIBlockHandle,'Object'));
    isLibWidget=utils.getIsLibWidget(get_param(HMIBlockHandle,'Object'));

    if(isCoreBlock)
        binding=get_param(HMIBlockHandle,'Binding');
        if(~isempty(binding))
            boundElem=binding;
        else
            boundElem={};
        end
    else
        boundElem=utils.getBoundElement(modelName,widgetID,isLibWidget);
    end

    widgetType=utils.getWidgetType(HMIBlockHandle);
    widgetBindingType=utils.getWidgetBindingType(HMIBlockHandle);


    if(strcmp(widgetBindingType,'ParameterOrVariable'))
        boundElemData=utils.getParameterRows(modelName,widgetID,[],boundElem,widgetType);
    elseif(strcmp(widgetType,'sdiscope'))

        boundElemData={};
    elseif(strcmp(widgetBindingType,'SingleSignal'))
        boundElemData=utils.getSignalRows(modelName,widgetID,[],[],boundElem,widgetType);
    else
        boundElemData={};
    end
end