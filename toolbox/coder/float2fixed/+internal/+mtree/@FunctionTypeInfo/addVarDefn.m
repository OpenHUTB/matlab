
function addVarDefn(this,varName,type)




    defns={};
    if this.symbolTable.isKey(varName)
        defns=this.symbolTable(varName);
    end
    defns{end+1}=type;
    defns{end}.isInputArg=defns{1}.isInputArg;
    this.symbolTable(varName)=defns;
    type.functionInfo=this;
end
