
function newObj=copy(this)




    newObj=this.getCopyWithEmptySymbolTable;


    newObj.tree=this.getMTree;




    cellfun(@(var,varTypeInfo)newObj.addVarInfo(var...
    ,varTypeInfo{1}.copy)...
    ,this.symbolTable.keys...
    ,this.symbolTable.values);


    newObj.callSites=this.callSites;
end
