
function varInfos=getInputVarInfos(this)




    varInfos=coder.internal.VarTypeInfo.empty();
    for ii=1:length(this.inputVarNames)
        varName=this.inputVarNames{ii};
        if this.symbolTable.isKey(varName)
            namedVars=this.symbolTable(varName);
            namedVars=[namedVars{:}];

            varInfos=[varInfos,namedVars([namedVars.isInputArg])];%#ok<AGROW>
        end
    end
end
