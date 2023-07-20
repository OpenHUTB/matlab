

function bindParameter(obj)

    if isempty(obj.srcBlockObj)
        return;
    end

    channel=hmiblockdlg.ParameterDlg.getChannel();

    paramSource=Simulink.HMI.ParamSourceInfo;
    block=get(obj.srcBlockObj,'Name');
    block=regexprep(block,'/','//');
    bpath=get(obj.srcBlockObj,'Parent');

    paramSource.BlockPath=Simulink.BlockPath([bpath,'/',block]);
    if isempty(obj.srcWksType)
        paramSource.ParamName=obj.srcParamOrVar;
    else
        paramSource.WksType=obj.srcWksType;
        paramSource.VarName=obj.srcParamOrVar;
    end
    paramSource.Element=obj.srcElement;
    valueToTune=paramSource.getValue;
    if isa(valueToTune,'Simulink.Parameter')
        valueToTune=valueToTune.Value;
    end
    if~isscalar(valueToTune)||isstruct(valueToTune)
        if isempty(paramSource.Element)
            message.publish([channel,'addShadowToElementTextfield'],{});
        end
        error(message('SimulinkHMI:errors:InvalidNonScalarTuningElement'));
    end
    modelName=get_param(bdroot(obj.srcBlockObj.Handle),'Name');
    isCoreWebBlock=get_param(obj.blockObj.Handle,'isCoreWebBlock');

    if strcmp(isCoreWebBlock,'on')
        cachedModelName=get_param(obj.blockObj.Handle,'ModelName');
        if~isequal(cachedModelName,modelName)
            set_param(obj.blockObj.Handle,'ModelName',modelName);
        end
        set_param(obj.blockObj.Handle,'Binding',paramSource);
        boundElem=utils.getBoundParamStruct(paramSource);
    else
        widget=utils.getWidget(modelName,obj.widgetId,obj.isLibWidget);

        if~isempty(widget)
            widget.bind(paramSource,obj.isLibWidget);
        end

        boundElem=utils.getBoundParam(modelName,obj.widgetId,obj.isLibWidget);
    end
    boundElem.Element=paramSource.getElementToDisplay;
    message.publish([channel,'changeBoundElement'],{obj.widgetId,boundElem});
end
