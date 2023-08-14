function res=doesChartDeclaresDSMem(chartPath,memName)
    chartID=sfprivate('block2chart',chartPath);
    chartH=idToHandle(sfroot,chartID);
    d=chartH.find('-isa','Stateflow.Data','scope','Data Store Memory','Name',memName);
    if isempty(d)
        res=false;
    else
        res=true;
    end
end
