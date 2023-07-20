function node=convertVertex(jVertex)




    loc=arrayfun(@(s)char(s),jVertex.getLocation.toArray,'UniformOutput',false);
    type=char(jVertex.getType.getUUID);
    node=dependencies.internal.graph.Node(loc,type,true);

end
