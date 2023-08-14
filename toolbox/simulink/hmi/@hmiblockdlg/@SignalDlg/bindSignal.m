

function bindSignal(obj)

    if isempty(obj.srcBlockObj)
        return;
    end



    if~isempty(obj.PreviousBinding)&&...
        obj.PreviousBinding.OutputPortIndex==obj.OutputPortIndex&&...
        obj.PreviousBinding.CachedBlockHandle_==obj.srcBlockObj.Handle
        signalSource=obj.PreviousBinding;
    else
        signalSource=Simulink.HMI.SignalSpecification;
        block=get(obj.srcBlockObj,'Name');
        block=regexprep(block,'/','//');
        bpath=get(obj.srcBlockObj,'Parent');

        signalSource.BlockPath=Simulink.BlockPath([bpath,'/',block]);
        signalSource.OutputPortIndex=obj.OutputPortIndex;
        signalSource.CachedBlockHandle_=obj.srcBlockObj.Handle;
    end


    signalSource=signalSource.applyRebindingRules();

    modelName=get_param(bdroot(obj.srcBlockObj.Handle),'Name');
    modelHandle=get_param(modelName,'Handle');
    isCoreWebBlock=get_param(obj.blockObj.Handle,'isCoreWebBlock');

    if strcmp(isCoreWebBlock,'on')
        cachedModelName=get_param(obj.blockObj.Handle,'ModelName');
        if~isequal(cachedModelName,modelName)
            set_param(obj.blockObj.Handle,'ModelName',modelName);
        end
        set_param(obj.blockObj.Handle,'Binding',signalSource);
    else
        widget=utils.getWidget(modelName,obj.widgetId,obj.isLibWidget);

        if~isempty(widget)
            if Simulink.HMI.WebHMI.isBound(modelHandle,obj.widgetId,obj.isLibWidget)
                widget.unbind(obj.isLibWidget);
            end
            widget.bind(signalSource,obj.isLibWidget);
        end

        boundElem=utils.getBoundSignal(modelName,obj.widgetId,obj.isLibwidget);
        channel=hmiblockdlg.SignalDlg.getChannel();
        message.publish([channel,'changeBoundElement'],{obj.widgetId,boundElem});
    end
end
