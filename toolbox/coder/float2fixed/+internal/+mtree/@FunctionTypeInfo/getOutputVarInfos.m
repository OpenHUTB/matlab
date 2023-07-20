
function varInfos=getOutputVarInfos(this)




    varInfos=coder.internal.VarTypeInfo.empty();
    for ii=1:length(this.outputVarNames)
        varName=this.outputVarNames{ii};
        if this.symbolTable.isKey(varName)
            namedVars=this.symbolTable(varName);
            namedVars=[namedVars{:}];

            varInfos=[varInfos,namedVars([namedVars.isOutputArg])];%#ok<AGROW>
        end
    end
end
