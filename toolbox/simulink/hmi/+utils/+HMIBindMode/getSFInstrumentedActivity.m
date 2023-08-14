

function match=getSFInstrumentedActivity(modelName,obj,mode)

    match=[];
    isChart=false;
    if isa(obj,'Stateflow.Chart')||...
        isa(obj,'Stateflow.StateTransitionTableChart')
        isChart=true;
        ssid=[];
    else
        chartId=sfprivate('getChartOf',obj.Id);
        chart=sf('IdToHandle',chartId);
        ssid=num2str(obj.SSIdNumber);
    end


    instrumentedSignals=get_param(modelName,'InstrumentedSignals');
    for idx=1:instrumentedSignals.Count
        signalSpec=instrumentedSignals.get(idx);
        domainParams=signalSpec.DomainParams_;
        if isChart


            if isfield(domainParams,'Activity')&&...
                strcmp(domainParams.Activity,mode)&&...
                strcmp(signalSpec.BlockPath_,obj.Path)
                match=signalSpec;
                break
            end
        else


            if isfield(domainParams,'SSID')&&...
                isfield(domainParams,'Activity')&&...
                strcmp(domainParams.SSID,ssid)&&...
                strcmp(domainParams.Activity,mode)&&...
                strcmp(signalSpec.BlockPath_,chart.Path)
                match=signalSpec;
                break
            end
        end
    end
end