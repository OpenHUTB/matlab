



function schema=pbRefreshers(fncname,userData,cbinfo,eventData)
    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==4
            fnc(userData,cbinfo,eventData);
        elseif nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function pbZeroCrossingDetectionRefresher(~,cbinfo,action)
    zc=get_param(cbinfo.uiObject.Handle,'ZeroCross');
    if strcmp(zc,'off')
        action.selected=false;
    else
        action.selected=true;
    end
end

function pbBeforeFirstExtrapolationRefresher(userData,cbinfo,action)
    extrapolation=get_param(cbinfo.uiObject.Handle,'ExtrapolationBeforeFirstDataPoint');
    action.selected=false;
    if strcmp(userData,"linear")&&strcmp(extrapolation,"Linear extrapolation")
        action.selected=true;
        return;
    end
    if strcmp(userData,"holdfirstvalue")&&strcmp(extrapolation,"Hold first value")
        action.selected=true;
        return;
    end
    if strcmp(userData,"ground")&&strcmp(extrapolation,"Ground value")
        action.selected=true;
        return;
    end
end

function pbAfterLastExtrapolationRefresher(userData,cbinfo,action)
    extrapolation=get_param(cbinfo.uiObject.Handle,'ExtrapolationAfterLastDataPoint');
    action.selected=false;
    if strcmp(userData,"linear")&&strcmp(extrapolation,"Linear extrapolation")
        action.selected=true;
        return;
    end
    if strcmp(userData,"holdfirstvalue")&&strcmp(extrapolation,"Hold last value")
        action.selected=true;
        return;
    end
    if strcmp(userData,"ground")&&strcmp(extrapolation,"Ground value")
        action.selected=true;
        return;
    end
end

function pbPortsEditorRefresher(~,cbinfo,action)
    portEditorStatus=get_param(cbinfo.uiObject.Handle,'PortEditorStatus');
    if strcmpi(portEditorStatus,"off")
        action.selected=false;
    else
        action.selected=true;
    end
end

function pbSparklinesSortRefresher(~,cbinfo,action)
    if(strcmpi(locCheckSimulationStatus(cbinfo,action),'stopped'))
        currentView=get_param(cbinfo.uiObject.Handle,'View');
        action.selected=currentView.sortSparklines;
    end
end

function pbDeleteDataRefresher(~,cbinfo,action)
    if(strcmpi(locCheckSimulationStatus(cbinfo,action),'stopped'))
        locSetButtonStatusBasedOnSignalData(cbinfo,action);
    end
end

function pbRefreshDataRefresher(~,cbinfo,action)
    if(strcmpi(locCheckSimulationStatus(cbinfo,action),'stopped'))
        locSetButtonStatusBasedOnSignalData(cbinfo,action);
    end
end

function pbAddRefresher(~,cbinfo,action)
    locCheckSimulationStatus(cbinfo,action);
end

function pbParametersDropDownRefresher(~,cbinfo,action)
    locCheckSimulationStatus(cbinfo,action);
end

function locSetButtonStatusBasedOnSignalData(cbinfo,action)
    if(strcmp(get_param(bdroot(cbinfo.uiObject.Handle),'Lock'),'on'))
        return;
    end
    signalMetaData=get_param(cbinfo.uiObject.Handle,'SignalMetaData');
    if isempty(signalMetaData)
        action.enabled=false;
    else
        action.enabled=true;
    end
end

function simStatus=locCheckSimulationStatus(cbinfo,action)
    simStatus=get_param(bdroot(cbinfo.uiObject.Handle),'SimulationStatus');
    if strcmpi(simStatus,'stopped')
        action.enabled=true;
    else
        action.enabled=false;
    end
end