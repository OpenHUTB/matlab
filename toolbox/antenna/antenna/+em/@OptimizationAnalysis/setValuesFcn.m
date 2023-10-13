function setValuesFcn( obj, setFcn )

arguments
obj( 1, 1 ){ mustBeNonempty }
setFcn( 1, 1 )function_handle{ mustBeNonempty }
end 
obj.OptimStruct.SetValuesFcn = setFcn;
end 



