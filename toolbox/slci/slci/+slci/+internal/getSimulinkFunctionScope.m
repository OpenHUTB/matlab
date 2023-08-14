









function scope=getSimulinkFunctionScope(fcnBlkHdl)
    blkObj=get_param(fcnBlkHdl,'Object');
    assert(isa(blkObj,'Simulink.SubSystem'));
    assert(strcmpi(slci.internal.getSubsystemType(blkObj),'SimulinkFunction'),...
    'Not a Simulink Function block');
    blkPath=getFullName(blkObj);
    pathCell=strsplit(blkPath,'/');
    assert(numel(pathCell)>1,['At least two levels are expected for '...
    ,'Simulink Function Block Path']);
    if numel(pathCell)==2

        scope=[];
    else
        scope=pathCell{end-1};
    end