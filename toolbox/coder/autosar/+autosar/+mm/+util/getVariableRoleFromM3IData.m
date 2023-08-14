function type=getVariableRoleFromM3IData(m3iData)





    m3iBehavior=m3iData.containerM3I;
    type='';

    m3iArTypedPIM=m3iBehavior.ArTypedPIM;
    idx=autosar.mm.Model.findObjectIndexInSequence(m3iArTypedPIM,m3iData);
    if idx~=-1
        type='ArTypedPerInstanceMemory';
        return;
    end

    m3iStaticMemory=m3iBehavior.StaticMemory;
    idx=autosar.mm.Model.findObjectIndexInSequence(m3iStaticMemory,m3iData);
    if idx~=-1
        type='StaticMemory';
        return;
    end
end
