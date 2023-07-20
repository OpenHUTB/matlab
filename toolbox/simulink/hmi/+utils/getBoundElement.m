function boundElem=getBoundElement(modelName,widgetID,varargin)



    if~ishandle(modelName)
        hMdl=get_param(modelName,'Handle');
    else
        hMdl=modelName;
        modelName=get(hMdl,'Name');
    end

    isLibWidget=false;
    if~isempty(varargin)
        isLibWidget=varargin{1};
    end

    widgetBlockPath='';
    if length(varargin)>1
        widgetBlockPath=varargin{2};
    end

    if~locIsCoreBlock(widgetBlockPath)
        boundElem=getBoundElementLegacy(hMdl,widgetID,isLibWidget);
    else
        widgetHandle=get_param(widgetBlockPath,'Handle');
        if ishandle(widgetHandle)
            boundElem=Simulink.HMI.getBoundElementForDashboardBlock(widgetHandle);
        else
            boundElem=[];
        end
    end
end


function ret=locIsCoreBlock(blockPath)
    ret=false;
    if~isempty(blockPath)
        ret=~strcmpi(get_param(blockPath,'BlockType'),'SubSystem');
    end
end


function boundElem=getBoundElementLegacy(modelName,widgetID,isLibWidget)

    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelName);
    if isempty(webhmi)
        boundElem=Simulink.HMI.WebHMI.getBindable(widgetID);
    else
        boundElem=webhmi.getBoundElement(widgetID,isLibWidget);
    end
end