function sfObj=getSFObj(block,objType)







    name='';
    sfObjPath='';

    if objType~=Simulink.variant.utils.StateflowObjectType.CHART
        [block,name]=Simulink.variant.utils.getParentBlockPathFromString(block);
        [sfObjPath,name]=Simulink.variant.utils.getPathAndNameOfObjectInSFChart(name);
    end

    block=Simulink.variant.utils.getRefBlockIfLibBlockForStateflow(block);

    if~isempty(sfObjPath)
        block=[block,'/',sfObjPath];
    end

    sfRoot=sfroot;

    switch objType
    case Simulink.variant.utils.StateflowObjectType.CHART
        sfObj=sfRoot.find('-isa',objType.getType(),'Path',block);
    case{Simulink.variant.utils.StateflowObjectType.ATOMIC_SUBCHART,...
        Simulink.variant.utils.StateflowObjectType.SIMULINK_FUNCTION,...
        Simulink.variant.utils.StateflowObjectType.SIMULINK_STATE}
        sfObj=sfRoot.find('-isa',objType.getType(),'Path',block,'Name',name);
    end

end
