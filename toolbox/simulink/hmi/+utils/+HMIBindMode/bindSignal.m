

function success=bindSignal(HMIBlockHandle,srcPortBlockHandle,outputPortIndex)




    success=false;
    modelName=get_param(bdroot(srcPortBlockHandle),'Name');
    if(Simulink.HMI.isLibrary(modelName))
        return;
    end

    HMIBlockObj=get_param(HMIBlockHandle,'Object');
    slBlockObj=get_param(srcPortBlockHandle,'Object');

    if(isempty(slBlockObj)||isempty(HMIBlockObj))
        return;
    end

    signalSource=Simulink.HMI.SignalSpecification;
    block=get(slBlockObj,'Name');
    block=regexprep(block,'/','//');
    bpath=get(slBlockObj,'Parent');
    signalSource.BlockPath=Simulink.BlockPath([bpath,'/',block]);
    signalSource.OutputPortIndex=outputPortIndex;
    signalSource.CachedBlockHandle_=slBlockObj.Handle;

    isCoreWebBlock=get_param(HMIBlockHandle,'isCoreWebBlock');
    widgetId=utils.getInstanceId(HMIBlockObj);
    isLibWidget=utils.getIsLibWidget(HMIBlockObj);


    if(strcmp(isCoreWebBlock,'on'))
        [editor,editorDomain]=utils.HMIBindMode.getEditorWithParamChangeUndoRedo(get(HMIBlockHandle,'Path'));
        if(~isempty(editorDomain))
            success=editorDomain.createParamChangesCommand(...
            editor,...
            '',...
            '',...
            @bindSignalWithUndo,...
            {modelName,HMIBlockHandle,signalSource,editorDomain},...
            false,...
            true,...
            false,...
            false,...
true...
            );


            set_param(modelName,'Dirty','on');
            return;
        else

            locSetParam(modelName,HMIBlockHandle,signalSource);
            success=true;
        end
    else
        widget=utils.getWidget(modelName,widgetId,isLibWidget);
        if(~isempty(widget))
            modelHandle=get_param(modelName,'Handle');
            if(Simulink.HMI.WebHMI.isBound(modelHandle,widgetId,isLibWidget))
                widget.unbind(isLibWidget);
            end
            widget.bind(signalSource,isLibWidget);
            success=true;
        end
    end


    if(success)
        set_param(modelName,'Dirty','on');
    end
end

function[success,noop]=bindSignalWithUndo(modelName,HMIBlockHandle,signalSource,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(HMIBlockHandle);
        locSetParam(modelName,HMIBlockHandle,signalSource);
    catch
        success=false;
    end
end

function locSetParam(modelName,HMIBlockHandle,signalSource)
    cachedModelName=get_param(HMIBlockHandle,'ModelName');
    if(~isequal(cachedModelName,modelName))
        set_param(HMIBlockHandle,'ModelName',modelName);
    end
    set_param(HMIBlockHandle,'Binding',signalSource);
end