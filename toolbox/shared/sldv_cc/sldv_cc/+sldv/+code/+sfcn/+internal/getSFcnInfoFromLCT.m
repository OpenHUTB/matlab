function sldvSFcnInfo=getSFcnInfoFromLCT(infoStruct)











    sldvSFcnInfo=sldv.code.sfcn.internal.StaticSFcnInfoWriter(infoStruct.Specs.Options.language);
    sldvSFcnInfo.DoMacroCheck=true;


    addVarDecls(sldvSFcnInfo.InputType,infoStruct,infoStruct.Inputs.Input,infoStruct.Inputs.Num,sldvSFcnInfo);
    addVarDecls(sldvSFcnInfo.OutputType,infoStruct,infoStruct.Outputs.Output,infoStruct.Outputs.Num,sldvSFcnInfo);
    addVarDecls(sldvSFcnInfo.ParameterType,infoStruct,infoStruct.Parameters.Parameter,infoStruct.Parameters.Num,sldvSFcnInfo);

    addDworks(infoStruct,infoStruct.DWorks.DWork,infoStruct.DWorks.Num,sldvSFcnInfo);


    if infoStruct.Specs.Options.isMacro
        sldvSFcnInfo.DoMacroCheck=false;



        addFcnSpec('InitializeConditions',infoStruct,sldvSFcnInfo,'mw_InitializeConditions_wrapper');
        addFcnSpec('Output',infoStruct,sldvSFcnInfo,'mw_Output_wrapper');
        addFcnSpec('Start',infoStruct,sldvSFcnInfo,'mw_Start_wrapper');
        addFcnSpec('Terminate',infoStruct,sldvSFcnInfo,'mw_Terminate_wrapper');
    else
        addFcnSpec('InitializeConditions',infoStruct,sldvSFcnInfo);
        addFcnSpec('Output',infoStruct,sldvSFcnInfo);
        addFcnSpec('Start',infoStruct,sldvSFcnInfo);
        addFcnSpec('Terminate',infoStruct,sldvSFcnInfo);
    end

    sldvSFcnInfo.Transpose2DMatrix=infoStruct.Specs.Options.convertNDArrayToRowMajor;


    mainBody=sprintf('#include <tmwtypes.h>\n#include <string.h>\n\n')';

    headers=infoStruct.Specs.HeaderFiles;
    if~isempty(infoStruct.DataTypes.Items)

        typeHeaders={infoStruct.DataTypes.Items.HeaderFile};
        typeHeaders=typeHeaders(~strcmp('',typeHeaders));

        if~isempty(typeHeaders)
            headers=unique([headers(:);typeHeaders(:)],'stable');
        end
    end


    for inc=1:numel(headers)
        mainBody=sprintf('%s#include "%s"\n',mainBody,headers{inc});
    end

    if infoStruct.Specs.Options.isMacro
        initWrapper=generateMacroWrapper(infoStruct,'InitializeConditions','mw_InitializeConditions_wrapper');
        outputWrapper=generateMacroWrapper(infoStruct,'Output','mw_Output_wrapper');
        startWrapper=generateMacroWrapper(infoStruct,'Start','mw_Start_wrapper');
        terminateWrapper=generateMacroWrapper(infoStruct,'Terminate','mw_Terminate_wrapper');

        mainBody=sprintf('%s%s%s%s%s',mainBody,initWrapper,outputWrapper,startWrapper,terminateWrapper);
    end
    sldvSFcnInfo.setMainFileBody(mainBody);


    function addVarDecls(varCategory,infoStruct,varInfos,numElements,db)
        for index=1:numElements
            v=varInfos(index);
            varName=v.Identifier;
            dataType=infoStruct.DataTypes.DataType(v.DataTypeId);

            if(dataType.Id~=dataType.IdAliasedThruTo)&&(dataType.IdAliasedTo>0)
                varType=dataType.Name;
            else
                dataType=infoStruct.DataTypes.DataType(dataType.IdAliasedThruTo);
                varType=dataType.Name;
            end

            if v.IsComplex
                varType=sprintf('c%s',varType);
            end

            db.addVarDecl(varCategory,varName,varType,index);
        end


        function addDworks(infoStruct,varInfos,numElements,db)
            dworkIndex=1;
            for index=1:numElements
                v=varInfos(index);
                varName=v.Identifier;
                dataType=infoStruct.DataTypes.DataType(v.DataTypeId);

                if(dataType.Id~=dataType.IdAliasedThruTo)&&(dataType.IdAliasedTo>0)
                    varType=dataType.Name;
                else
                    dataType=infoStruct.DataTypes.DataType(dataType.IdAliasedThruTo);
                    varType=dataType.Name;
                end

                if v.IsComplex
                    varType=sprintf('c%s',varType);
                end

                if strcmp(varType,'void')
                    varIndex=-1;
                else
                    varIndex=dworkIndex;
                    dworkIndex=dworkIndex+1;
                end

                db.addVarDecl(db.DworkType,varName,varType,varIndex);
            end


            function res=isVarScalar(infoStruct,arg)
                if strcmp(arg.Type,'SizeArg')
                    res=true;
                else
                    data=legacycode.util.lct_pGetDataFromArg(infoStruct,arg);
                    res=data.Width==1;
                end


                function cType=getCType(infoStruct,arg)

                    hasTypeProp=isfield(arg,'Type')||isprop(arg,'Type');
                    if hasTypeProp&&strcmp(arg.Type,'SizeArg')
                        cType='int32_T';
                    else
                        name=infoStruct.DataTypes.DataType(arg.DataTypeId).Name;
                        if strcmp(arg.AccessType,'pointer')
                            cType=[name,'*'];
                        else
                            cType=name;
                        end

                        if(isfield(arg,'Data')||isprop(arg,'Data'))&&arg.Data.IsComplex
                            cType=['c',cType];
                        end
                    end
                    if(hasTypeProp&&any(strcmp(arg.Type,{'Input','Parameter'})))
                        cType=['const ',cType];
                    end


                    function macroWrapper=generateMacroWrapper(infoStruct,fcnName,wrapperName)
                        macroWrapper='';

                        fcnInfo=infoStruct.Fcns.(fcnName);
                        if fcnInfo.IsSpecified
                            if fcnInfo.LhsArgs.NumArgs==1
                                outType=getCType(infoStruct,fcnInfo.LhsArgs.Arg);
                            else
                                outType='void';
                            end

                            numArgs=fcnInfo.RhsArgs.NumArgs;
                            args=cell(1,numArgs);
                            for ii=1:numArgs
                                argType=getCType(infoStruct,fcnInfo.RhsArgs.Arg(ii));
                                args{ii}=sprintf('%s p%d',argType,ii);
                            end
                            macroWrapper=sprintf('%s%s %s(%s)\n{\n',macroWrapper,outType,wrapperName,strjoin(args,', '));



                            if fcnInfo.LhsArgs.NumArgs==1
                                returnStr='return ';
                            else
                                returnStr='';
                            end
                            params=cellfun(@(x)sprintf('p%d',x),num2cell(1:numArgs),'UniformOutput',false);
                            paramStr=strjoin(params,', ');
                            calledName=getCalledName(fcnInfo);

                            macroWrapper=sprintf('%s    %s%s(%s);\n}\n\n',macroWrapper,returnStr,calledName,paramStr);
                        end


                        function calledName=getCalledName(fcnInfo)

                            if legacycode.lct.util.feature('newImpl')
                                calledName=fcnInfo.Name;
                            else
                                token=regexpi(fcnInfo.RhsExpression,'(\w*)\s*\(','tokens');
                                calledName=token{1}{1};
                            end


                            function addFcnSpec(fcnName,infoStruct,db,calledName)
                                if nargin<4
                                    calledName='';
                                end
                                fcnInfo=infoStruct.Fcns.(fcnName);
                                if fcnInfo.IsSpecified



                                    if isempty(calledName)
                                        calledName=getCalledName(fcnInfo);
                                    end

                                    db.addFunctionSpec(fcnName,calledName);


                                    if fcnInfo.LhsArgs.NumArgs==1
                                        thisArg=fcnInfo.LhsArgs.Arg(1);
                                        thisName=thisArg.Identifier;
                                        isScalar=isVarScalar(infoStruct,thisArg);
                                        accessType=thisArg.AccessType;
                                        argType=thisArg.Type;

                                        db.addFunctionArg(fcnName,db.LhsParam,1,thisName,argType,accessType,isScalar);
                                    end


                                    for ii=1:fcnInfo.RhsArgs.NumArgs

                                        thisArg=fcnInfo.RhsArgs.Arg(ii);
                                        thisName=thisArg.Identifier;
                                        isScalar=isVarScalar(infoStruct,thisArg);
                                        accessType=thisArg.AccessType;
                                        argType=thisArg.Type;

                                        if strcmp(argType,'SizeArg')
                                            if legacycode.lct.util.feature('newImpl')
                                                thisName=thisArg.Data.DimsInfo.Expr;
                                                argType='ExprArg';
                                            else
                                                dimsInfo=thisArg.DimsInfo;
                                                if dimsInfo.HasInfo

                                                    dimInfo=dimsInfo.DimInfo(1);

                                                    dimVar='';
                                                    if strcmpi(dimInfo.Type,'Input')
                                                        dimVar=infoStruct.Inputs.Input(dimInfo.DataId).Identifier;
                                                    elseif strcmpi(dimInfo.Type,'Parameter')
                                                        dimVar=infoStruct.Parameters.Parameter(dimInfo.DataId).Identifier;
                                                    end

                                                    if~isempty(dimVar)


                                                        thisName=sprintf('size(%s, %d)',dimVar,dimInfo.DimRef);
                                                    end
                                                end
                                            end
                                        end

                                        db.addFunctionArg(fcnName,db.RhsParam,ii,thisName,argType,accessType,isScalar);
                                    end
                                end


