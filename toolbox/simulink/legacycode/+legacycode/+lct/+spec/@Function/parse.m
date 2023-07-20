



function parse(this)

    try

        defObj=legacycode.lct.spec.Common.instance();




        partPos=regexpi(this.Expression,defObj.SpecExpr,'tokenExtents');
        if isempty(partPos)||~isnumeric(partPos{1})||any(size(partPos{1})~=[4,2])||(diff(partPos{1}(3,:))<0)
            this.throwError('LCTSpecParserBadSpec',0,numel(this.Expression));
        end


        this.SpecPos=partPos{1};



        hasEqOp=~isempty(this.EqExpr);


        lhsExpr=this.LhsExpr;
        if isempty(lhsExpr)


            startExpr=this.Expression(1:this.NameStartPos-1);
            if hasEqOp||~isempty(regexprep(startExpr,' ',''))
                throw(legacycode.lct.spec.ParseException('LCTSpecParserBadLhsExpr',...
                startExpr,0));
            end
        else

            [lhsExpr,numS]=defObj.remWhiteSpaces(lhsExpr);
            isVoidExpr=strcmpi(lhsExpr,'void');
            if(isVoidExpr&&hasEqOp)||(~isVoidExpr&&~hasEqOp)
                throw(legacycode.lct.spec.ParseException('LCTSpecParserBadLhsExpr',...
                this.Expression(1:this.NameStartPos-1),0));
            end

            if~isVoidExpr

                lhsExpr=strtrim(lhsExpr);


                argSpec=legacycode.lct.spec.FunctionArg(lhsExpr,this.LhsStartPos+numS-1);


                if~argSpec.Data.isOutput()||~argSpec.PassedByValue
                    this.throwError('LCTSpecParserBadFcnReturn',numS,numel(lhsExpr));
                end


                argSpec.Id=1;
                argSpec.AccessKind=legacycode.lct.spec.AccessKind.Return;


                this.validateArg(argSpec);


                this.LhsArgs.add(argSpec);
            end
        end


        posArgList=this.ArgListPos;
        argListStr=this.ArgListExpr;

        if~isempty(argListStr)

            remTxt=this.Expression(this.ArgListPos(2)+1:end);
            checkSpecRemainder(this,remTxt,this.ArgListPos(2)-1);

            [argListStr,numS]=defObj.remWhiteSpaces(argListStr);


            argsPos=regexpi(argListStr,['(',defObj.ArgSpecExpr,')(?:,\s*)?'],'tokenExtents');

            numArgs=numel(argsPos);
            if numArgs>0

                posOffset=posArgList(1)+numS-1;
                lastEnd=0;



                if numArgs>1


                    argStr=argListStr;
                    for ii=1:numel(argsPos)
                        argStr(argsPos{ii}(1):argsPos{ii}(2))=' ';
                    end
                    idx=find(strfind(argStr,','));



                    if numel(idx)~=(numArgs-1)
                        posOffset=this.ArgListStartPos;
                        this.throwError('LCTSpecParserBadRhsExpr',posOffset-1,numel(argListStr));
                    end
                end

                for ii=1:numArgs

                    if isempty(argsPos{ii})||~isnumeric(argsPos{ii})
                        this.throwError('LCTSpecParserBadArgListExpr',...
                        posArgList(1)-1,posArgList(2)-posArgList(1)+1);
                    end
                    argPos=[min(argsPos{ii}(:)),max(argsPos{ii}(:))];


                    remTxt=argListStr(lastEnd+1:argPos(1)-1);
                    checkArgRemainder(this,defObj,remTxt,posOffset+lastEnd+double(lastEnd>0));
                    if ii<=numArgs
                        checkEndOfSpec(this,defObj,remTxt,posOffset+lastEnd);
                    end


                    lastEnd=argPos(2);


                    argExpr=argListStr(argPos(1):argPos(2));
                    argSpec=legacycode.lct.spec.FunctionArg(argExpr,posOffset+argPos(1)-1);


                    argSpec.Id=ii;


                    if argSpec.Data.isExprArg()
                        argSpec.Data.Identifier=sprintf('expr%d',findUniqueExprArgId(this,1));
                    end


                    this.validateArg(argSpec);


                    this.RhsArgs.add(argSpec);
                end


                remTxt=argListStr(argsPos{end}(2)+1:end);
                checkArgRemainder(this,defObj,remTxt,posOffset+argsPos{end}(2)+1);
                checkEndOfSpec(this,defObj,remTxt,posOffset+lastEnd);


                if~isempty(strtrim(argListStr(argsPos{end}(2)+1:end)))
                    this.throwError('LCTSpecParserBadRhsExpr',...
                    posOffset+argsPos{end}(2),posArgList(2)-argsPos{end}(2)-posOffset);
                end

            else

                posOffset=this.ArgListStartPos;
                remTxt=this.Expression(posOffset:end);
                checkEndOfSpec(this,defObj,remTxt,posOffset);


                argListStr=strtrim(argListStr);
                if~isempty(strtrim(argListStr))&&~strcmpi(argListStr,'void')
                    this.throwError('LCTSpecParserBadArgListExpr',...
                    posArgList(1)-1,posArgList(2)-posArgList(1)+1);
                end
            end
        else

            posOffset=this.ArgListStartPos;
            remTxt=this.Expression(posOffset:end);
            checkEndOfSpec(this,defObj,remTxt,posOffset);
        end

    catch Me
        if isa(Me,'legacycode.lct.spec.ParseException')
            legacycode.lct.spec.Common.error(Me,this.Expression);
        else
            rethrow(Me);
        end
    end


    function checkArgRemainder(this,defObj,remTxt,posOffset)

        if~isempty(strtrim(remTxt))
            remPos=regexp(remTxt,'[,\(]([\s*\w*])*|([\s*\w*])*[,\)]','tokenExtents');
            for jj=1:numel(remPos)
                if~isempty(remPos{jj})&&(remPos{jj}(1)<=remPos{jj}(2))
                    [remTxt,numS]=defObj.remWhiteSpaces(remTxt(remPos{jj}(1):remPos{jj}(2)));
                    if isempty(remTxt)
                        continue
                    end
                    numS=posOffset+numS;
                    numT=numel(remTxt);
                    this.throwError('LCTSpecParserBadRhsExpr',numS,numT);
                end
            end
        end


        function checkSpecRemainder(this,remTxt,posOffset)

            if~isempty(strtrim(remTxt))
                remPos=regexp(remTxt,'[^\s;\)]','once');
                if~isempty(remPos)
                    remTxt=remTxt(remPos(1):end);
                    numS=posOffset+remPos(1);
                    numT=numel(remTxt);
                    this.throwError('LCTSpecParserBadRhsExpr',numS,numT);
                end
            end


            function checkEndOfSpec(this,defObj,remTxt,posOffset)

                closingParentPos=regexp(remTxt,'\)','once');
                closingSemiColonPos=regexp(remTxt,';','once');

                if~(isempty(closingParentPos)&&isempty(closingSemiColonPos))
                    endPos=max([closingParentPos,closingSemiColonPos]);
                    badRem=this.Expression(posOffset+endPos+1:end);
                    if~isempty(defObj.remWhiteSpaces(badRem))
                        this.throwError('LCTSpecParserBadRhsExpr',posOffset+endPos,numel(badRem));
                    end
                end


                function out=findUniqueExprArgId(this,idx)


                    out=idx;


                    if this.RhsArgs.Numel<1
                        return
                    end


                    impArgIdx=find(strncmp('ExprArg',{this.RhsArgs.Items(:).DataKind},7));
                    if isempty(impArgIdx)
                        return
                    end


                    allIds=zeros(1,numel(impArgIdx),'uint32');
                    for ii=1:numel(impArgIdx)
                        allIds(ii)=this.RhsArgs.Items(impArgIdx(ii)).Data.Id;
                    end


                    out=max(allIds)+1;


