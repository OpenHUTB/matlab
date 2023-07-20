function flag=IsUnderReadOnlySystem(blkObj)





    flag=false;

    curRoot=get_param(bdroot(blkObj.Handle),'Name');


    isArchitectureModel=Simulink.internal.isArchitectureModel(curRoot);
    if isArchitectureModel
        flag=true;
        return;
    end


    rootHarnessSetting=get_param(curRoot,'isHarness');
    if strcmp(rootHarnessSetting,'on')
        flag=true;
        return;
    end


    if isa(blkObj,'Simulink.SubSystem')||isa(blkObj,'Simulink.BlockDiagram')
        curParent=blkObj.getFullName();
    else
        curParent=blkObj.parent;
    end


    while~strcmp(curParent,curRoot)

        localPermission=get_param(curParent,'Permissions');
        if strcmp(localPermission,'ReadOnly')||strcmp(localPermission,'NoReadOrWrite')
            flag=true;
            return;
        end


        partOfReference=get_param(curParent,'ReferencedSubsystem');
        if~isempty(partOfReference)
            flag=true;
            return;
        end

        curParent=get_param(curParent,'parent');
    end

end