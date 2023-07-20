function reason=getSimulinkReductionReason(obj,sid)
    reason=[];
    if isempty(obj.SimulinkReducedBlockMap)&&~isempty(obj.SimulinkReducedBlocks)
        obj.SimulinkReducedBlockMap=containers.Map(obj.SimulinkReducedBlocks,obj.SimulinkReductionReason,'UniformValues',true);
    end
    if~isempty(obj.SimulinkReducedBlockMap)&&obj.SimulinkReducedBlockMap.isKey(sid)
        reason=obj.SimulinkReducedBlockMap(sid);
    end
end
