function[allEdges]=shareDataObjects(~,allNodes,allEdges)






    dataObjectUniqueKeyToResultMap=SimulinkFixedPoint.AutoscalerUtils.getDataObjectUniqueKeyToResultMap(allNodes);


    dataObjectEdges=SimulinkFixedPoint.AutoscalerUtils.getDataObjectEdges(dataObjectUniqueKeyToResultMap);


    breakpointObjectEdges=SimulinkFixedPoint.AutoscalerUtils.getBreakpointObjectEdges(allNodes);


    allEdges=[allEdges,dataObjectEdges,breakpointObjectEdges];
end
