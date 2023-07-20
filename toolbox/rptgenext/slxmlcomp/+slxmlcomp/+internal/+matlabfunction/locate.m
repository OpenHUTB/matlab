function[blockName,objectHandle,isStateflow]=locate(location)












    colon=find(location==':');
    assert(~isempty(colon),'Valid MATLAB function location must contain a colon');


    colon=colon(end);
    blockName=location(1:colon-1);
    ssid=str2double(location(colon+1:end));




    objectHandle=slxmlcomp.internal.stateflow.chart.get(blockName,'Stateflow.EMFunction',ssid);
    isStateflow=true;
    if isempty(objectHandle)

        isStateflow=false;

        objectHandle=slxmlcomp.internal.stateflow.chart.get(blockName,'Stateflow.EMChart');
    end

    if isempty(objectHandle)

        objectHandle=slxmlcomp.internal.stateflow.chart.get(blockName,'Stateflow.TruthTable',ssid);
    end

    if isempty(objectHandle)
        slxmlcomp.internal.error('reverseannotation:InvalidEMLLocation',location);
    elseif length(objectHandle)>1
        MSLDiagnostic(...
        'SimulinkXMLComparison:reverseannotation:AmbiguousEMLLocation',...
location...
        ).reportAsWarning;
    end

end

