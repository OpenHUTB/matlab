

function currDecl=getVariableDeclaration(varImp)
    try
        if isa(varImp,'RTW.Variable')
            if varImp.isDefined
                currExpr=varImp.getExpression;
            else
                currExpr=varImp.Identifier;
            end
            currTypeIdentifier=getTypeIdentifier(varImp.Type);
            if varImp.Type.isMatrix
                matrixWidth=varImp.Type.getWidth;
                if matrixWidth>1
                    currDecl=[currTypeIdentifier,' ',currExpr,'[',num2str(matrixWidth),']'];
                else
                    currDecl=[currTypeIdentifier,' ',currExpr];
                end
            elseif varImp.Type.isPointer
                currDecl=[currTypeIdentifier,currExpr];
            else
                currDecl=[currTypeIdentifier,' ',currExpr,''];
            end
        elseif isa(varImp,'RTW.Argument')
            currTypeIdentifier=getTypeIdentifier(varImp.Type);
            if varImp.Type.isPointer
                space='&nbsp';
                if currTypeIdentifier(end)=='*'
                    space='';
                end
                currDecl=[currTypeIdentifier,space,varImp.Name];
            elseif varImp.Type.isMatrix
                matrixWidth=varImp.Type.getWidth;
                if matrixWidth>1
                    currDecl=[currTypeIdentifier,' ',varImp.Name,'[',num2str(matrixWidth),']'];
                else
                    currDecl=[currTypeIdentifier,' ',varImp.Name];
                end
            else
                currDecl=[currTypeIdentifier,' ',varImp.Name];
            end
        end
    catch %#ok<CTCH>
        currDecl='';
    end

end
