






function resolveArrayNodes(ast)
    newChildren=ast.getChildren();
    for k=1:numel(newChildren);
        newChild=newChildren{k};
        if isa(newChild,'slci.ast.SFAstArray')
            arrayChildren=newChild.getChildren();
            assert(numel(arrayChildren)>0);
            left=arrayChildren{1};

            if isa(left,'slci.ast.SFAstDot')
                leftChildren=left.getChildren();
                assert(numel(leftChildren)>0);
                if isclass(leftChildren{1})
                    newAst=slci.ast.SFAstUnsupported(...
                    newChild.getMtree(),ast);
                    newChild=newAst;
                end
            end
        end
        if newChild==newChildren{k}

            slci.matlab.astTranslator.resolveArrayNodes(newChild);
        end
        newChildren{k}=newChild;
    end
    ast.setChildren(newChildren);
end


function out=isclass(ast)
    out=false;
    datatype=ast.getDataType();
    if~slci.internal.isSimulinkBuildInType(datatype);
        out=true;
        symTable=ast.ParentChart.getSymbolTable;
        if symTable.hasSymbol(datatype)
            baseType=symTable.getType(datatype);

            isstruct=isa(baseType,'slci.mlutil.MLStructType')...
            ||isa(baseType,'Simulink.Bus');
            if isstruct
                out=false;
            end
        end
    end
end
