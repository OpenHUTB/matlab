function info=lct_pParseFcnSpec(info,fcnSpecType)






    narginchk(2,2);


    fcnSpec=info.Specs.([fcnSpecType,'FcnSpec']);


    if isempty(fcnSpec)
        return
    end






    argPattern=['\s*([a-zA-Z_0-9<>]*)\s+([yup]|work)(\d+)(\s*\[\s*[ a-z\(\)0-9\,]*\s*\]\s*){0,}|',...
'\s*(\w*)\s+(size)\(\s*([yup]|work)(\d+)\s*,\s*(\d+)\s*\)|'...
    ,'\s*(void)\s*(\*){1,2}\s*(work)(\d+)'];


    info.Fcns.(fcnSpecType).Expression=fcnSpec;
    info.Fcns.(fcnSpecType).IsSpecified=1;


    tokens=regexpi(fcnSpec,['\s*(',argPattern,')?\s*(=)?(.*)'],'tokens');
    lhsExpr=tokens{1}{1};
    eqExpr=tokens{1}{2};
    rhsExpr=tokens{1}{3};


    if(isempty(lhsExpr)&&~isempty(eqExpr))||(~isempty(lhsExpr)&&isempty(eqExpr))
        DAStudio.error('Simulink:tools:LCTErrorParseBadAssignement',fcnSpec);
    end


    info.Fcns.(fcnSpecType).LhsExpression=lhsExpr;
    if~isempty(lhsExpr)

        argInfo=iExtractArgInfo(fcnSpec,lhsExpr,argPattern);


        iVerifyArgument(lhsExpr,fcnSpec,fcnSpecType,argInfo);


        if~strcmp(argInfo.Type,'Output')||strcmp(argInfo.AccessType,'pointer')
            DAStudio.error('Simulink:tools:LCTErrorParseBadAssignement',fcnSpec);
        end


        lhsExprRem=regexprep(lhsExpr,argPattern,'','ignorecase');
        lhsExprRem=regexprep(lhsExprRem,'\s+','');
        if~isempty(lhsExprRem)
            DAStudio.error('Simulink:tools:LCTErrorParseBadAssignement',fcnSpec);
        end


        [info.DataTypes,dataTypeId]=legacycode.util.lct_pAddDataType(info.DataTypes,argInfo.DTName);
        if dataTypeId>info.DataTypes.NumSLBuiltInDataTypes
            info.DataTypes.DataType(dataTypeId).IsPartOfSpec=true;
        end


        argStruct=legacycode.util.lct_pInitStructure('FcnArgElement');
        argStruct.Identifier=argInfo.Identifier;
        argStruct.Type=argInfo.Type;
        argStruct.DataTypeId=dataTypeId;
        argStruct.DataId=argInfo.DataId;
        argStruct.AccessType=argInfo.AccessType;
        argStruct.Expression=lhsExpr;
        argStruct.IsComplex=argInfo.IsComplex;


        info=iAddArg(info,argStruct,'LhsArgs',fcnSpecType);


        info=iAddData(info,argStruct,argInfo.Dims,argInfo.DimsInfo);

    end


    info.Fcns.(fcnSpecType).RhsExpression=rhsExpr;
    tokens=regexpi(rhsExpr,['[,\(]\s*(',argPattern,')|(',argPattern,')\s*[,\)]'],'tokens');
    for ii=1:length(tokens)

        argInfo=iExtractArgInfo(fcnSpec,tokens{ii}{1},argPattern);


        iVerifyArgument(tokens{ii}{1},fcnSpec,fcnSpecType,argInfo);


        [info.DataTypes,dataTypeId]=legacycode.util.lct_pAddDataType(info.DataTypes,argInfo.DTName);
        if dataTypeId>info.DataTypes.NumSLBuiltInDataTypes
            info.DataTypes.DataType(dataTypeId).IsPartOfSpec=true;
        end


        argStruct=legacycode.util.lct_pInitStructure('FcnArgElement');
        argStruct.Identifier=argInfo.Identifier;
        argStruct.Type=argInfo.Type;
        argStruct.DataTypeId=dataTypeId;
        argStruct.DataId=argInfo.DataId;
        argStruct.AccessType=argInfo.AccessType;
        argStruct.Expression=tokens{ii}{1};
        argStruct.IsComplex=argInfo.IsComplex;



        if strcmp(argInfo.Type,'SizeArg')
            argStruct.DimsInfo=argInfo.DimsInfo;
        end


        info=iAddArg(info,argStruct,'RhsArgs',fcnSpecType);


        info=iAddData(info,argStruct,argInfo.Dims,argInfo.DimsInfo);

    end



    rhsExprRem=regexprep(rhsExpr,argPattern,'','ignorecase');


    rhsExprRem=regexprep(rhsExprRem,'void','','ignorecase');


    tokens=regexp(rhsExprRem,'[,\(]([\s*\w*])*|([\s*\w*])*[,\)]','tokens');
    for ii=1:length(tokens)
        badArg=strtrim(tokens{ii}{1});
        if~isempty(badArg)
            DAStudio.error('Simulink:tools:LCTErrorParseUnrecognizedToken',badArg,fcnSpec);
        end
    end


    rhsExprRem=regexprep(rhsExprRem,'\s*\w*\s*\(\s*(\s*,\s*)*\)\s*','','ignorecase');
    if~isempty(rhsExprRem)
        DAStudio.error('Simulink:tools:LCTErrorParseUnrecognizedToken',rhsExprRem,fcnSpec);
    end



    function argInfo=iExtractArgInfo(fcnSpec,expression,argPattern)




        tokens=regexpi(expression,argPattern,'tokens');


        isVoidPtr=false;

        switch lower(tokens{1}{2})
        case 'u'
            argInfo.Type='Input';

        case 'y'
            argInfo.Type='Output';

        case 'p'
            argInfo.Type='Parameter';

        case 'work'
            argInfo.Type='DWork';

        case 'size'
            argInfo.Type='SizeArg';

        case{'*','**'}
            argInfo.Type='DWork';
            isVoidPtr=true;

        otherwise


            DAStudio.error('Simulink:tools:LCTErrorParseUnrecognizedToken',expression,fcnSpec);
        end


        if isempty(tokens{1}{1})
            DAStudio.error('Simulink:tools:LCTErrorParseMissingDataType',expression,fcnSpec);
        end

        dtName=strtrim(tokens{1}{1});
        dtPattern='(complex)\s*(<)\s*(\w*)\s*(>)|(\w*)';
        dtTokens=regexpi(dtName,dtPattern,'tokens');

        argInfo.IsComplex=false;
        hasBadDTName=false;
        if length(dtTokens{1})==1
            argInfo.DTName=strtrim(dtTokens{1}{1});

        elseif length(dtTokens{1})==4
            argInfo.DTName=strtrim(dtTokens{1}{3});
            argInfo.IsComplex=true;

        else
            hasBadDTName=true;
        end

        if hasBadDTName
            DAStudio.error('Simulink:tools:LCTErrorParseMissingDataType',expression,fcnSpec);
        end

        if~strcmp(argInfo.Type,'SizeArg')&&(isVoidPtr==false)

            argInfo.DataId=sscanf(tokens{1}{3},'%d');
            if~isnumeric(argInfo.DataId)||(argInfo.DataId<1)
                DAStudio.error('Simulink:tools:LCTErrorParseBadDataId',expression,fcnSpec);
            end


            argInfo.Identifier=[lower(tokens{1}{2}),tokens{1}{3}];



            argInfo.Dims=-1;
            argInfo.DimsInfo.HasInfo=-1;
            argInfo.DimsInfo.DimInfo=struct('Type','','DataId',[],'DimRef',[]);
            argInfo.AccessType='direct';
            if isempty(tokens{1}{4})
                argInfo.Dims=1;
            else
                argInfo.AccessType='pointer';


                paramPattern='\[(\d*)\]|\[(size)\(([yup]|work)(\d+),(\d+)\)\]|\[(p)(\d+)\]';
                thisToken=strrep(tokens{1}{4},' ','');
                dimtokens=regexpi(thisToken,paramPattern,'tokens');



                err=regexprep(thisToken,paramPattern,'','ignorecase');
                if~isempty(err)
                    DAStudio.error('Simulink:tools:LCTErrorParseUnrecognizedToken',err,expression);
                end

                for jj=1:length(dimtokens)
                    jjDim=-1;
                    jjHasInfo=-1;
                    jjDimInfo=struct('Type','','DataId',[],'DimRef',[]);

                    if isempty(dimtokens{jj}{1})


                        if strcmp(argInfo.Type,'Output')||strcmp(argInfo.Type,'DWork')
                            DAStudio.error('Simulink:tools:LCTErrorParseBadOutputOrDWorkDim',...
                            expression,fcnSpec);
                        end

                    else
                        nbDimTokens=length(dimtokens{jj});
                        switch nbDimTokens
                        case 1

                            jjDim=sscanf(dimtokens{jj}{1},'%d');

                        case 2

                            jjHasInfo=1;
                            jjDimInfo.Type='Parameter';
                            jjDimInfo.DataId=sscanf(dimtokens{jj}{2},'%d');
                            jjDimInfo.DimRef=0;

                        case 4

                            jjHasInfo=1;
                            if strcmpi(dimtokens{jj}{2},'u')
                                jjDimInfo.Type='Input';
                            elseif strcmpi(dimtokens{jj}{2},'p')
                                jjDimInfo.Type='Parameter';
                            else
                                DAStudio.error('Simulink:tools:LCTErrorParseBadOutputOrDWorkDimForDynSize',...
                                expression,fcnSpec);
                            end
                            jjDimInfo.DataId=sscanf(dimtokens{jj}{3},'%d');
                            jjDimInfo.DimRef=sscanf(dimtokens{jj}{4},'%d');

                        otherwise

                        end


                        if nbDimTokens>1
                            if strcmp(argInfo.Type,'Parameter')
                                DAStudio.error('Simulink:tools:LCTErrorParseBadParameterDim',...
                                expression,fcnSpec);
                            end

                            if strcmp(argInfo.Type,'Input')&&strcmp(jjDimInfo.Type,'Input')
                                DAStudio.error('Simulink:tools:LCTErrorParseBadInputDim',...
                                expression,fcnSpec);
                            end
                        end
                    end

                    argInfo.Dims(jj)=jjDim;
                    argInfo.DimsInfo.HasInfo(jj)=jjHasInfo;
                    argInfo.DimsInfo.DimInfo(jj)=jjDimInfo;
                end
            end

        elseif(isVoidPtr==true)

            argInfo.DataId=sscanf(tokens{1}{4},'%d');
            if~isnumeric(argInfo.DataId)||(argInfo.DataId<1)
                DAStudio.error('Simulink:tools:LCTErrorParseBadDataId',expression,fcnSpec);
            end


            argInfo.Identifier=[lower(tokens{1}{3}),tokens{1}{4}];



            argInfo.Dims=1;
            argInfo.DimsInfo.HasInfo=-1;
            argInfo.DimsInfo.DimInfo=struct('Type','','DataId',[],'DimRef',[]);

            switch lower(tokens{1}{2})
            case '*'
                argInfo.AccessType='direct';

            case '**'
                argInfo.AccessType='pointer';

            otherwise

            end

        else

            argInfo.DataId=-1;



            dataId=sscanf(tokens{1}{4},'%d');
            if~isnumeric(dataId)||(dataId<1)
                DAStudio.error('Simulink:tools:LCTErrorParseBadDataId',expression,fcnSpec);
            end



            argInfo.Identifier=sprintf('%s%s_dim%s',tokens{1}{3},tokens{1}{4},tokens{1}{5});


            argInfo.AccessType='direct';


            argInfo.Dims=1;
            argInfo.DimsInfo.HasInfo=1;
            argInfo.DimsInfo.DimInfo=struct('Type','','DataId',[],'DimRef',[]);
            argInfo.DimsInfo.DimInfo.DataId=dataId;
            argInfo.DimsInfo.DimInfo.DimRef=sscanf(tokens{1}{5},'%d');

            switch lower(tokens{1}{3})
            case 'u'
                argInfo.DimsInfo.DimInfo.Type='Input';

            case 'y'
                argInfo.DimsInfo.DimInfo.Type='Output';

            case 'p'
                argInfo.DimsInfo.DimInfo.Type='Parameter';

            case 'work'
                argInfo.DimsInfo.DimInfo.Type='DWork';

            otherwise

            end

        end


        function info=iAddData(info,argStruct,argDims,argDimsInfo)



            if strcmp(argStruct.Type,'SizeArg')
                return
            end

            fieldName=[argStruct.Type,'s'];

            [bool,idx]=ismember(argStruct.DataId,info.(fieldName).Id);

            if bool==0
                data=legacycode.util.lct_pInitStructure('Data');
                data.Identifier=argStruct.Identifier;
                data.DataTypeId=argStruct.DataTypeId;
                data.Dimensions=argDims;
                data.IsComplex=argStruct.IsComplex;
                if all(argDims>=0)
                    data.Width=prod(argDims);
                else
                    data.Width=-1;
                end
                data.DimsInfo=argDimsInfo;

                info.(fieldName).Num=info.(fieldName).Num+1;

                info.(fieldName).Id=sort([info.(fieldName).Id,argStruct.DataId]);
                info.(fieldName).(argStruct.Type)(argStruct.DataId)=data;

            else
                data=info.(fieldName).(argStruct.Type)(idx);
                if~strcmp(data.Identifier,argStruct.Identifier)||...
                    (data.DataTypeId~=argStruct.DataTypeId)||...
                    (data.IsComplex~=argStruct.IsComplex)||...
                    ~isempty(setdiff(data.Dimensions,argDims))||...
                    ~isequal(data.DimsInfo,argDimsInfo)

                    DAStudio.error('Simulink:tools:LCTErrorParseDifferentDataSpec');
                end
            end



            function info=iAddArg(info,argStruct,argType,fcnSpecType)

                if~strcmp(argStruct.Type,'SizeArg')

                    for ii=1:info.Fcns.(fcnSpecType).LhsArgs.NumArgs
                        if strcmp(argStruct.Identifier,info.Fcns.(fcnSpecType).LhsArgs.Arg(ii).Identifier)
                            DAStudio.error('Simulink:tools:LCTErrorParseDuplicatedArgName');
                        end
                    end

                    for ii=1:info.Fcns.(fcnSpecType).RhsArgs.NumArgs
                        if strcmp(argStruct.Identifier,info.Fcns.(fcnSpecType).RhsArgs.Arg(ii).Identifier)
                            DAStudio.error('Simulink:tools:LCTErrorParseDuplicatedArgName');
                        end
                    end

                else
                    if argStruct.IsComplex
                        DAStudio.error('Simulink:tools:LCTErrorParseBadComplexSizeArg');
                    end









                    impArgIdx=strncmp('SizeArg',{info.Fcns.(fcnSpecType).(argType).Arg(:).Type},7);
                    allImpArgName={info.Fcns.(fcnSpecType).(argType).Arg(impArgIdx).Identifier};


                    thisArgName=argStruct.Identifier;
                    mangle='';
                    num=1;
                    while 1
                        newName=sprintf('%s%s',thisArgName,mangle);
                        bool=any(strcmp(newName,allImpArgName));
                        if bool==false

                            argStruct.Identifier=newName;
                            break
                        end
                        mangle=sprintf('_%d',num);
                        num=num+1;
                    end

                end


                NumArgs=info.Fcns.(fcnSpecType).(argType).NumArgs+1;
                info.Fcns.(fcnSpecType).(argType).NumArgs=NumArgs;
                info.Fcns.(fcnSpecType).(argType).Arg(NumArgs)=argStruct;



                function iVerifyArgument(expr,fcnSpec,fcnSpecType,argInfo)


                    if(length(argInfo.Dims)>2)
                        if argInfo.Dims(end)==1
                            DAStudio.error('Simulink:tools:LCTErrorParseBadTrailingDim',...
                            expr,fcnSpec);
                        end
                    end






                    idxDimsDynSize=find(argInfo.Dims==-1);
                    idxDimsNeg=find(argInfo.Dims<=0);
                    if~isempty(setxor(idxDimsDynSize,idxDimsNeg))
                        DAStudio.error('Simulink:tools:LCTErrorParseBadDimSpec',...
                        expr,fcnSpec);
                    end


                    if~(strcmp(argInfo.Type,'Parameter')||strcmp(argInfo.Type,'DWork'))&&...
                        ~strcmp(fcnSpecType,'Output')&&...
                        ~strcmp(argInfo.Type,'SizeArg')
                        DAStudio.error('Simulink:tools:LCTErrorParseBadDataAccessForMethod',...
                        fcnSpecType,expr,fcnSpec);
                    end





