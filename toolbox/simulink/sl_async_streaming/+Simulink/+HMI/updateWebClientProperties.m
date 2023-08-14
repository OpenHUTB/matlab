

function updateWebClientProperties(webClientID,yMin,yMax,isTimeSpanAuto,varargin)



    try
        modelName=bdroot(gcs);
    catch

        return;
    end

    timeSpan='';
    if nargin>1
        timeSpan=varargin{1};
    end
    scopeTimeSpan=...
    utils.getScopeAutoTimeSpan(modelName,isTimeSpanAuto,timeSpan);

    mdlStartTime=get_param(modelName,'StartTime');
    if isvarname(mdlStartTime)
        xMin=0;
    else
        xMin=eval(mdlStartTime);
    end

    if strcmpi(get_param(modelName,'SimulationStatus'),'paused')
        mdlPauseTime=get_param(modelName,'SimulationTime');
        if(xMin<(mdlPauseTime-scopeTimeSpan))
            xMin=mdlPauseTime-scopeTimeSpan;
        end
    end


    allWebClients=Simulink.sdi.WebClient.getAllClients('hmiscope');
    for idx=1:length(allWebClients)
        client=allWebClients(idx);
        if isequal(client.ClientID,webClientID)
            axesList=client.Axes;
            for jdx=1:length(axesList)
                if axesList(jdx).AxisID==1
                    axisToBeModified=axesList(jdx);



                    axisProperties.xMin=xMin;
                    axisProperties.xMax=xMin+scopeTimeSpan;
                    axisProperties.yMin=yMin;
                    axisProperties.yMax=yMax;
                    axisProperties.isTimeSpanAuto=isTimeSpanAuto;
                    axisToBeModified.setProperties(axisProperties);
                    break;
                end
            end
        end
    end
end
