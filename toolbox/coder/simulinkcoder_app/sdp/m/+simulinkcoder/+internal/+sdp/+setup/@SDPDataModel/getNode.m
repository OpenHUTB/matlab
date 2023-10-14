function node = getNode( obj, id )

arguments
    obj
    id
end

if obj.nodeMap.isKey( id )
    node = obj.nodeMap( id );
else
    node = simulinkcoder.internal.sdp.setup.SDPModelNode( id );
    obj.nodeMap( id ) = node;
end


