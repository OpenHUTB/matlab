function bind(widgetId,modelName,signalInfo,varargin)



    if~ischar(modelName)
        modelName=bdroot(modelName);
    end
    isLibWidget=false;
    if nargin>3
        isLibWidget=varargin{1};
    end

    widget=utils.getWidget(modelName,widgetId,isLibWidget);
    if isempty(widget)
        return;
    end

    signalInfo=simulink.hmi.sdiscope.getSignalsToBind(widgetId,modelName,signalInfo,isLibWidget);
    widget.bind(signalInfo,isLibWidget);
end
