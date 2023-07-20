function operandExprs=getLadderExpr(ctx,pou,expr,operand)




    operand=strrep(operand,'[','(');
    operand=strrep(operand,']',')');


    varTokens_1=regexp(operand,'([a-zA-Z].*)\.(\d+)$','tokens');

    bitPosition=-1;
    if~isempty(varTokens_1)


        bitPosition=varTokens_1{1}{2};
        operand=varTokens_1{1}{1};
    end

    try
        mTreeNodes=mtree(operand);
        firstNonPRINTNode=2;
        node=mTreeNodes.select(firstNonPRINTNode);
    catch
        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:UnsupportedExpression',operand);
    end
    mtreeVisitor=plccore.frontend.L5X.LadderArgParser(node,ctx,pou,operand,expr);
    mtreeVisitor.run;

    if isempty(varTokens_1)||isa(mtreeVisitor.IR,'plccore.expr.ConstExpr')
        operandExprs=mtreeVisitor.IR;
    else
        bitPosition=str2double(bitPosition);
        operandExprs=plccore.expr.IntegerBitRefExpr(mtreeVisitor.IR,bitPosition);
    end
end


