function G=extractBDHierarchyGraph(bd,followMWLibraries)









    edges=Advisor.component.internal.extractHierarchyEdges(bd,followMWLibraries);


    allnodes=unique(edges(:));

    nodeTable=table(allnodes,'VariableNames',{'Handle'});


    alledges=toIndex(allnodes,edges);


    edgeTable=table(alledges,...
    'VariableNames',{'EndNodes'});


    G=digraph(edgeTable,nodeTable);

end


function I=toIndex(baseline,input)
    [~,I]=ismember(input,baseline);
end