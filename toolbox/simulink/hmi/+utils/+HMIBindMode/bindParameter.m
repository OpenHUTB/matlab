

function success=bindParameter(HMIBlockHandle,slBlockHandle,paramOrVarName,varWorkspaceType,element)






    success=false;
    modelName=get_param(bdroot(slBlockHandle),'Name');
    if(Simulink.HMI.isLibrary(modelName))
        return;
    end

    HMIBlockObj=get_param(HMIBlockHandle,'Object');
    slBlockObj=get_param(slBlockHandle,'Object');

    if(isempty(slBlockObj)||isempty(HMIBlockObj))
        return;
    end

    paramSource=Simulink.HMI.ParamSourceInfo;
    block=get(slBlockObj,'Name');
    block=regexprep(block,'/','//');
    bpath=get(slBlockObj,'Parent');
    paramSource.BlockPath=Simulink.BlockPath([bpath,'/',block]);

    if(isempty(varWorkspaceType))
        paramSource.ParamName=paramOrVarName;
    else
        paramSource.WksType=varWorkspaceType;
        paramSource.VarName=paramOrVarName;
    end



    elementNum=str2double(element);
    if~isnan(elementNum)&&elementNum>0&&floor(elementNum)==elementNum
        element=['(',element,')'];
    end
    paramSource.Element=element;




    valueToTune=paramSource.getValue;
    if~isscalar(valueToTune)||isstruct(valueToTune)

        error(message('SimulinkHMI:errors:InvalidNonScalarTuningElement'));
    end

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
            @bindParameterWithUndo,...
            {modelName,HMIBlockHandle,paramSource,editorDomain},...
            false,...
            true,...
            false,...
            false,...
true...
            );


            set_param(modelName,'Dirty','on');
            return;
        else

            locSetParam(modelName,HMIBlockHandle,paramSource);
            success=true;
        end
    else
        widget=utils.getWidget(modelName,widgetId,isLibWidget);

        if(~isempty(widget))
            widget.bind(paramSource,isLibWidget);
            success=true;
        end
    end


    if(success)
        set_param(modelName,'Dirty','on');
    end
end

function[success,noop]=bindParameterWithUndo(modelName,HMIBlockHandle,paramSource,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(HMIBlockHandle);
        locSetParam(modelName,HMIBlockHandle,paramSource);
    catch
        success=false;
    end
end

function locSetParam(modelName,HMIBlockHandle,paramSource)
    cachedModelName=get_param(HMIBlockHandle,'ModelName');
    if(~isequal(cachedModelName,modelName))
        set_param(HMIBlockHandle,'ModelName',modelName);
    end
    set_param(HMIBlockHandle,'Binding',paramSource);
end

