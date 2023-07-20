
function widget=getWidget(modelName,widgetID,varargin)

    if~ishandle(modelName)
        modelName=get_param(modelName,'Handle');
    end
    isLibWidget=false;
    if nargin>2
        isLibWidget=varargin{1};
    end
    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelName);


    if isempty(webhmi)
        widget=Simulink.HMI.getActiveWidget(widgetID);

    else
        widget=webhmi.getWidget(widgetID,isLibWidget);
    end
end