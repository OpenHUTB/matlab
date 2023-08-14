

function success=onRadioSelectionChange(HMIBlockHandle,~,bindableType,~,bindableMetaData,isChecked)


    success=false;
    if(isChecked==1)
        bindableTypeEnum=BindMode.BindableTypeEnum.getEnumTypeFromChar(bindableType);
        if(bindableTypeEnum==BindMode.BindableTypeEnum.SLSIGNAL||...
            bindableTypeEnum==BindMode.BindableTypeEnum.SLPARAMETER||...
            bindableTypeEnum==BindMode.BindableTypeEnum.VARIABLE)
            slBlockHandle=get_param(bindableMetaData.blockPathStr,'Handle');
            modelName=get_param(bdroot(slBlockHandle),'Name');
            if(Simulink.HMI.isLibrary(modelName))
                return;
            end
            if(bindableTypeEnum==BindMode.BindableTypeEnum.SLSIGNAL)
                slPortNumber=bindableMetaData.outputPortNumber;
                success=utils.HMIBindMode.bindSignal(HMIBlockHandle,slBlockHandle,slPortNumber);
            elseif(bindableTypeEnum==BindMode.BindableTypeEnum.SLPARAMETER||...
                bindableTypeEnum==BindMode.BindableTypeEnum.VARIABLE)
                paramOrVarName=bindableMetaData.name;
                varWorkspaceType='';
                if(bindableTypeEnum==BindMode.BindableTypeEnum.VARIABLE)
                    varWorkspaceType=bindableMetaData.workspaceType.sourceName;
                end
                element=bindableMetaData.inputValue;
                try
                    success=utils.HMIBindMode.bindParameter(HMIBlockHandle,slBlockHandle,paramOrVarName,varWorkspaceType,element);
                catch e



                    BindMode.BindMode.setInputFieldValid(false,e.message);
                end
            end
        elseif(bindableTypeEnum==BindMode.BindableTypeEnum.SFCHART||...
            bindableTypeEnum==BindMode.BindableTypeEnum.SFSTATE||...
            bindableTypeEnum==BindMode.BindableTypeEnum.SFDATA)
            [obj,activity,chartHandle]=utils.HMIBindMode.getSFInstrumentationMetadata(bindableTypeEnum,bindableMetaData);
            modelName=get_param(bdroot(chartHandle),'Name');
            if(Simulink.HMI.isLibrary(modelName))
                return;
            end
            success=utils.HMIBindMode.bindSFState(HMIBlockHandle,obj,chartHandle,activity);
        end

        if(success)
            set_param(modelName,'Dirty','on');
        end
    end
end