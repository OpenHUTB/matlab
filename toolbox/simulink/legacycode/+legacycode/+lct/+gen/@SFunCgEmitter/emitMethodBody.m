



function emitMethodBody(this,codeWriter,funKind)


    fcnInfo=this.LctSpecInfo.Fcns.(funKind);


    rhsArgTypes={};
    rhsArgDeclStmts={};
    rhsArgExtraInitStmts={};
    rhsArgAccesses={};


    hasOutputOnRhs=false;

    for ii=1:fcnInfo.RhsArgs.Numel
        argSpec=fcnInfo.RhsArgs.Items(ii);
        dataSpec=argSpec.Data;
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);

        if argSpec.Data.isExprArg()

            dataType=this.LctSpecInfo.DataTypes.getTypeForDeclaration(dataType);




            dataTypeEnum=dataType.Enum;


            exprStr=legacycode.lct.gen.ExprSFunCgEmitter.emitExprArg(this.LctSpecInfo,argSpec.Data);

            argType=sprintf('Type(%s)',dataTypeEnum);
            argAccess=sprintf('Value(Type(%s), %s)',dataTypeEnum,exprStr);
        else
            if argSpec.Data.isOutput()
                hasOutputOnRhs=true;
            end

            [argType,argAccess,extraDeclStmts,extraInitStmts]=nGetTypeAndArgInfo(argSpec);

            if~isempty(extraDeclStmts)

                rhsArgDeclStmts=[rhsArgDeclStmts,extraDeclStmts];%#ok<AGROW>

                if~isempty(extraInitStmts)
                    rhsArgExtraInitStmts=[rhsArgExtraInitStmts,extraInitStmts];%#ok<AGROW>
                end
            end
        end


        rhsArgTypes{end+1}=argType;%#ok<AGROW>
        rhsArgAccesses{end+1}=argAccess;%#ok<AGROW>
    end

    if~isempty(rhsArgDeclStmts)

        codeWriter.wCmt('Locally defined argument(s)');
        cellfun(@(aLine)codeWriter.wLine(aLine),rhsArgDeclStmts);
        codeWriter.wNewLine;
    end


    if~isempty(rhsArgTypes)
        inputTypesStr='inputTypes';
        codeWriter.wCmt('Array of Input Data Types');
        emitArrayDeclInit('Type',inputTypesStr,rhsArgTypes);
    else
        inputTypesStr='NULL';
    end


    if fcnInfo.RhsArgs.Numel>3

        inputArgStr='inputArgs';
        codeWriter.wCmt('Input argument(s)');
        emitArrayDeclInit('Value',inputArgStr,rhsArgAccesses);
        argList={inputArgStr,sprintf('%d',fcnInfo.RhsArgs.Numel)};
    else

        argList=rhsArgAccesses;
    end


    lhsArgStr='';
    codeWriter.wCmt('Output Data Type');
    if fcnInfo.LhsArgs.Numel==1
        argSpec=fcnInfo.LhsArgs.Items(1);
        dataSpec=argSpec.Data;


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'cgir');
        codeWriter.wLine('Type outputType = Type(%s);',apiInfo.TypeId);


        lhsArgStr=sprintf('output(%d)',argSpec.Data.Id-1);
    else

        codeWriter.wLine('Type outputType = Type::voidType();');
    end
    codeWriter.wNewLine;

    if~isempty(rhsArgExtraInitStmts)

        codeWriter.wCmt('Locally defined argument(s) initialization');
        cellfun(@(aLine)codeWriter.wLine(aLine),rhsArgExtraInitStmts);
        codeWriter.wNewLine;
    end


    headerFileName='NULL';
    if~isempty(this.LctSpecInfo.Specs.HeaderFiles)
        headerFileName=this.LctSpecInfo.Specs.HeaderFiles{1};
    end


    codeWriter.wCmt('Function object mapped to the external function');
    codeWriter.wLine('Function _%s_obj("%s", "%s", outputType, %s, %d);',...
    fcnInfo.Name,fcnInfo.Name,headerFileName,inputTypesStr,fcnInfo.RhsArgs.Numel);
    codeWriter.wNewLine;









    if~this.LctSpecInfo.Specs.Options.isMacro&&~this.LctSpecInfo.Specs.Options.isVolatile&&...
        (fcnInfo.LhsArgs.Numel==1)&&(hasOutputOnRhs==false)
        isPureStr='true';
    else
        isPureStr='false';
    end
    codeWriter.wLine('_%s_obj.setPure(%s);',fcnInfo.Name,isPureStr);
    codeWriter.wNewLine;


    codeWriter.wCmt('Invoke the function in the generated code');
    if~isempty(lhsArgStr)
        lhsArgStr=[lhsArgStr,' = '];
    end
    codeWriter.wLine('%s_%s_obj(%s);',lhsArgStr,fcnInfo.Name,strjoin(argList,', '));

    function emitArrayDeclInit(arrayType,arrayName,initList)
        codeWriter.wLine('%s %s[] = {',arrayType,arrayName);
        codeWriter.incIndent;
        for kk=1:numel(initList)-1
            codeWriter.wLine('%s,',initList{kk});
        end
        codeWriter.wLine('%s',initList{end});
        codeWriter.decIndent;
        codeWriter.wLine('};');
        codeWriter.wNewLine;
    end

    function[argType,argAccess,extraDeclStmts,extraInitStmts]=nGetTypeAndArgInfo(argSpec)




        dataKind=this.DataKind2ApiKindMap(argSpec.DataKind);





        extraDeclStmts={};
        extraInitStmts={};


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(argSpec.Data,'cgir');
        argType=sprintf('Type(%s)',apiInfo.TypeId);

        if argSpec.Data.IsComplex
            argType=sprintf('complex(%s)',argType);
        end

        if argSpec.Data.Width==1

            if~argSpec.PassedByValue
                argType=sprintf('pointerTo(%s)',argType);



                if strcmpi(dataKind,'input')||strcmp(dataKind,'param')



                    extraDeclStmts{end+1}=sprintf('Reference %s%d_tmp(createLocal(%s(%d).type()));',...
                    dataKind,argSpec.Data.Id-1,dataKind,argSpec.Data.Id-1);

                    extraInitStmts{end+1}=sprintf('%s%d_tmp = %s(%d);',...
                    dataKind,argSpec.Data.Id-1,dataKind,argSpec.Data.Id-1);

                    argAccess=sprintf('addressOf(%s%d_tmp)',dataKind,argSpec.Data.Id-1);

                elseif strcmpi(dataKind,'output')||strcmpi(dataKind,'dwork')


                    extraDeclStmts{end+1}=sprintf('Reference %s%d_tmp(%s(%d));',...
                    dataKind,argSpec.Data.Id-1,dataKind,argSpec.Data.Id-1);

                    argAccess=sprintf('addressOf(%s%d_tmp)',dataKind,argSpec.Data.Id-1);

                else
                    argAccess=sprintf('addressOf(%s(%d))',dataKind,argSpec.Data.Id-1);
                end
            else

                argType=sprintf('%s',argType);
                argAccess=sprintf('%s(%d)',dataKind,argSpec.Data.Id-1);
            end
        else

            hasDynSize=any(argSpec.Data.Dimensions==-1);

            if numel(argSpec.Data.Dimensions)<2

                if hasDynSize
                    argType=sprintf('vectorOf(%s, %s)',argType,apiInfo.Width);
                else
                    argType=sprintf('vectorOf(%s, %d)',argType,argSpec.Data.Width);
                end

            elseif numel(argSpec.Data.Dimensions)==2

                if hasDynSize
                    dim1Str=legacycode.lct.gen.ExprSFunCgEmitter.emitOneDim(this.LctSpecInfo,argSpec.Data,1);
                    dim2Str=legacycode.lct.gen.ExprSFunCgEmitter.emitOneDim(this.LctSpecInfo,argSpec.Data,2);
                    argType=sprintf('matrixOf(%s, %s, %s)',argType,dim1Str,dim2Str);

                else
                    argType=sprintf('matrixOf(%s, %d, %d)',argType,argSpec.Data.Dimensions(1),argSpec.Data.Dimensions(2));
                end
            else

                argType=sprintf('matrixOf(%s, dimsInfo_%s)',argType,argSpec.Data.Identifier);
            end














            if strcmpi(dataKind,'output')||strcmpi(dataKind,'dwork')


                extraDeclStmts{end+1}=sprintf('Reference %s%d_tmp(%s(%d));',...
                dataKind,argSpec.Data.Id-1,dataKind,argSpec.Data.Id-1);

                argAccess=sprintf('addressOf(%s%d_tmp)',dataKind,argSpec.Data.Id-1);
                argType=sprintf('pointerTo(%s)',strtrim(argType));
            else
                argAccess=sprintf('%s(%d)',dataKind,argSpec.Data.Id-1);
            end

        end
    end
end


