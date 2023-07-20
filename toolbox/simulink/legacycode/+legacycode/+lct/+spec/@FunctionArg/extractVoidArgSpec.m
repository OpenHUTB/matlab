





function extractVoidArgSpec(this)


    if~isempty(regexprep(this.StarExpr,'[ |*]',''))
        throw(legacycode.lct.spec.ParseException('LCTSpecParserBadVoidArg',...
        this.Expression,this.TypeStartPos));
    end

    numStars=numel(regexprep(this.StarExpr,' ',''));
    if~(numStars==1||numStars==2)
        throw(legacycode.lct.spec.ParseException('LCTSpecParserBadStars',...
        this.StarExpr,this.StarStartPos));
    end


    this.Data.Identifier=lower(this.NameExpr);
    this.Data.DataTypeName='void';
    if numStars==1
        this.AccessKind=legacycode.lct.spec.AccessKind.Value;
    else
        this.AccessKind=legacycode.lct.spec.AccessKind.Pointer;
    end
