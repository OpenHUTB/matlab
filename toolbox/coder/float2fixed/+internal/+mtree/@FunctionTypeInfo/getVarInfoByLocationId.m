
function info=getVarInfoByLocationId(this,varName,textStart,textLength,MxInfoLocationId)




    info=[];
    if this.symbolTable.isKey(varName)
        namedVars=this.symbolTable(varName);
        for ii=1:length(namedVars)
            namedVar=namedVars{ii};
            if namedVar.TextStart==textStart&&namedVar.TextLength==textLength





                info=namedVar;







                if namedVar.Synthesized||namedVar.MxInfoLocationId==MxInfoLocationId
                    info=namedVar;
                    return;
                end
            end
        end
    end
end


