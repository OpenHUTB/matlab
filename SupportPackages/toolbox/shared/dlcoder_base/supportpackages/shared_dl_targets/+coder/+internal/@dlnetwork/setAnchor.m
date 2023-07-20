%#codegen



function setAnchor(obj)




    coder.allowpcode('plain');
    coder.inline('always');


















    coder.extrinsic('coder.internal.coderNetworkUtils.getUniqueName');

    unique_name=coder.const(@coder.internal.coderNetworkUtils.getUniqueName,obj.MatFile,obj.NetworkName,obj.DataType,obj.CodegenInputSizes);

    obj.anchor=coder.opaque(unique_name);
end
