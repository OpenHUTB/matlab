
function type=getVarInfo(this,varIdNode)




    type=[];

    if ischar(varIdNode)
        varName=varIdNode;

        if coder.internal.Float2FixedConverter.supportMCOSClasses
            if this.symbolTable.isKey(varName)
                namedVars=this.symbolTable(varName);
                type=namedVars{1};
                return;
            end
        end

        varName=this.getRootVarName(varName);

        if this.symbolTable.isKey(varName)
            namedVars=this.symbolTable(varName);
            type=namedVars{1};
        end
        return;
    end

    varName=varIdNode.string;
    textPos=lefttreepos(varIdNode);

    if this.symbolTable.isKey(varName)
        namedVars=this.symbolTable(varName);
        matchPos=-1;
        for ii=1:length(namedVars)
            namedVar=namedVars{ii};
            if namedVar.TextStart<=textPos
                if namedVar.TextStart>matchPos
                    type=namedVar;
                    matchPos=namedVar.TextStart;
                end
            end
        end
    end
end


