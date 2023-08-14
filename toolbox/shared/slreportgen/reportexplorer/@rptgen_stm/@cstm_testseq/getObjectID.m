function id=getObjectID(this,state,blockPath)




    stateName=getStateName(this,state);

    assert(~isempty(stateName));

    stateId=getStateId(this,state);

    assert(~isempty(stateId));

    obj=[blockPath,'/',num2str(stateId),'/',stateName];
    id=char(mlreportgen.utils.normalizeLinkID(obj));
end