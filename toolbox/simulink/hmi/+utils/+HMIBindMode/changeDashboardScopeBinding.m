

function success=changeDashboardScopeBinding(scopeBlockHandle,allBindableTypes,allBindableMetaData,allIsChecked)





    success=false;


    scopeBlockObj=get_param(scopeBlockHandle,'Object');
    if isempty(scopeBlockObj)
        return;
    end



    bIsStateflow=false;
    bindableTypeEnum=BindMode.BindableTypeEnum.getEnumTypeFromChar(allBindableTypes{1});
    bindableMetaData=allBindableMetaData{1};
    if bindableTypeEnum==BindMode.BindableTypeEnum.SLSIGNAL
        srcBlockHandle=get_param(bindableMetaData.blockPathStr,'Handle');
    elseif bindableTypeEnum==BindMode.BindableTypeEnum.SFCHART||...
        bindableTypeEnum==BindMode.BindableTypeEnum.SFSTATE||...
        bindableTypeEnum==BindMode.BindableTypeEnum.SFDATA
        [~,~,srcBlockHandle]=utils.HMIBindMode.getSFInstrumentationMetadata(bindableTypeEnum,bindableMetaData);
        bIsStateflow=true;
    else
        return;
    end
    modelHandle=get_param(bdroot(srcBlockHandle),'Handle');
    modelName=get_param(bdroot(modelHandle),'Name');
    if Simulink.HMI.isLibrary(modelName)
        return;
    end


    bindings=get_param(scopeBlockHandle,'Binding');


    for idx=1:numel(allBindableTypes)

        bindableTypeEnum=BindMode.BindableTypeEnum.getEnumTypeFromChar(allBindableTypes{idx});
        bindableMetaData=allBindableMetaData{idx};
        if bindableTypeEnum==BindMode.BindableTypeEnum.SLSIGNAL
            srcBlockHandle=get_param(bindableMetaData.blockPathStr,'Handle');
            outputPortIndex=bindableMetaData.outputPortNumber;
        elseif bindableTypeEnum==BindMode.BindableTypeEnum.SFCHART||...
            bindableTypeEnum==BindMode.BindableTypeEnum.SFSTATE||...
            bindableTypeEnum==BindMode.BindableTypeEnum.SFDATA
            [sfObj,activity,srcBlockHandle]=utils.HMIBindMode.getSFInstrumentationMetadata(bindableTypeEnum,bindableMetaData);
        else

            continue;
        end
        srcBlockPath=getfullname(srcBlockHandle);
        bIsChecked=allIsChecked(idx);
        if bIsChecked

            if bIsStateflow
                sfprivate('instrument_activity_for_logging',srcBlockHandle,sfObj,activity);
                sigSpec=utils.HMIBindMode.getSFInstrumentedActivity(modelName,sfObj,activity);
            else
                sigSpec=Simulink.HMI.SignalSpecification;
                sigSpec.BlockPath=srcBlockPath;
                sigSpec.OutputPortIndex=outputPortIndex;
            end


            simulationStatus=get_param(modelName,'SimulationStatus');
            bModelSimulating=~strcmpi(simulationStatus,'stopped');
            utils.HMIBindMode.createRuntimeObserver(sigSpec,bModelSimulating);

            bindings{end+1}=sigSpec;%#ok<AGROW>
        else

            for bindingIdx=1:numel(bindings)
                binding=bindings{bindingIdx};
                if bIsStateflow
                    ssid=int2str(sfObj.SSIdNumber);
                    blockPath=binding.BlockPath;
                    localBlockPath=blockPath.getBlock(blockPath.getLength);
                    if strcmp(localBlockPath,srcBlockPath)&&...
                        strcmp(binding.DomainParams_.SSID,ssid)&&...
                        strcmp(binding.DomainParams_.Activity,activity)
                        bindings(bindingIdx)=[];
                        break;
                    end
                else
                    if isequal(binding.BlockPath,srcBlockPath)&&...
                        binding.OutputPortIndex==outputPortIndex
                        bindings(bindingIdx)=[];
                        break;
                    end
                end
            end
        end
    end


    [editor,editorDomain]=utils.HMIBindMode.getEditorWithParamChangeUndoRedo(get(scopeBlockHandle,'Path'));
    if~isempty(editorDomain)
        success=editorDomain.createParamChangesCommand(...
        editor,...
        '',...
        '',...
        @locBindScopeWithUndo,...
        {scopeBlockHandle,bindings,editorDomain},...
        false,...
        true,...
        false,...
        false,...
true...
        );


        set_param(modelName,'Dirty','on');
        return;
    else

        locSetParam(scopeBlockHandle,bindings);
        success=true;
    end
end


function[success,noop]=locBindScopeWithUndo(scopeBlockHandle,bindings,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(scopeBlockHandle);
        locSetParam(scopeBlockHandle,bindings);
    catch
        success=false;
    end
end


function locSetParam(scopeBlockHandle,bindings)
    set_param(scopeBlockHandle,'Binding',bindings);
end
