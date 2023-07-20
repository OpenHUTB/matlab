
function typeInfo=getOriginalTypeInfo(this,node)




    typeInfo=[];
    compiledMxLocInfo=this.treeAttributes(node).CompiledMxLocInfo;
    if~isempty(compiledMxLocInfo)
        mxTypeInfo=this.fcnRegistry.mxInfos{compiledMxLocInfo.MxInfoID};
        typeInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxTypeInfo,this.fcnRegistry.mxArrays);
    end
end
