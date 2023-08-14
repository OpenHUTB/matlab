


function newFcnTypeInfo=getCopyWithEmptySymbolTable(this)



    newFcnTypeInfo=internal.mtree.FunctionTypeInfo(this.functionName,...
    this.specializationName,...
    this.uniqueId,...
    this.getMTree.tree2str,...
    this.scriptPath);
    newFcnTypeInfo.inferenceId=this.inferenceId;
    newFcnTypeInfo.specializationId=this.specializationId;
    newFcnTypeInfo.className=this.className;
end
