


function infos=getVarInfosByFullVarName(this,fullVarName)



    infos={};
    if this.symbolTable.isKey(fullVarName)
        infos=this.symbolTable(fullVarName);
    end
end


