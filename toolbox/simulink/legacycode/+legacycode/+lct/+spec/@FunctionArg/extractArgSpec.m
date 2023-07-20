




function extractArgSpec(this)


    this.Data.Identifier=this.NameExpr;


    this.extractDataTypeNameInfo();


    sizeSpec=this.DimExpr;
    sizePosOffset=this.DimStartPos-1;
    sizePos=regexpi(sizeSpec,'\s*\[\s*(.*?)\s*\]\s*','tokenExtents');
    numDims=numel(sizePos);

    if numDims==0

        this.AccessKind=legacycode.lct.spec.AccessKind.Value;
    else

        this.AccessKind=legacycode.lct.spec.AccessKind.Pointer;


        this.Data.DimsInfo=repmat(legacycode.lct.spec.DimInfo(),numDims,1);

        for ii=1:numDims

            sizeExpr=sizeSpec(sizePos{ii}(1,1):sizePos{ii}(1,2));


            this.Data.DimsInfo(ii).Pos=sizePosOffset+sizePos{ii}(1,1);
            this.Data.DimsInfo(ii).Expr=sizeExpr;


            if isempty(sizeExpr)
                continue
            end


            sizeExprVisitor=legacycode.lct.spec.ExprVisitor(sizeExpr);
            try
                exprInfo=sizeExprVisitor.getExprInfo();
            catch Me

                throw(legacycode.lct.spec.ParseException('LCTSpecParserBadSizeSyntax',...
                sizeExpr,this.Data.DimsInfo(ii).Pos,Me.message));
            end


            this.Data.DimsInfo(ii).Info=exprInfo;


            kinds={exprInfo.Kind};
            if~isempty(kinds)&&all(strcmp('i',kinds))
                try
                    [~,val]=evalc(sizeExpr);
                catch Me

                    rethrow(Me);
                end


                iVal=int32(val);
                if val~=iVal


                end


                this.Data.DimsInfo(ii).Val=iVal;
            elseif lower(sizeExpr)=="inf"
                this.Data.DimsInfo(ii).IsInf=true;
            end

        end
    end
