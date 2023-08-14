function deleteAllBPsForBlock(obj,objectId)

    bpList=Simulink.Debug.BreakpointList.getAllBreakpoints();
    for i=1:numel(bpList)
        bp=bpList{i};
        if bp.domain==Simulink.Debug.BaseItemDomainEnum.Stateflow&&...
            (isequal(bp.ownerUdd.Id,obj.chartId)||...
            isequal(bp.ownerUdd.Id,objectId))&&...
            isa(bp,'Stateflow.Debug.EML.EMLBreakpoint')
            bp.clearBreakpointsForStateId(objectId);
            break;
        end
    end
    Stateflow.Debug.refreshSLBPList(objectId);
end

