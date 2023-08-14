function res=isMenuActionEnabled(cbinfo,isHarnessBD)






    simStatus=get_param(cbinfo.model.Handle,'SimulationStatus');

    restartStatus=get_param(cbinfo.model.Handle,'InteractiveSimInterfaceExecutionStatus');

    [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);

    editor=cbinfo.studio.App.getActiveEditor;
    if~isempty(editor)&&isvalid(editor)&&~editor.isLocked
        locked=false;
    else
        locked=true;
    end

    harnessOwnerFullPath=[];
    if~isHarnessBD&&Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)
        harnessOwnerFullPath=Simulink.harness.internal.getActiveHarness(cbinfo.model.Name).ownerFullPath;
    end

    if slfeature('LockMainMdlSubsysOnHarnessOpen')&&~isempty(harnessOwnerFullPath)&&isValidSel(sel)&&isParentBlockSame(sel.getFullName,harnessOwnerFullPath)

        res=false;
    elseif~slfeature('LockMainMdlSubsysOnHarnessOpen')&&~isHarnessBD&&Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)

        res=false;
    elseif(~strcmpi(simStatus,'stopped')||locked)&&restartStatus~=2


        res=false;
    elseif restartStatus==2&&isHarnessBD

        res=false;
    else
        res=true;
    end

    isLinked=false;
    if(numel(sel)==1)&&isa(sel,'Simulink.SubSystem')
        isLinked=strcmp(sel.LinkStatus,'resolved')||...
        strcmp(sel.LinkStatus,'inactive');
    end


    if~res&&isCompatSingleSel&&(isLinked||Simulink.harness.internal.isImplicitLink(sel.Handle))...
        &&~IsInsideLockedLibrary(sel)
        res=true;
    end
end

function res=IsInsideLockedLibrary(ownerBlk)
    bd=Simulink.harness.internal.getBlockDiagram(ownerBlk);
    bd=get_param(bd,'object');
    res=bd.isLibrary&&strcmp(get_param(bd.Handle,'lock'),'on');
end


function res=isValidSel(sel)



    res=(numel(sel)==1)&&(isa(sel,'Simulink.SubSystem')||isa(sel,'Simulink.ModelReference')||isa(sel,'Simulink.BlockDiagram'));
end

function res=isParentBlockSame(selBlock,harnessOwnerBlock)

    res=false;


    if isequal(selBlock,harnessOwnerBlock)
        res=true;
        return;
    end

    harnessOwnerHandle=get_param(harnessOwnerBlock,'handle');
    selHandle=get_param(selBlock,'handle');
    bdrootHandle=bdroot(harnessOwnerHandle);
    selBdrootHandle=bdroot(selHandle);




    if~isequal(selBdrootHandle,bdrootHandle)
        return;
    end



    while(~isequal(selHandle,bdrootHandle))
        selHandle=get_param(get(selHandle,'Parent'),'handle');
        if isequal(selHandle,harnessOwnerHandle)
            res=true;
            break;
        end
    end
end
