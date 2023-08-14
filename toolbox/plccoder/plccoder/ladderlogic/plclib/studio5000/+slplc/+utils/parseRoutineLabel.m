function[dataName,dsmDataName]=parseRoutineLabel(routineBlock,LabelTagName)

    blockScopeTag=slplc.utils.getBlockScopeTag(routineBlock);
    dataName=['_',blockScopeTag,'_',LabelTagName];
    headerStr='_PLCLabel_';
    dsmDataName=matlab.lang.makeValidName([headerStr,dataName]);
end