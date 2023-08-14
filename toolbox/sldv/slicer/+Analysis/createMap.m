function[m,edgeMap]=createMap(ir)








    bh=ir.handleToDfgIdx.keys;
    bh=[bh{:}];
    id=ir.handleToDfgIdx.values;
    bid=[id{:}];
    ph=ir.portHandleToDfgVarIdx.keys;
    ph=[ph{:}];
    pid=ir.portHandleToDfgVarIdx.values;
    pid=[pid{:}];
    ih=ir.dfgInportHToInputIdx.keys;
    ih=[ih{:}];
    iid=ir.dfgInportHToInputIdx.values;
    iid=[iid{:}];

    m=SystemsEngineering.SLGraphVertexMap(ir.dfg,...
    MSUtils.graphVertices(bid),bh,MSUtils.graphVertices(pid),ph,...
    MSUtils.graphVertices(iid),ih);

    edgeIds=ir.outputPortToInputPortEdges.keys;
    edgeIds=[edgeIds{:}];

    edgeList=ir.outputPortToInputPortEdges.values;
    varOffsets=cellfun(@(x)(x{1,1}),edgeList);
    inputOffsets=cellfun(@(x)(x{1,2}),edgeList);
    widths=cellfun(@(x)(x{1,3}),edgeList);

    edgeMap=SystemsEngineering.SLGraphEdgeMap(ir.dfg,...
    MSUtils.graphEdges(edgeIds),varOffsets,inputOffsets,widths);

    edgeIds=ir.dataDependenceBetweenInputAndVar.keys;
    edgeIds=[edgeIds{:}];

    dependencyList=ir.dataDependenceBetweenInputAndVar.values;
    varHandles=cellfun(@(x)(x{1,1}),dependencyList);
    depFlags=cellfun(@(x)(x{1,2}),dependencyList);

    edgeMap.addJacobianMap(MSUtils.graphEdges(edgeIds),varHandles,depFlags);

end

