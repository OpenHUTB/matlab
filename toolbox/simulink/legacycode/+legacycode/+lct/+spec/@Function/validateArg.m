



function validateArg(this,argSpec)


    argPosOffet=argSpec.NameStartPos-1;
    argName=argSpec.NameExpr;
    this.checkIdentifierRadix(argName,argSpec.Data.Radix,argPosOffet-1);
    this.checkIdentifierIdx(argName,argSpec.Data.Id,argPosOffet);
    this.checkUniqueUsage(argSpec);


    if argSpec.Data.isExprArg()&&argSpec.Data.IsComplex
        this.throwError('LCTSpecParserBadComplexSizeArg',...
        argSpec.TypeStartPos-1,numel(argSpec.TypeExpr));
    end


    if strcmp(argSpec.TypeExpr,'void')&&~argSpec.Data.isDWork()
        [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.Expression);
        this.throwError('LCTErrorValidateVoidArg',...
        numS+argSpec.TypeStartPos-1,numel(argStr));
    end





    isInf=[argSpec.Data.DimsInfo.IsInf];
    if~(all(isInf==true)||all(isInf==false))
        [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.DimExpr);
        this.throwError('LCTSpecParserBadMixedDynFixDims',...
        numS+argSpec.DimStartPos-1,numel(argStr));
    end


    for ii=1:numel(argSpec.Data.DimsInfo)
        dimInfo=argSpec.Data.DimsInfo(ii);

        if dimInfo.Val==-1

            if isempty(dimInfo.Info)&&(argSpec.Data.isOutput()||argSpec.Data.isDWork())

                this.throwError('LCTSpecParserBadOutputOrDWorkDim',...
                argSpec.DimStartPos-1,numel(argSpec.DimExpr));
            end
        end


        if~argSpec.Data.isExprArg()
            if dimInfo.Val<=0&&dimInfo.HasInfo&&all(strcmp('i',{dimInfo.Info.Kind}))
                this.throwError('LCTSpecParserBadDimSpec',...
                dimInfo.Pos-1,numel(dimInfo.Expr));
            end
        end

        for jj=1:numel(dimInfo.Info)
            exprInfo=dimInfo.Info(jj);


            if~any(strcmp(exprInfo.Kind,{'v','n','s'}))
                continue
            end


            this.checkIdentifierIdx(exprInfo.Txt,exprInfo.Id,dimInfo.Pos);



            if argSpec.Data.isExprArg()
                continue
            end



            if argSpec.Data.isParameter()
                this.throwError('LCTSpecParserBadParameterDim',...
                dimInfo.Pos-1,numel(dimInfo.Expr));
            end



            if exprInfo.Kind=='v'
                continue
            end



            if argSpec.Data.isInput()&&strcmpi(exprInfo.Radix,'u')
                this.throwError('LCTSpecParserBadInputDim',...
                dimInfo.Pos-1,numel(dimInfo.Expr));
            end


            if~ismember(lower(exprInfo.Radix),{'u','p'})
                this.throwError('LCTSpecParserBadOutputOrDWorkDimForDynSize',...
                dimInfo.Pos-1,numel(dimInfo.Expr));
            end
        end
    end


    dataDims=argSpec.Data.Dimensions;
    if numel(dataDims)>2&&dataDims(end)==1
        this.throwError('LCTSpecParserBadTrailingDim',...
        argSpec.DimStartPos-1,numel(argSpec.DimExpr));
    end






    idxDimsDynSize=find(dataDims==-1);
    idxDimsNeg=find(dataDims<=0);
    if~isempty(setxor(idxDimsDynSize,idxDimsNeg))
        this.throwError('LCSpecParserBadDimSpec',...
        argSpec.DimStartPos-1,numel(argSpec.DimExpr));
    end


