function[dsNames,varNames]=getDSMInfoV1(blockH)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    try
        blkObj=get_param(blockH,'Object');
        local_dsmInfo=blkObj.getNeededDSMemBlks();
    catch exc %#ok<NASGU>
        local_dsmInfo=[];
    end
    delete(sess);

    dsNames={};
    numDSMs=length(local_dsmInfo);
    for dsIdx=1:numDSMs
        dsNames{end+1}=get_param(local_dsmInfo(dsIdx).Handle,'DataStoreName');
    end

    context=getfullname(blockH);
    filterSignals=...
    @(var)(isa(var,'Simulink.Signal')&&~isa(var,'Simulink.Bus'));
    varsbws=Simulink.findVars(context,'SearchMethod','cached',...
    'WorkspaceType','base',...
    'ReturnResolvedVar',true,...
    'Value',filterSignals);
    varsmws=Simulink.findVars(context,'SearchMethod','cached',...
    'WorkspaceType','model',...
    'ReturnResolvedVar',true,...
    'Value',filterSignals);

    vars=[varsbws',varsmws'];
    varNames={vars.Name};
end
