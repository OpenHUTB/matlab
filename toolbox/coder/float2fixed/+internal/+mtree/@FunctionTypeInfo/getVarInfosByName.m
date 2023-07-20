
function infos=getVarInfosByName(this,varName)




    infos={};

    if coder.internal.Float2FixedConverter.supportMCOSClasses
        if this.symbolTable.isKey(varName)
            namedVars=this.symbolTable(varName);
            infos=namedVars;
            return;
        end
    end

    varName=this.getRootVarName(varName);
    if this.symbolTable.isKey(varName)
        infos=this.symbolTable(varName);
    end
end
