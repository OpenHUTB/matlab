function drawCostForAllBlocksOnCanvas(CostTable)











    drawCostForBlockWrapper=@(BlockName,BlockCost,TotalBlockCost)...
    designcostestimation.internal.util.drawCostForBlockOnCanvas(BlockName,BlockCost,TotalBlockCost);
    rowfun(drawCostForBlockWrapper,CostTable,'NumOutputs',0);
end


