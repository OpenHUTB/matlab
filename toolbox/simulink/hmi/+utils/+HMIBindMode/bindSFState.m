

function success=bindSFState(HMIBlockHandle,state,chartBlockHandle,mode)





    success=false;

    HMIBlockObj=get_param(HMIBlockHandle,'Object');
    if isempty(HMIBlockObj)
        return;
    end

    modelName=get_param(bdroot(chartBlockHandle),'Name');
    if Simulink.HMI.isLibrary(modelName)
        return;
    end


    sfprivate('instrument_activity_for_logging',chartBlockHandle,state,mode);


    signalSpecification=utils.HMIBindMode.getSFInstrumentedActivity(modelName,state,mode);
    if isempty(signalSpecification)


        return;
    end


    [editor,editorDomain]=utils.HMIBindMode.getEditorWithParamChangeUndoRedo(get(HMIBlockHandle,'Path'));
    if~isempty(editorDomain)
        success=editorDomain.createParamChangesCommand(...
        editor,...
        '',...
        '',...
        @bindSignalWithUndo,...
        {modelName,HMIBlockHandle,signalSpecification,editorDomain},...
        false,...
        true,...
        false,...
        false,...
true...
        );


        set_param(modelName,'Dirty','on');
    else

        locSetParam(modelName,HMIBlockHandle,signalSpecification);
        success=true;
    end
end

function[success,noop]=bindSignalWithUndo(modelName,HMIBlockHandle,signalSpecification,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(HMIBlockHandle);
        locSetParam(modelName,HMIBlockHandle,signalSpecification);
    catch
        success=false;
    end
end

function locSetParam(modelName,HMIBlockHandle,signalSpecification)
    cachedModelName=get_param(HMIBlockHandle,'ModelName');
    if~isequal(cachedModelName,modelName)
        set_param(HMIBlockHandle,'ModelName',modelName);
    end
    set_param(HMIBlockHandle,'Binding',signalSpecification);
end