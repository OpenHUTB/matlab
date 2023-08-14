function Pnodes=exportGeometry(obj)





    Pnodes=cellfun(@(x)x.wireNodesOrig,obj.WiresInt,'UniformOutput',false);

end
