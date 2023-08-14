function mode=calcOperationMode(v,params)












    v1=params.OperationModeBoundaries(1);
    v2=params.OperationModeBoundaries(2);
    mode=discretize(v,[0,v1,v2,inf],...
    'categorical',{'urban','rural','motorway'},...
    'IncludedEdge','right');
end