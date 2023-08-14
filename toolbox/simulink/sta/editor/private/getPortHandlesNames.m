
function[allPortH,allPortNames]=getPortHandlesNames(model,varargin)



    if isempty(varargin)
        GET_ALL=true;
    else
        GET_ALL=varargin{1};
    end


    [portH_Inports,~,portName,~,~]=...
    Simulink.iospecification.InportProperty.getInportProperties(model,GET_ALL);


    [portH_Enable,~,portNameEnable,~]=...
    Simulink.iospecification.InportProperty.getEnableProperties(model);


    [portH_Trigger,~,portNameTrig,~]=...
    Simulink.iospecification.InportProperty.getTriggerProperties(model);



    if~isempty(portH_Inports)
        portH_Inports=[portH_Inports{:}];
    else
        portH_Inports=[];
    end


    if~isempty(portH_Enable)
        portH_Enable=[portH_Enable{:}];
    else
        portH_Enable=[];
    end


    if~isempty(portH_Trigger)
        portH_Trigger=[portH_Trigger{:}];
    else
        portH_Trigger=[];
    end

    allPortH=[portH_Inports,portH_Enable,portH_Trigger];
    allPortNames=[portName',portNameEnable,portNameTrig];
