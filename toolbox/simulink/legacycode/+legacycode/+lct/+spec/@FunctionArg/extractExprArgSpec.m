




function extractExprArgSpec(this)



    this.Data.Identifier='expr1';


    this.extractDataTypeNameInfo();


    sizeExpr=this.Expr;
    sizeExprVisitor=legacycode.lct.spec.ExprVisitor(sizeExpr);
    try
        exprInfo=sizeExprVisitor.getExprInfo();
    catch Me

        throw(legacycode.lct.spec.ParseException('LCTSpecParserBadSizeSyntax',...
        sizeExpr,this.ExprStartPos,Me.message));
    end


    this.Data.DimsInfo=legacycode.lct.spec.DimInfo();
    this.Data.DimsInfo.Pos=this.ExprStartPos;
    this.Data.DimsInfo.Expr=sizeExpr;
    this.Data.DimsInfo.Info=exprInfo;
