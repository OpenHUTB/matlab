function[wrappersInfo,preIncludeFile,simStructStubs]=generateSfcnWrappers(sfcnName,...
    sInfo,...
    resultArray,...
    options)












































    wrappersInfo=struct([]);
    preIncludeFile='';
    simStructStubs=struct([]);

    if~isfield(options,'testComponent')
        testcomp=[];
    else
        testcomp=options.testComponent;
    end

    if~isfield(sInfo.Functions,'Output')
        sldv.code.internal.showMessage(testcomp,'error','sldv_sfcn:sldv_sfcn:noOutputFunctionError',sfcnName);
        return
    end

    if isfield(options,'MainFile')
        mainFile=options.MainFile;
    else
        mainFile=sInfo.MainFile;
    end

    if isfield(options,'GeneratePsInputs')
        generatePsInputs=options.GeneratePsInputs;
    else
        generatePsInputs=true;
    end

    if isfield(options,'SimStructPrefix')
        ssPrefix=options.SimStructPrefix;
    else
        ssPrefix='';
    end

    if isfield(options,'VarPrefix')
        varPrefix=options.VarPrefix;
    else
        varPrefix='';
    end

    if isfield(options,'FcnPrefix')
        fcnPrefix=options.FcnPrefix;
    else
        fcnPrefix='';
    end


    simStructOptions=struct('GenerateAsserts',false,...
    'FunctionWrappers',false,...
    'UseInstanceVar',true);
    if isfield(options,'GenerateAsserts')
        simStructOptions.GenerateAsserts=options.GenerateAsserts;
    end

    if isfield(options,'FunctionWrappers')
        simStructOptions.FunctionWrappers=options.FunctionWrappers;
    end

    if isfield(options,'GenerateCodeInformation')




        generateCodeInfo=options.GenerateCodeInformation;
    else
        generateCodeInfo=false;
    end

    if isempty(mainFile)
        sldv.code.internal.showMessage(testcomp,'error','sldv_sfcn:sldv_sfcn:incompleteSFunctionError',sfcnName);
        return
    end

    for instance=resultArray
        instance.createIRMapping();
    end

    writer=sldv.code.internal.CWriter(mainFile,'at');


    writer.print('#ifdef __cplusplus\nextern "C" {\n#endif\n');


    count=numel(resultArray);
    wrappersInfo(count).Start='';
    wrappersInfo(count).InitializeConditions='';
    wrappersInfo(count).Output='';
    wrappersInfo(count).Terminate='';
    wrappersInfo(count).Update='';
    wrappersInfo(count).Enable='';
    wrappersInfo(count).Disable='';
    wrappersInfo(count).ExtraInit='';
    wrappersInfo(count).PsInputs='';
    wrappersInfo(count).PsInit='';
    wrappersInfo(count).InputVars='';
    wrappersInfo(count).OutputVars='';
    wrappersInfo(count).DWorkVars='';
    wrappersInfo(count).ParameterVars='';
    wrappersInfo(count).DialogParameterVars='';
    wrappersInfo(count).CodeInformation=containers.Map('KeyType','char','ValueType','any');


    if~isfield(sInfo,'DialogParameters')
        sInfo.DialogParameters=struct([]);
    end
    allCompletedInfos(1:count)=sInfo;

    hasSimStructs=~isempty(sInfo.SimStructs);
    nameGenerator=sldv.code.sfcn.internal.CNameGenerator(sfcnName,sInfo,ssPrefix,varPrefix,fcnPrefix);
    if count<2
        nameGenerator.SingleInstance=true;
    end

    varNamesInfo=struct('InstanceVar',nameGenerator.varName('instanceId'),...
    'IndexVar',nameGenerator.varName('idx'),...
    'VarsMacro','SLDV_VARS_DECL');

    simStructOptions.UseInstanceVar=hasSimStructs&&(~simStructOptions.FunctionWrappers||count>1);
    if hasSimStructs
        if simStructOptions.UseInstanceVar
            writer.print('\n\nint_T %s;\n',varNamesInfo.InstanceVar);
        end

        if~simStructOptions.FunctionWrappers
            writer.print('int_T %s;\n\n',varNamesInfo.IndexVar);
        end
    end


    for infoIndex=1:count
        sldvInfo=resultArray(infoIndex);

        completedInfo=completeSimStructInfo(sInfo,sldvInfo);
        allCompletedInfos(infoIndex)=completedInfo;

        instanceName=get_encoded_instance_name(infoIndex);
        if generateCodeInfo
            instanceFullPath=Simulink.ID.getFullName(sldvInfo.SID);
            instancePathStart=strfind(instanceFullPath,'/');
            if isempty(instancePathStart)
                instancePathStart=1;
            end

            instanceDesc=sprintf('%d (''<Root>%s'')',infoIndex,...
            instanceFullPath(instancePathStart:end));
        else
            instanceDesc=sprintf('%d',infoIndex);
        end
        writer.print('/*** S-Function instance %s ***/\n\n',instanceDesc);

        variableNames=generateVariableNames(completedInfo,nameGenerator,instanceName);

        wInfo=struct('Start','',...
        'InitializeConditions','',...
        'Output','',...
        'Terminate','',...
        'Update','',...
        'Enable','',...
        'Disable','',...
        'ExtraInit','',...
        'PsInputs','',...
        'PsInit','',...
        'InputVars','',...
        'OutputVars','',...
        'DWorkVars','',...
        'ParameterVars','',...
        'DialogParameterVars','',...
        'CodeInformation',containers.Map('KeyType','char','ValueType','any'));


        numInputs=numel(sldvInfo.InputPortInfo);
        wInfo.InputVars=cell(numInputs,1);
        for kk=1:numInputs
            originalName=completedInfo.Inputs(kk).Name;
            inputName=variableNames(originalName);
            inputDims=sldvInfo.InputPortInfo(kk).Dim;

            generateVarDeclaration(writer,...
            completedInfo.Inputs(kk),...
            inputDims,...
            inputName,'',...
            completedInfo.Transpose2DMatrix...
            );
            sldvInfo.IRMapping.addInputName(inputName);
            wInfo.InputVars{kk}=inputName;
            if hasSimStructs
                generateDimsVar(writer,...
                inputDims,...
                inputName,...
                'int_T');
            end
            if generateCodeInfo
                wInfo.CodeInformation(inputName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:inputPortCodeInformation',kk,sldvInfo.SID);
            end
        end


        numParams=numel(sldvInfo.ParameterPortInfo);
        wInfo.ParameterVars=cell(numParams,1);
        for kk=1:numParams
            originalName=completedInfo.Parameters(kk).Name;
            paramName=variableNames(originalName);

            paramDims=sldvInfo.ParameterPortInfo(kk).Dim;

            if sldvInfo.ParameterPortInfo(kk).HasValue&&...
                canWriteValue(sldvInfo.ParameterPortInfo(kk).Value)
                paramValue=sldvInfo.ParameterPortInfo(kk).Value;

                generateVarDeclaration(writer,...
                completedInfo.Parameters(kk),...
                paramDims,...
                paramName,'const',...
                paramValue,...
                completedInfo.Transpose2DMatrix...
                );
            else
                generateVarDeclaration(writer,...
                completedInfo.Parameters(kk),...
                paramDims,...
                paramName,'',...
                completedInfo.Transpose2DMatrix...
                );
            end

            if hasSimStructs
                generateRunTimeParamInfo(writer,...
                paramDims,...
                paramName);
            end

            sldvInfo.IRMapping.addParameterName(paramName);
            wInfo.ParameterVars{kk}=paramName;
            if generateCodeInfo
                wInfo.CodeInformation(paramName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:runtimeParameterCodeInformation',kk,...
                sldvInfo.SID);
            end
        end


        numDialogParameters=numel(sldvInfo.DialogParameterInfo);
        wInfo.DialogParameterVars=cell(numDialogParameters,1);
        for kk=1:numDialogParameters
            originalName=completedInfo.DialogParameters(kk).Name;
            paramName=variableNames(originalName);

            paramDims=sldvInfo.DialogParameterInfo(kk).Dim;
            paramType=sldvInfo.DialogParameterInfo(kk).Type;

            if isempty(paramType)



                writer.print('extern char* %s;\n',paramName);
            elseif sldvInfo.DialogParameterInfo(kk).HasValue&&...
                canWriteValue(sldvInfo.DialogParameterInfo(kk).Value)
                paramValue=sldvInfo.DialogParameterInfo(kk).Value;

                generateVarDeclaration(writer,...
                completedInfo.DialogParameters(kk),...
                paramDims,...
                paramName,'const',...
                paramValue,...
                completedInfo.Transpose2DMatrix...
                );
            else
                generateVarDeclaration(writer,...
                completedInfo.DialogParameters(kk),...
                paramDims,...
                paramName,'',...
                completedInfo.Transpose2DMatrix...
                );
            end

            if hasSimStructs
                generateDimsVar(writer,...
                paramDims,...
                paramName,...
                'mwSize');
            end
            wInfo.DialogParameterVars{kk}=paramName;
            if generateCodeInfo
                wInfo.CodeInformation(paramName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:dialogParameterCodeInformation',kk,...
                sldvInfo.SID);
            end
        end


        numDWorks=numel(completedInfo.DWorks);
        wInfo.DWorkVars=cell(numDWorks,1);
        for kk=1:numDWorks
            sDwork=completedInfo.DWorks(kk);
            varIndex=sDwork.VarIndex;
            originalName=sDwork.Name;
            dworkName=nameGenerator.varName(originalName,instanceName);
            if varIndex>0&&varIndex<=numel(sldvInfo.DWorkInfo)

                iDWork=sldvInfo.DWorkInfo(varIndex);

                generateVarDeclaration(writer,...
                sDwork,...
                iDWork.Dim,...
                dworkName,'',...
                completedInfo.Transpose2DMatrix...
                );
            else


                writer.print('extern char* %s;\n',...
                nameGenerator.varName(originalName,instanceName));
            end
            sldvInfo.IRMapping.addDworkName(dworkName);
            wInfo.DWorkVars{kk}=dworkName;
            if generateCodeInfo
                wInfo.CodeInformation(dworkName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:dworkCodeInformation',kk,sldvInfo.SID);
            end
        end


        numOutputPorts=numel(sldvInfo.OutputPortInfo);
        wInfo.OutputVars=cell(numOutputPorts,1);
        for kk=1:numOutputPorts
            originalName=completedInfo.Outputs(kk).Name;
            outputName=variableNames(originalName);
            outputDims=sldvInfo.OutputPortInfo(kk).Dim;

            generateVarDeclaration(writer,...
            completedInfo.Outputs(kk),...
            outputDims,...
            outputName,'',...
            completedInfo.Transpose2DMatrix...
            );
            sldvInfo.IRMapping.addOutputName(outputName);
            wInfo.OutputVars{kk}=outputName;
            if hasSimStructs
                generateDimsVar(writer,...
                outputDims,...
                outputName,...
                'int_T');
            end
            if generateCodeInfo
                wInfo.CodeInformation(outputName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:outputPortCodeInformation',kk,sldvInfo.SID);
            end
        end


        for kk=1:numel(sldvInfo.DiscStateInfo)
            originalName=completedInfo.DiscreteStates(kk).Name;
            discName=variableNames(originalName);
            discDims=sldvInfo.DiscStateInfo(kk).Dim;
            discValue=sldvInfo.DiscStateInfo(kk).Value;

            generateVarDeclaration(writer,...
            completedInfo.DiscreteStates(kk),...
            discDims,...
            discName,'',...
            discValue,...
            completedInfo.Transpose2DMatrix);
            if generateCodeInfo
                wInfo.CodeInformation(discName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:discreteStateCodeInformation',kk,sldvInfo.SID);
            end
        end


        for kk=1:numel(completedInfo.SimStructs)
            simStructName=variableNames(completedInfo.SimStructs(kk).Name);
            simStructType=completedInfo.SimStructs(kk).DataType;
            if strcmp(simStructType,'SimStruct')


                writer.print('extern %s * const %s;\n',simStructType,simStructName);
            else
                writer.print('%s %s;\n',simStructType,simStructName);
            end
            if generateCodeInfo
                wInfo.CodeInformation(simStructName)=generateCodeInformation(...
                'sldv_sfcn:sldv_sfcn:simStructInstanceCodeInformation',kk,sldvInfo.SID);
            end
        end


        fcnNames={'Start','InitializeConditions','Output','Terminate','Update','Enable','Disable'};
        for kk=1:numel(fcnNames)
            currentFunction=fcnNames{kk};
            if isfield(completedInfo.Functions,currentFunction)
                generatedName=nameGenerator.functionName(currentFunction,instanceName);
                sldvInfo.IRMapping.setFunctionName(currentFunction,generatedName);

                wInfo.(currentFunction)=generatedName;


                writer.beginBlock('\n\nvoid %s(void) {',generatedName);

                if simStructOptions.UseInstanceVar
                    writer.print('\n%s = %d;',varNamesInfo.InstanceVar,infoIndex);
                end
                writer.print('\n%s;',generateFunctionBody(completedInfo.Functions.(currentFunction),...
                variableNames,...
                completedInfo,sldvInfo));
                writer.endBlock('\n}\n\n');
                if generateCodeInfo
                    wInfo.CodeInformation(generatedName)=generateCodeInformation(...
                    'sldv_sfcn:sldv_sfcn:functionCodeInformation',currentFunction,sldvInfo.SID,'function');
                end
            end
        end



        if hasSimStructs
            wInfo.ExtraInit=nameGenerator.functionName('init_globals',instanceName);
            sldvInfo.IRMapping.setFunctionName('ExtraInit',wInfo.ExtraInit);

            writer.beginBlock('\nvoid %s(void) {',wInfo.ExtraInit);


            generateSimStructExtraInit(writer,sldvInfo,completedInfo,variableNames);
            writer.endBlock('\n}\n\n');
        end


        if generatePsInputs
            dummyFcnName=declarePointerAccessFunction(writer,'__mw__dummy_pointer_access',nameGenerator,instanceName);


            if numel(sldvInfo.InputPortInfo)>0

                wInfo.PsInputs=nameGenerator.functionName('ps_inputs',instanceName);
                writer.beginBlock('\nvoid %s(void) {',wInfo.PsInputs);
                callPointerAccessFunction(writer,dummyFcnName,...
                {completedInfo.Inputs.Name},variableNames);


                generateMemSetZero(writer,sldvInfo.OutputPortInfo,completedInfo.Outputs,variableNames);
                writer.endBlock('\n}\n\n');
            end




            wInfo.PsInit=nameGenerator.functionName('ps_inits',instanceName);
            writer.beginBlock('\nvoid %s(void) {',wInfo.PsInit);


            generateMemSetZero(writer,sldvInfo.InputPortInfo,completedInfo.Inputs,variableNames);



            for kk=1:numel(sldvInfo.ParameterPortInfo)
                if~sldvInfo.ParameterPortInfo(kk).HasValue||...
                    ~canWriteValue(sldvInfo.ParameterPortInfo(kk).Value)
                    callPointerAccessFunction(writer,dummyFcnName,...
                    {completedInfo.Parameters(kk).Name},variableNames);
                end
            end

            for kk=1:numel(sldvInfo.DialogParameterInfo)
                if~sldvInfo.DialogParameterInfo(kk).HasValue||...
                    ~canWriteValue(sldvInfo.DialogParameterInfo(kk).Value)
                    callPointerAccessFunction(writer,dummyFcnName,...
                    {completedInfo.DialogParameters(kk).Name},variableNames);
                end
            end

            if hasSimStructs

                generateSimStructInit(writer,sldvInfo,completedInfo,variableNames);
            end
            writer.endBlock('\n}\n\n');
        end

        wrappersInfo(infoIndex)=wInfo;
        writer.print('\n\n');
    end


    if hasSimStructs
        typeInfo=generateTypeInfo(resultArray);

        simStructStubs=generateSimStructFunctions(writer,nameGenerator,allCompletedInfos,resultArray,varNamesInfo,simStructOptions,typeInfo);
        generateFixedPointStubs(writer,typeInfo);
        preIncludeFile=generatePreInclude(mainFile,nameGenerator,allCompletedInfos,resultArray,varNamesInfo,simStructStubs,simStructOptions);
    end

    writer.print('#ifdef __cplusplus\n}\n#endif\n');
    writer.print('\n\n');


    function fullName=declarePointerAccessFunction(writer,functionName,nameGenerator,instanceName)
        fullName=nameGenerator.functionName(functionName,instanceName);
        writer.print('\n\nextern void %s(void *);',fullName);


        function callPointerAccessFunction(writer,fullName,parameters,variableNames)
            if numel(parameters)>0
                for kk=1:numel(parameters)
                    param=parameters{kk};
                    varName=variableNames(param);
                    writer.print('\n%s(&%s);',fullName,varName);
                end
            end


            function generateVarDeclaration(writer,sInfo,varDims,name,qualifier,...
                initValue,transpose2DMatrix)

                portWidth=prod(varDims);

                if isempty(qualifier)
                    writer.print('%s %s',sInfo.DataType,name);
                else
                    writer.print('%s %s %s',qualifier,sInfo.DataType,name);
                end
                if portWidth>1
                    writer.print('[%d]',portWidth);
                end

                if nargin>=7&&canWriteValue(initValue)

                    writer.print(' = ');
                    cvalue=getValueString(initValue,transpose2DMatrix);
                    writer.print('%s',cvalue);
                end

                writer.print(';\n');


                function generateMemSetZero(writer,portInfos,completedInfo,variableNames)
                    for ii=1:numel(portInfos)

                        originalName=completedInfo(ii).Name;
                        inputName=variableNames(originalName);
                        inputDims=portInfos(ii).Dim;

                        if prod(inputDims)>1
                            arraySuffix='[0]';
                        else
                            arraySuffix='';
                        end

                        writer.print('\nmemset(&%s%s, 0, sizeof(%s));',inputName,arraySuffix,inputName);
                    end


                    function ssParamRecName=getRunTimeParamRecName(name)
                        ssParamRecName=[name,'___ssParamRec'];


                        function dimsArrayName=getDimsArrayVarName(name)
                            dimsArrayName=[name,'___dims'];


                            function generateDimsVar(writer,varDims,name,type)
                                dimsArrayName=getDimsArrayVarName(name);
                                dimsStr=arrayfun(@(x)sprintf('%d',x),varDims,'UniformOutput',false);
                                dimsStr=strjoin(dimsStr,', ');
                                writer.print('%s %s[%d] = { %s };\n',type,dimsArrayName,numel(varDims),dimsStr);


                                function generateRunTimeParamInfo(writer,varDims,name)
                                    generateDimsVar(writer,varDims,name,'int_T');
                                    ssParamRecName=getRunTimeParamRecName(name);
                                    writer.print('ssParamRec %s;\n',ssParamRecName);


                                    function generateSimStructInit(writer,sldvInfo,completedInfo,variableNames)
                                        for kk=1:numel(sldvInfo.ParameterPortInfo)
                                            originalName=completedInfo.Parameters(kk).Name;
                                            paramName=variableNames(originalName);

                                            ssParamRecName=getRunTimeParamRecName(paramName);

                                            writer.print('\nmemset(&%s, 0, sizeof(%s));',ssParamRecName,ssParamRecName);
                                        end


                                        function generateSimStructExtraInit(writer,sldvInfo,completedInfo,variableNames)
                                            for kk=1:numel(sldvInfo.ParameterPortInfo)
                                                originalName=completedInfo.Parameters(kk).Name;
                                                paramName=variableNames(originalName);
                                                paramDims=sldvInfo.ParameterPortInfo(kk).Dim;

                                                ssParamRecName=getRunTimeParamRecName(paramName);

                                                writer.print('\n%s.nDimensions = %d;',ssParamRecName,numel(paramDims));
                                                writer.print('\n%s.dimensions = %s;',ssParamRecName,[paramName,'___dims']);
                                                if prod(paramDims)>1
                                                    arraySuffix='[0]';
                                                else
                                                    arraySuffix='';
                                                end
                                                writer.print('\n%s.data = &%s%s;',ssParamRecName,paramName,arraySuffix);
                                            end


                                            function canWrite=canWriteValue(value)
                                                canWrite=~isempty(value)&&isnumeric(value)&&isreal(value)...
                                                &&(isfloat(value)||isinteger(value));


                                                function valueStr=getValueString(value,transpose2D)
                                                    dims=size(value);
                                                    if isfloat(value)
                                                        strformat='%f';
                                                    else
                                                        strformat='%d';
                                                    end
                                                    if prod(dims)>1
                                                        isFirst=true;
                                                        valueStr='{ ';
                                                        if transpose2D&&numel(dims)==2&&sum(dims>1)==2
                                                            tmp=value';
                                                            printedValues=tmp(:);
                                                        else
                                                            printedValues=value(:);
                                                        end

                                                        for v=printedValues'
                                                            if isFirst
                                                                currentFormat=['%s',strformat];
                                                                isFirst=false;
                                                            else
                                                                currentFormat=['%s, ',strformat];

                                                            end
                                                            valueStr=sprintf(currentFormat,valueStr,v);
                                                        end
                                                        valueStr=sprintf('%s }',valueStr);
                                                    else
                                                        valueStr=sprintf(strformat,value);
                                                    end




                                                    function isScalar=isScalarArg(sInfo,sldvInfo,argInfo)


                                                        dims=getVariableDimensions(sInfo,sldvInfo,argInfo.Identifier);
                                                        if isempty(dims)
                                                            isScalar=argInfo.IsScalar;
                                                        else
                                                            isScalar=prod(dims)==1;
                                                        end


                                                        function protoStr=generateFunctionBody(sfunctionSpec,...
                                                            variableNames,...
                                                            sInfo,...
                                                            sldvInfo)
                                                            protoStr=sfunctionSpec.Called;

                                                            if numel(sfunctionSpec.LhsArgs)==1
                                                                lhsVar=variableNames(sfunctionSpec.LhsArgs.Identifier);
                                                                prefix='';

                                                                isScalar=isScalarArg(sInfo,sldvInfo,sfunctionSpec.LhsArgs);
                                                                if strcmpi(sfunctionSpec.LhsArgs.AccessType,'pointer')&&isScalar
                                                                    prefix='&';
                                                                end

                                                                protoStr=sprintf('%s%s = %s',prefix,lhsVar,protoStr);
                                                            end

                                                            protoStr=sprintf('%s(',protoStr);
                                                            sep=' ';
                                                            for ii=1:numel(sfunctionSpec.RhsArgs)
                                                                varInfo=sfunctionSpec.RhsArgs(ii);

                                                                prefix='';
                                                                if any(strcmpi(varInfo.ArgType,{'SizeArg','ExprArg'}))


                                                                    rhsVar=getSize(varInfo.Identifier,sInfo,sldvInfo,variableNames,varInfo.ArgType);
                                                                else
                                                                    rhsVar=variableNames(varInfo.Identifier);

                                                                    isScalar=isScalarArg(sInfo,sldvInfo,varInfo);
                                                                    if strcmpi(varInfo.AccessType,'pointer')&&isScalar
                                                                        prefix='&';
                                                                    end
                                                                end


                                                                protoStr=sprintf('%s%s%s%s',protoStr,sep,prefix,rhsVar);
                                                                sep=', ';
                                                            end
                                                            protoStr=sprintf('%s)',protoStr);


                                                            function sizeValue=getSize(sizeExpr,sInfo,sldvInfo,variableNames,argType)

                                                                sizeValue='';

                                                                if strcmpi(argType,'ExprArg')

                                                                    exprObj=legacycode.lct.spec.ExprVisitor(sizeExpr);
                                                                    exprInfo=exprObj.getExprInfo();


                                                                    newExpr=sizeExpr;
                                                                    pValIdx=[];
                                                                    for ii=1:numel(exprInfo)
                                                                        switch exprInfo(ii).Kind
                                                                        case 'n'

                                                                            sizeValue=getVariableSize(sInfo,sldvInfo,exprInfo(ii).Txt,0);
                                                                            pat=sprintf('numel\\s*\\(\\s*%s\\s*\\)',exprInfo(ii).Txt);
                                                                            newExpr=regexprep(newExpr,pat,sizeValue,'IgnoreCase');

                                                                        case 's'

                                                                            sizeValue=getVariableSize(sInfo,sldvInfo,exprInfo(ii).Txt,exprInfo(ii).Val);
                                                                            pat=sprintf('size\\s*\\(\\s*%s\\s*,\\s*%d\\s*\\)',exprInfo(ii).Txt,exprInfo(ii).Val);
                                                                            newExpr=regexprep(newExpr,pat,sizeValue,'IgnoreCase');

                                                                        case 'v'

                                                                            pValIdx=[pValIdx,ii];%#ok<AGROW>
                                                                        end
                                                                    end


                                                                    canEvaluateExpr=true;
                                                                    for ii=pValIdx
                                                                        pExprInfo=exprInfo(ii);
                                                                        if sldvInfo.ParameterPortInfo(pExprInfo.Id).HasValue&&...
                                                                            canWriteValue(sldvInfo.ParameterPortInfo(pExprInfo.Id).Value)

                                                                            pValue=sprintf('%g',sldvInfo.ParameterPortInfo(pExprInfo.Id).Value(1));
                                                                        else


                                                                            pValue=variableNames(pExprInfo.Txt);
                                                                            canEvaluateExpr=false;
                                                                        end
                                                                        newExpr=regexprep(newExpr,pExprInfo.Txt,pValue,'IgnoreCase');
                                                                    end


                                                                    if canEvaluateExpr
                                                                        sizeValue=sprintf('%g',eval(newExpr));
                                                                    else
                                                                        sizeValue=newExpr;
                                                                    end

                                                                else

                                                                    tokens=regexp(sizeExpr,'\s*size\(\s*(\w+)\s*,\s*(\d+)\s*\)','tokens');
                                                                    if length(tokens)==1
                                                                        elems=tokens{1};

                                                                        variableName=elems{1};

                                                                        [sizeIndex,indexOk]=str2num(elems{2});
                                                                        if indexOk
                                                                            sizeValue=getVariableSize(sInfo,sldvInfo,variableName,sizeIndex);
                                                                        end
                                                                    else
                                                                        tokens=regexp(sizeExpr,'\s*numel\(\s*(\w+)\s*)','tokens');
                                                                        if length(tokens)==1
                                                                            elems=tokens{1};

                                                                            variableName=elems{1};

                                                                            sizeValue=getVariableSize(sInfo,sldvInfo,variableName,0);
                                                                        end
                                                                    end
                                                                end


                                                                function dimensions=getPortVariableDimensions(portNames,portInfo,variableName)
                                                                    dimensions=[];
                                                                    if numel(portNames)>0
                                                                        index=find(strcmp({portNames.Name},variableName));
                                                                        if~isempty(index)
                                                                            dimensions=portInfo(index).Dim;
                                                                        end
                                                                    end


                                                                    function dimensions=getVariableDimensions(sInfo,sldvInfo,variableName)
                                                                        dimensions=getPortVariableDimensions(sInfo.Inputs,sldvInfo.InputPortInfo,variableName);
                                                                        if isempty(dimensions)
                                                                            dimensions=getPortVariableDimensions(sInfo.Parameters,sldvInfo.ParameterPortInfo,variableName);
                                                                        end
                                                                        if isempty(dimensions)
                                                                            dimensions=getPortVariableDimensions(sInfo.Outputs,sldvInfo.OutputPortInfo,variableName);
                                                                        end
                                                                        if isempty(dimensions)
                                                                            dimensions=getPortVariableDimensions(sInfo.DiscreteStates,sldvInfo.DiscStateInfo,variableName);
                                                                        end
                                                                        if isempty(dimensions)
                                                                            dimensions=getPortVariableDimensions(sInfo.DialogParameters,sldvInfo.DialogParameterInfo,variableName);
                                                                        end



                                                                        function sizeValue=getVariableSize(sInfo,sldvInfo,variableName,sizeIndex)
                                                                            sizeValue='0';
                                                                            if~isempty(variableName)
                                                                                dimensions=getVariableDimensions(sInfo,sldvInfo,variableName);

                                                                                if~isempty(dimensions)
                                                                                    if sizeIndex==0

                                                                                        sizeValue=sprintf('%d',prod(dimensions));
                                                                                    elseif sizeIndex>=1&&sizeIndex<=length(dimensions)
                                                                                        sizeValue=sprintf('%d',dimensions(sizeIndex));
                                                                                    end
                                                                                end
                                                                            end


                                                                            function instanceName=get_encoded_instance_name(instanceIndex)


                                                                                instanceName=sprintf('i%d',instanceIndex);


                                                                                function addVariableNames(variableNames,nameGenerator,instanceName,varInfo)
                                                                                    if~isempty(varInfo)
                                                                                        originalNames={varInfo.Name};
                                                                                        for n=originalNames
                                                                                            name=n{1};
                                                                                            convertedName=nameGenerator.varName(name,instanceName);
                                                                                            variableNames(name)=convertedName;
                                                                                        end
                                                                                    end


                                                                                    function variableNames=generateVariableNames(sInfo,nameGenerator,instanceName)
                                                                                        variableNames=containers.Map();
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.Inputs);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.Outputs);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.Parameters);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.DWorks);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.DiscreteStates);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.SimStructs);
                                                                                        addVariableNames(variableNames,nameGenerator,instanceName,sInfo.DialogParameters);


                                                                                        function ports=generatePorts(prefix,staticPorts,instancePorts)
                                                                                            if~isempty(staticPorts)
                                                                                                ports=staticPorts;
                                                                                            else
                                                                                                ports=struct([]);
                                                                                                count=numel(instancePorts);
                                                                                                for ii=1:count
                                                                                                    t=instancePorts(ii).Type;

                                                                                                    if isempty(t)
                                                                                                        dataType='';
                                                                                                    else
                                                                                                        if ischar(t)
                                                                                                            dataType=t;
                                                                                                        elseif isa(t,'embedded.numerictype')
                                                                                                            if t.isfloat
                                                                                                                dataType=sprintf('real%d_T',t.WordLength);
                                                                                                            elseif t.isboolean
                                                                                                                dataType='boolean_T';
                                                                                                            elseif t.isfixed
                                                                                                                signednessPrefix='';
                                                                                                                if~t.SignednessBool
                                                                                                                    signednessPrefix='u';
                                                                                                                end
                                                                                                                dataType=sprintf('%sint%d_T',signednessPrefix,t.WordLength);
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                    ports(ii).Name=sprintf('%s%d',prefix,ii);
                                                                                                    ports(ii).VarIndex=ii;
                                                                                                    ports(ii).DataType=dataType;
                                                                                                end
                                                                                            end


                                                                                            function completedInfo=completeSimStructInfo(sInfo,instanceInfo)







                                                                                                completedInfo=sInfo;
                                                                                                if~isempty(completedInfo.SimStructs)
                                                                                                    completedInfo.Outputs=generatePorts('Out',sInfo.Outputs,instanceInfo.OutputPortInfo);
                                                                                                    completedInfo.Inputs=generatePorts('In',sInfo.Inputs,instanceInfo.InputPortInfo);
                                                                                                    completedInfo.Parameters=generatePorts('RtPrm',sInfo.Parameters,instanceInfo.ParameterPortInfo);
                                                                                                    completedInfo.DWorks=generatePorts('DWork',sInfo.DWorks,instanceInfo.DWorkInfo);
                                                                                                    completedInfo.DiscreteStates=generatePorts('DiscState',sInfo.DiscreteStates,instanceInfo.DiscStateInfo);
                                                                                                end
                                                                                                completedInfo.DialogParameters=generatePorts('DialogPrm',sInfo.DialogParameters,instanceInfo.DialogParameterInfo);


                                                                                                function beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions)
                                                                                                    writer.beginBlock('%s {',sig);
                                                                                                    if simStructOptions.GenerateAsserts&&simStructOptions.UseInstanceVar
                                                                                                        writer.print('\nassert(%s >= 1 && %s <= %d);',...
                                                                                                        varNamesInfo.InstanceVar,varNamesInfo.InstanceVar,numInstances);
                                                                                                    end


                                                                                                    function beginCurrentInstance(writer,varNamesInfo,ii,numInstances)
                                                                                                        if numInstances>1
                                                                                                            if ii==1
                                                                                                                blkStart=sprintf('\nif(%s == %d)',varNamesInfo.InstanceVar,ii);
                                                                                                            elseif ii==numInstances
                                                                                                                blkStart='else';
                                                                                                            else
                                                                                                                blkStart=sprintf('else if(%s == %d)',varNamesInfo.InstanceVar,ii);
                                                                                                            end
                                                                                                            writer.beginBlock('%s {',blkStart);
                                                                                                        end









                                                                                                        function stubInfo=newSimStructStub(name,sig,retType)
                                                                                                            stubInfo=struct(...
                                                                                                            'Name',name,...
                                                                                                            'RetType',retType,...
                                                                                                            'Definition','',...
                                                                                                            'Declaration',sig,...
                                                                                                            'Line',0,...
                                                                                                            'IsInternal',false);


                                                                                                            function endCurrentInstance(writer,~,numInstances)
                                                                                                                if numInstances>1
                                                                                                                    writer.endBlock('\n} ');
                                                                                                                end


                                                                                                                function endInstances(writer)
                                                                                                                    writer.endBlock('\n}\n\n');


                                                                                                                    function beginPorts(writer,numPorts,simStructOptions)
                                                                                                                        if simStructOptions.GenerateAsserts
                                                                                                                            if numPorts>0
                                                                                                                                writer.print('\nassert(idx >= 0 && idx < %d);',numPorts);
                                                                                                                            else
                                                                                                                                writer.print('\nassert(0);');
                                                                                                                            end
                                                                                                                        end


                                                                                                                        function beginCurrentPort(writer,idx,numPorts)
                                                                                                                            if numPorts>1
                                                                                                                                portIdx=idx-1;
                                                                                                                                if idx==1
                                                                                                                                    startBlk=sprintf('\nif(idx==%d)',portIdx);
                                                                                                                                elseif idx==numPorts
                                                                                                                                    startBlk='else';
                                                                                                                                else
                                                                                                                                    startBlk=sprintf('else if(idx==%d)',portIdx);
                                                                                                                                end
                                                                                                                                writer.beginBlock('%s {',startBlk);
                                                                                                                            end


                                                                                                                            function endCurrentPort(writer,numPorts)
                                                                                                                                if numPorts>1
                                                                                                                                    writer.endBlock('\n} ');
                                                                                                                                end


                                                                                                                                function endPorts(writer,numPorts)
                                                                                                                                    if numPorts<=0
                                                                                                                                        writer.print('\nreturn 0;');
                                                                                                                                    end


                                                                                                                                    function stubInfo=generateDiscStatesFunction(writer,functionName,outputType,...
                                                                                                                                        variableNames,instances,allCompletedInfo,varNamesInfo,...
                                                                                                                                        simStructOptions)
                                                                                                                                        sig=sprintf('%s *%s(SimStruct *S)',outputType,functionName);
                                                                                                                                        stubInfo=newSimStructStub(functionName,sig,outputType);

                                                                                                                                        numInstances=numel(allCompletedInfo);
                                                                                                                                        stubInfo.Line=writer.beginStr();

                                                                                                                                        beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);

                                                                                                                                        for ii=1:numel(allCompletedInfo)
                                                                                                                                            varNames=variableNames{ii};
                                                                                                                                            instance=instances(ii);
                                                                                                                                            sInfo=allCompletedInfo(ii);

                                                                                                                                            beginCurrentInstance(writer,varNamesInfo,ii,numInstances);

                                                                                                                                            sInfoPort=sInfo.DiscreteStates;
                                                                                                                                            instancePort=instance.DiscStateInfo;
                                                                                                                                            if numel(sInfoPort)==1
                                                                                                                                                portDims=instancePort.Dim;
                                                                                                                                                if prod(portDims)>1
                                                                                                                                                    arrayIdx='[0]';
                                                                                                                                                else
                                                                                                                                                    arrayIdx='';
                                                                                                                                                end
                                                                                                                                                varName=varNames(sInfoPort.Name);
                                                                                                                                                writer.print('\nreturn (%s*)&%s%s;',outputType,varName,arrayIdx);
                                                                                                                                            else
                                                                                                                                                if simStructOptions.GenerateAsserts
                                                                                                                                                    writer.print('\nassert(0);');
                                                                                                                                                end
                                                                                                                                                writer.print('\nreturn 0;');
                                                                                                                                            end
                                                                                                                                            endCurrentInstance(writer,ii,numInstances);
                                                                                                                                        end
                                                                                                                                        endInstances(writer);
                                                                                                                                        stubInfo.Definition=writer.endStr();



                                                                                                                                        function stubInfo=generateGetNumFunction(writer,...
                                                                                                                                            functionName,...
                                                                                                                                            instances,...
                                                                                                                                            instancePortName,...
                                                                                                                                            varNamesInfo,...
                                                                                                                                            ~)
                                                                                                                                            sig=sprintf('int_T %s(SimStruct *S)',functionName);
                                                                                                                                            stubInfo=newSimStructStub(functionName,sig,'int_T');
                                                                                                                                            stubInfo.Line=writer.beginStr();

                                                                                                                                            numInstances=numel(instances);


                                                                                                                                            numPorts=numel(instances(1).(instancePortName));
                                                                                                                                            for ii=2:numInstances
                                                                                                                                                instanceNumPorts=numel(instances(ii).(instancePortName));
                                                                                                                                                if instanceNumPorts~=numPorts
                                                                                                                                                    numPorts=-1;
                                                                                                                                                end
                                                                                                                                            end

                                                                                                                                            if numPorts<0
                                                                                                                                                beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                for ii=1:numel(instances)
                                                                                                                                                    portsInfo=instances(ii).(instancePortName);

                                                                                                                                                    beginCurrentInstance(writer,varNamesInfo,ii,numInstances,simStructOptions);
                                                                                                                                                    writer.print('\nreturn %d;',numel(portsInfo));
                                                                                                                                                    endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                end
                                                                                                                                                endInstances(writer);
                                                                                                                                            else

                                                                                                                                                writer.beginBlock('%s {',sig);
                                                                                                                                                writer.print('\nreturn %d;',numPorts);
                                                                                                                                                writer.endBlock('\n}\n\n');
                                                                                                                                            end
                                                                                                                                            stubInfo.Definition=writer.endStr();





                                                                                                                                            function stubInfo=generatePortDimensionsFunction(writer,functionName,variableNames,instances,portName,completedPortName,allCompletedInfos,varNamesInfo,simStructOptions,outputType)
                                                                                                                                                sig=sprintf('%s *%s(SimStruct *S, int_T idx)',outputType,functionName);

                                                                                                                                                stubInfo=newSimStructStub(functionName,sig,outputType);
                                                                                                                                                stubInfo.Line=writer.beginStr();


                                                                                                                                                numInstances=numel(instances);
                                                                                                                                                beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                for ii=1:numInstances
                                                                                                                                                    portsInfo=instances(ii).(portName);
                                                                                                                                                    varNames=variableNames{ii};
                                                                                                                                                    completedInfo=allCompletedInfos(ii);

                                                                                                                                                    beginCurrentInstance(writer,varNamesInfo,ii,numInstances);
                                                                                                                                                    numPorts=numel(portsInfo);
                                                                                                                                                    beginPorts(writer,numPorts,simStructOptions);

                                                                                                                                                    completedPorts=completedInfo.(completedPortName);
                                                                                                                                                    for p=1:numPorts
                                                                                                                                                        currentPortName=completedPorts(p).Name;
                                                                                                                                                        variableName=getDimsArrayVarName(varNames(currentPortName));
                                                                                                                                                        beginCurrentPort(writer,p,numPorts);

                                                                                                                                                        writer.print('\nreturn %s;',variableName);
                                                                                                                                                        endCurrentPort(writer,numPorts);
                                                                                                                                                    end

                                                                                                                                                    endPorts(writer,numPorts);
                                                                                                                                                    endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                end
                                                                                                                                                endInstances(writer);
                                                                                                                                                stubInfo.Definition=writer.endStr();


                                                                                                                                                function stubInfo=generateNumDimensionsFunction(writer,functionName,instances,portName,varNamesInfo,simStructOptions,outputType)
                                                                                                                                                    sig=sprintf('%s %s(SimStruct *S, int_T idx)',outputType,functionName);
                                                                                                                                                    stubInfo=newSimStructStub(functionName,sig,outputType);
                                                                                                                                                    stubInfo.Line=writer.beginStr();

                                                                                                                                                    numInstances=numel(instances);
                                                                                                                                                    beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                    for ii=1:numInstances
                                                                                                                                                        portsInfo=instances(ii).(portName);
                                                                                                                                                        beginCurrentInstance(writer,varNamesInfo,ii,numInstances);
                                                                                                                                                        numPorts=numel(portsInfo);
                                                                                                                                                        beginPorts(writer,numPorts,simStructOptions);
                                                                                                                                                        for p=1:numPorts
                                                                                                                                                            dims=portsInfo(p).Dim;
                                                                                                                                                            beginCurrentPort(writer,p,numPorts);
                                                                                                                                                            writer.print('\nreturn %d;',numel(dims));
                                                                                                                                                            endCurrentPort(writer,numPorts);
                                                                                                                                                        end
                                                                                                                                                        endPorts(writer,numPorts);
                                                                                                                                                        endCurrentInstance(writer,varNamesInfo,numInstances);
                                                                                                                                                    end
                                                                                                                                                    endInstances(writer);
                                                                                                                                                    stubInfo.Definition=writer.endStr();


                                                                                                                                                    function stubInfo=generateDimensionSizeFunction(writer,functionName,calledFunction,outputType)
                                                                                                                                                        sig=sprintf('%s %s(SimStruct *S, int_T port_idx, int_T dim_idx)',outputType,functionName);
                                                                                                                                                        stubInfo=newSimStructStub(functionName,sig,outputType);
                                                                                                                                                        stubInfo.Line=writer.beginStr();
                                                                                                                                                        writer.beginBlock('%s {',sig);
                                                                                                                                                        writer.print('\nreturn (%s(S, port_idx))[dim_idx];',calledFunction);
                                                                                                                                                        writer.endBlock('\n}\n\n');

                                                                                                                                                        stubInfo.Definition=writer.endStr();


                                                                                                                                                        function stubInfo=generateParamPortFunction(writer,functionName,variableNames,instances,allCompletedInfos,varNamesInfo,simStructOptions)
                                                                                                                                                            sig=sprintf('ssParamRec *%s(SimStruct *S, int_T idx)',functionName);
                                                                                                                                                            stubInfo=newSimStructStub(functionName,sig,'ssParamRec *');
                                                                                                                                                            stubInfo.Line=writer.beginStr();

                                                                                                                                                            numInstances=numel(instances);
                                                                                                                                                            beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                            for ii=1:numInstances
                                                                                                                                                                portsInfo=instances(ii).ParameterPortInfo;
                                                                                                                                                                varNames=variableNames{ii};
                                                                                                                                                                completedInfo=allCompletedInfos(ii);
                                                                                                                                                                beginCurrentInstance(writer,varNamesInfo,ii,numInstances);

                                                                                                                                                                numPorts=numel(portsInfo);
                                                                                                                                                                beginPorts(writer,numPorts,simStructOptions);

                                                                                                                                                                for p=1:numel(portsInfo)
                                                                                                                                                                    portName=completedInfo.Parameters(p).Name;
                                                                                                                                                                    variableName=getRunTimeParamRecName(varNames(portName));
                                                                                                                                                                    beginCurrentPort(writer,p,numPorts);
                                                                                                                                                                    writer.print('\nreturn &%s;',variableName);
                                                                                                                                                                    endCurrentPort(writer,numPorts);
                                                                                                                                                                end
                                                                                                                                                                endPorts(writer,numPorts);
                                                                                                                                                                endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                            end
                                                                                                                                                            endInstances(writer);
                                                                                                                                                            stubInfo.Definition=writer.endStr();




                                                                                                                                                            function dtypeId=getDTypeId(t)
                                                                                                                                                                dtypeId='';
                                                                                                                                                                if isa(t,'embedded.numerictype')
                                                                                                                                                                    if t.isfloat
                                                                                                                                                                        if t.WordLength==32
                                                                                                                                                                            dtypeId='SS_SINGLE';
                                                                                                                                                                        else
                                                                                                                                                                            dtypeId='SS_DOUBLE';
                                                                                                                                                                        end
                                                                                                                                                                    elseif t.isboolean
                                                                                                                                                                        dtypeId='SS_BOOLEAN';
                                                                                                                                                                    elseif t.isfixed
                                                                                                                                                                        signednessPrefix='';
                                                                                                                                                                        if~t.SignednessBool
                                                                                                                                                                            signednessPrefix='U';
                                                                                                                                                                        end
                                                                                                                                                                        if t.WordLength<=32
                                                                                                                                                                            dtypeId=sprintf('SS_%sINT%d',signednessPrefix,t.WordLength);
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end





                                                                                                                                                                function dtypeString=getNonPrimitiveDTypeString(t)
                                                                                                                                                                    dtypeString='';
                                                                                                                                                                    if ischar(t)

                                                                                                                                                                        dtypeString=['b',t];
                                                                                                                                                                    elseif isa(t,'embedded.numerictype')&&...
                                                                                                                                                                        t.isfixed&&...
                                                                                                                                                                        t.FractionLength~=0
                                                                                                                                                                        if t.SignednessBool
                                                                                                                                                                            signednessPrefix='s';
                                                                                                                                                                        else
                                                                                                                                                                            signednessPrefix='u';
                                                                                                                                                                        end
                                                                                                                                                                        dtypeString=sprintf('f%s%d_%d_%s',signednessPrefix,...
                                                                                                                                                                        t.WordLength,...
                                                                                                                                                                        t.FractionLength,...
                                                                                                                                                                        t.Scaling);
                                                                                                                                                                    end


                                                                                                                                                                    function currentId=updateUserTypeInfo(ports,userTypeInfo,currentId)
                                                                                                                                                                        for ii=1:numel(ports)
                                                                                                                                                                            currentType=ports(ii).Type;
                                                                                                                                                                            dataTypeString=getNonPrimitiveDTypeString(currentType);

                                                                                                                                                                            if~isempty(dataTypeString)&&~userTypeInfo.isKey(dataTypeString)

                                                                                                                                                                                typeInfo=struct('Type',currentType,...
                                                                                                                                                                                'DTypeID',currentId);
                                                                                                                                                                                userTypeInfo(dataTypeString)=typeInfo;

                                                                                                                                                                                currentId=currentId+1;
                                                                                                                                                                            end
                                                                                                                                                                        end


                                                                                                                                                                        function primitiveTypes=getPrimitiveTypes()
                                                                                                                                                                            primitiveTypes=containers.Map('KeyType','char','ValueType','any');
                                                                                                                                                                            primitiveTypes('SS_DOUBLE')=numerictype('double');
                                                                                                                                                                            primitiveTypes('SS_SINGLE')=numerictype('single');
                                                                                                                                                                            primitiveTypes('SS_INT8')=numerictype('int8');
                                                                                                                                                                            primitiveTypes('SS_UINT8')=numerictype('uint8');
                                                                                                                                                                            primitiveTypes('SS_INT16')=numerictype('int16');
                                                                                                                                                                            primitiveTypes('SS_UINT16')=numerictype('uint16');
                                                                                                                                                                            primitiveTypes('SS_INT32')=numerictype('int32');
                                                                                                                                                                            primitiveTypes('SS_UINT32')=numerictype('uint32');




                                                                                                                                                                            function typeInfo=generateTypeInfo(instancesInfo)
                                                                                                                                                                                primitiveTypes=getPrimitiveTypes();
                                                                                                                                                                                userTypeInfo=containers.Map('KeyType','char','ValueType','any');
                                                                                                                                                                                currentId=20;

                                                                                                                                                                                for ii=1:numel(instancesInfo)
                                                                                                                                                                                    instance=instancesInfo(ii);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.InputPortInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.OutputPortInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.ParameterPortInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.DialogParameterInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.DWorkInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.DiscStateInfo,userTypeInfo,currentId);
                                                                                                                                                                                    currentId=updateUserTypeInfo(instance.DataStoreInfo,userTypeInfo,currentId);
                                                                                                                                                                                end

                                                                                                                                                                                typeInfo=struct('PrimitiveTypes',primitiveTypes,...
                                                                                                                                                                                'UserTypes',userTypeInfo);


                                                                                                                                                                                function stubInfo=generateDataTypeSizeFcn(writer,outputType,functionName,...
                                                                                                                                                                                    typeInfo)
                                                                                                                                                                                    stubInfo=generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                    functionName,outputType,...
                                                                                                                                                                                    @(t)t.WordLength/8,...
                                                                                                                                                                                    'VolatileDefault',true);


                                                                                                                                                                                    function stubInfo=generateGetPortTypeFunction(writer,functionName,...
                                                                                                                                                                                        instances,instancePortName,...
                                                                                                                                                                                        varNamesInfo,simStructOptions,...
                                                                                                                                                                                        typeInfo)
                                                                                                                                                                                        sig=sprintf('DTypeId %s(SimStruct *S, int_T idx)',functionName);
                                                                                                                                                                                        stubInfo=newSimStructStub(functionName,sig,'DTypeId');
                                                                                                                                                                                        stubInfo.Line=writer.beginStr();
                                                                                                                                                                                        numInstances=numel(instances);
                                                                                                                                                                                        beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);

                                                                                                                                                                                        for ii=1:numInstances
                                                                                                                                                                                            portsInfo=instances(ii).(instancePortName);

                                                                                                                                                                                            beginCurrentInstance(writer,varNamesInfo,ii,numInstances);
                                                                                                                                                                                            numPorts=numel(portsInfo);
                                                                                                                                                                                            beginPorts(writer,numPorts,simStructOptions);
                                                                                                                                                                                            for p=1:numPorts
                                                                                                                                                                                                beginCurrentPort(writer,p,numPorts);

                                                                                                                                                                                                t=portsInfo(p).Type;

                                                                                                                                                                                                dtypeString=getNonPrimitiveDTypeString(t);
                                                                                                                                                                                                if~isempty(dtypeString)
                                                                                                                                                                                                    userType=typeInfo.UserTypes(dtypeString);
                                                                                                                                                                                                    writer.print('\n return %d;',userType.DTypeID);
                                                                                                                                                                                                else
                                                                                                                                                                                                    dtypeEnum=getDTypeId(t);
                                                                                                                                                                                                    writer.print('\nreturn %s;',dtypeEnum);
                                                                                                                                                                                                end

                                                                                                                                                                                                endCurrentPort(writer,numPorts);
                                                                                                                                                                                            end
                                                                                                                                                                                            endPorts(writer,numPorts);
                                                                                                                                                                                            endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                                                        end

                                                                                                                                                                                        endInstances(writer);
                                                                                                                                                                                        stubInfo.Definition=writer.endStr();


                                                                                                                                                                                        function stubInfo=generatePortWidthFunction(writer,functionName,...
                                                                                                                                                                                            instances,instancePortName,varNamesInfo,simStructOptions)
                                                                                                                                                                                            sig=sprintf('int_T %s(SimStruct *S, int_T idx)',functionName);
                                                                                                                                                                                            stubInfo=newSimStructStub(functionName,sig,'int_T');
                                                                                                                                                                                            stubInfo.Line=writer.beginStr();

                                                                                                                                                                                            numInstances=numel(instances);
                                                                                                                                                                                            beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                                                            for ii=1:numInstances
                                                                                                                                                                                                portsInfo=instances(ii).(instancePortName);
                                                                                                                                                                                                beginCurrentInstance(writer,varNamesInfo,ii,numInstances);
                                                                                                                                                                                                numPorts=numel(portsInfo);
                                                                                                                                                                                                beginPorts(writer,numPorts,simStructOptions);
                                                                                                                                                                                                for p=1:numPorts
                                                                                                                                                                                                    portDims=portsInfo(p).Dim;
                                                                                                                                                                                                    beginCurrentPort(writer,p,numPorts);
                                                                                                                                                                                                    writer.print('\nreturn %d;',prod(portDims));
                                                                                                                                                                                                    endCurrentPort(writer,numPorts);
                                                                                                                                                                                                end
                                                                                                                                                                                                endPorts(writer,numPorts);
                                                                                                                                                                                                endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                                                            end
                                                                                                                                                                                            endInstances(writer);
                                                                                                                                                                                            stubInfo.Definition=writer.endStr();


                                                                                                                                                                                            function simStructStubs=generateSimStructFunctions(writer,nameGenerator,allCompletedInfo,instances,...
                                                                                                                                                                                                varNamesInfo,simStructOptions,typeInfo)
                                                                                                                                                                                                writer.print('\n\n/*** SimStruct overridden functions ***/\n\n');
                                                                                                                                                                                                numInstances=numel(allCompletedInfo);
                                                                                                                                                                                                simStructStubs=newSimStructStub('','',' ');

                                                                                                                                                                                                if numInstances==numel(instances)&&numInstances>0



                                                                                                                                                                                                    variableNames=cell(1,numInstances);
                                                                                                                                                                                                    for ii=1:numInstances
                                                                                                                                                                                                        variableNames{ii}=generateVariableNames(allCompletedInfo(ii),...
                                                                                                                                                                                                        nameGenerator,...
                                                                                                                                                                                                        get_encoded_instance_name(ii));
                                                                                                                                                                                                    end

                                                                                                                                                                                                    simStructStubs(1)=generateGetNumFunction(writer,nameGenerator.ssFunction('ssGetNumInputPorts'),...
                                                                                                                                                                                                    instances,'InputPortInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end+1)=generateGetNumFunction(writer,nameGenerator.ssFunction('ssGetNumOutputPorts'),...
                                                                                                                                                                                                    instances,'OutputPortInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end+1)=generateGetNumFunction(writer,nameGenerator.ssFunction('ssGetNumRunTimeParams'),...
                                                                                                                                                                                                    instances,'ParameterPortInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end+1)=generateGetNumFunction(writer,nameGenerator.ssFunction('ssGetSFcnParamsCount'),...
                                                                                                                                                                                                    instances,'DialogParameterInfo',varNamesInfo,simStructOptions);

                                                                                                                                                                                                    simStructStubs(end+1)=generatePortWidthFunction(writer,nameGenerator.ssFunction('ssGetInputPortWidth'),...
                                                                                                                                                                                                    instances,'InputPortInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end+1)=generatePortWidthFunction(writer,nameGenerator.ssFunction('ssGetOutputPortWidth'),...
                                                                                                                                                                                                    instances,'OutputPortInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end+1)=generatePortWidthFunction(writer,nameGenerator.ssFunction('ssGetSFcnParam___Count'),...
                                                                                                                                                                                                    instances,'DialogParameterInfo',varNamesInfo,simStructOptions);
                                                                                                                                                                                                    simStructStubs(end).IsInternal=true;

                                                                                                                                                                                                    simStructStubs(end+1)=generatePortDimensionsFunction(writer,nameGenerator.ssFunction('ssGetInputPortDimensions'),...
                                                                                                                                                                                                    variableNames,instances,'InputPortInfo','Inputs',...
                                                                                                                                                                                                    allCompletedInfo,varNamesInfo,simStructOptions,'int_T');
                                                                                                                                                                                                    simStructStubs(end+1)=generatePortDimensionsFunction(writer,nameGenerator.ssFunction('ssGetOutputPortDimensions'),...
                                                                                                                                                                                                    variableNames,instances,'OutputPortInfo','Outputs',...
                                                                                                                                                                                                    allCompletedInfo,varNamesInfo,simStructOptions,'int_T');
                                                                                                                                                                                                    simStructStubs(end+1)=generatePortDimensionsFunction(writer,nameGenerator.ssFunction('ssGetSFcnParam___Dimensions'),...
                                                                                                                                                                                                    variableNames,instances,'DialogParameterInfo','DialogParameters',...
                                                                                                                                                                                                    allCompletedInfo,varNamesInfo,simStructOptions,'mwSize');
                                                                                                                                                                                                    simStructStubs(end).IsInternal=true;

                                                                                                                                                                                                    simStructStubs(end+1)=generateNumDimensionsFunction(writer,nameGenerator.ssFunction('ssGetInputPortNumDimensions'),...
                                                                                                                                                                                                    instances,'InputPortInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,'int_T');
                                                                                                                                                                                                    simStructStubs(end+1)=generateNumDimensionsFunction(writer,nameGenerator.ssFunction('ssGetOutputPortNumDimensions'),...
                                                                                                                                                                                                    instances,'OutputPortInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,'int_T');
                                                                                                                                                                                                    simStructStubs(end+1)=generateNumDimensionsFunction(writer,nameGenerator.ssFunction('ssGetSFcnParam___NumDimensions'),...
                                                                                                                                                                                                    instances,'DialogParameterInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,'mwSize');
                                                                                                                                                                                                    simStructStubs(end).IsInternal=true;

                                                                                                                                                                                                    simStructStubs(end+1)=generateDimensionSizeFunction(writer,nameGenerator.ssFunction('ssGetInputPortDimensionSize'),...
                                                                                                                                                                                                    nameGenerator.ssFunction('ssGetInputPortDimensions'),'int_T');
                                                                                                                                                                                                    simStructStubs(end+1)=generateDimensionSizeFunction(writer,nameGenerator.ssFunction('ssGetOutputPortDimensionSize'),...
                                                                                                                                                                                                    nameGenerator.ssFunction('ssGetOutputPortDimensions'),'int_T');

                                                                                                                                                                                                    simStructStubs(end+1)=generateParamPortFunction(writer,nameGenerator.ssFunction('ssGetRunTimeParamInfo'),...
                                                                                                                                                                                                    variableNames,instances,...
                                                                                                                                                                                                    allCompletedInfo,varNamesInfo,simStructOptions);

                                                                                                                                                                                                    simStructStubs(end+1)=generateDiscStatesFunction(writer,nameGenerator.ssFunction('ssGetDiscStates'),'real_T',...
                                                                                                                                                                                                    variableNames,instances,allCompletedInfo,varNamesInfo,simStructOptions);

                                                                                                                                                                                                    simStructStubs(end+1)=generateGetPortTypeFunction(writer,nameGenerator.ssFunction('ssGetInputPortDataType'),...
                                                                                                                                                                                                    instances,'InputPortInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,...
                                                                                                                                                                                                    typeInfo);

                                                                                                                                                                                                    simStructStubs(end+1)=generateGetPortTypeFunction(writer,nameGenerator.ssFunction('ssGetOutputPortDataType'),...
                                                                                                                                                                                                    instances,'OutputPortInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,...
                                                                                                                                                                                                    typeInfo);

                                                                                                                                                                                                    simStructStubs(end+1)=generateGetPortTypeFunction(writer,nameGenerator.ssFunction('ssGetDWorkDataType'),...
                                                                                                                                                                                                    instances,'DWorkInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,...
                                                                                                                                                                                                    typeInfo);
                                                                                                                                                                                                    simStructStubs(end+1)=generateDataTypeSizeFcn(writer,'int_T','ssGetDataTypeSize',typeInfo);


                                                                                                                                                                                                    simStructStubs(end+1)=generateGetPortScalarFunction(writer,nameGenerator.ssFunction('ssGetSFcnParam___Scalar'),...
                                                                                                                                                                                                    variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                    'DialogParameters','DialogParameterInfo',...
                                                                                                                                                                                                    varNamesInfo,simStructOptions,'real_T');
                                                                                                                                                                                                    simStructStubs(end).IsInternal=true;

                                                                                                                                                                                                    if simStructOptions.FunctionWrappers

                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetInputPortRealSignal'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'Inputs','InputPortInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions,'const real_T');

                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetOutputPortRealSignal'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'Outputs','OutputPortInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions,'real_T');


                                                                                                                                                                                                        simStructStubs(end+1)=generateGetSFcnParamX(writer,nameGenerator.ssFunction('ssGetSFcnParam___N'),...
                                                                                                                                                                                                        nameGenerator.ssFunction('ssGetSFcnParam___Dimensions'),...
                                                                                                                                                                                                        1);
                                                                                                                                                                                                        simStructStubs(end).IsInternal=true;


                                                                                                                                                                                                        simStructStubs(end+1)=generateGetSFcnParamX(writer,nameGenerator.ssFunction('ssGetSFcnParam___M'),...
                                                                                                                                                                                                        nameGenerator.ssFunction('ssGetSFcnParam___Dimensions'),...
                                                                                                                                                                                                        0);
                                                                                                                                                                                                        simStructStubs(end).IsInternal=true;


                                                                                                                                                                                                        simStructStubs(end+1)=generateDiscStatesFunction(writer,nameGenerator.ssFunction('ssGetRealDiscStates'),'real_T',...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        varNamesInfo,simStructOptions);


                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetInputPortSignal'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'Inputs','InputPortInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions,'const void');

                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetOutputPortSignal'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'Outputs','OutputPortInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions);

                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,...
                                                                                                                                                                                                        nameGenerator.ssFunction('ssGetRunTimeParamInfo___Data'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'Parameters','ParameterPortInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions);
                                                                                                                                                                                                        simStructStubs(end).IsInternal=true;


                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetSFcnParam___Data'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'DialogParameters','DialogParameterInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions);
                                                                                                                                                                                                        simStructStubs(end).IsInternal=true;

                                                                                                                                                                                                        simStructStubs(end+1)=generateGetPortSignalFunction(writer,nameGenerator.ssFunction('ssGetDWork'),...
                                                                                                                                                                                                        variableNames,instances,allCompletedInfo,...
                                                                                                                                                                                                        'DWorks','DWorkInfo',varNamesInfo,...
                                                                                                                                                                                                        simStructOptions,'void');
                                                                                                                                                                                                    end

                                                                                                                                                                                                    generateExtraSimStructWrappers(writer);
                                                                                                                                                                                                end




                                                                                                                                                                                                function generateExtraSimStructWrappers(writer)
                                                                                                                                                                                                    stubsFile=sldv.code.sfcn.internal.HandwrittenFEHandler.getDefaultStubsFile();
                                                                                                                                                                                                    stubsInfo=sldv.code.sfcn.internal.HandwrittenFEHandler.readStubsFile(stubsFile);

                                                                                                                                                                                                    for ii=1:numel(stubsInfo)
                                                                                                                                                                                                        current=stubsInfo(ii);
                                                                                                                                                                                                        if~isempty(current.Body)&&~current.Excluded
                                                                                                                                                                                                            writer.beginBlock('%s %s(%s) {',current.RetType,current.Name,current.Args);
                                                                                                                                                                                                            writer.print('\n%s',current.Body);
                                                                                                                                                                                                            writer.endBlock('\n}\n');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end


                                                                                                                                                                                                    function varsMacro=generatePreIncludeVar(varsMacro,sInfo,varDims,name,qualifier,...
                                                                                                                                                                                                        generateDims)

                                                                                                                                                                                                        if nargin<6
                                                                                                                                                                                                            generateDims=false;
                                                                                                                                                                                                        end

                                                                                                                                                                                                        portWidth=prod(varDims);

                                                                                                                                                                                                        dataType=sInfo.DataType;
                                                                                                                                                                                                        if isempty(dataType)
                                                                                                                                                                                                            dataType='char*';
                                                                                                                                                                                                            portWidth=1;
                                                                                                                                                                                                        end

                                                                                                                                                                                                        if isempty(qualifier)
                                                                                                                                                                                                            decl=sprintf('%s %s',dataType,name);
                                                                                                                                                                                                        else
                                                                                                                                                                                                            decl=sprintf('%s %s %s',qualifier,dataType,name);
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if portWidth>1
                                                                                                                                                                                                            decl=sprintf('%s[%d]',decl,portWidth);
                                                                                                                                                                                                        end

                                                                                                                                                                                                        varsMacro=sprintf('%s;\\\n  %s',varsMacro,decl);
                                                                                                                                                                                                        if generateDims
                                                                                                                                                                                                            dimsVar=getDimsArrayVarName(name);
                                                                                                                                                                                                            dimsDecl=sprintf('EXTERN mwSize %s[%d]',dimsVar,numel(varDims));

                                                                                                                                                                                                            varsMacro=sprintf('%s;\\\n  %s',varsMacro,dimsDecl);
                                                                                                                                                                                                        end


                                                                                                                                                                                                        function generateInstancePortsMacro(writer,sInfoPorts,instancePorts,varNames,varNamesInfo)
                                                                                                                                                                                                            closingCount=0;

                                                                                                                                                                                                            for portIndex=1:numel(sInfoPorts)
                                                                                                                                                                                                                closingCount=closingCount+1;

                                                                                                                                                                                                                writer.print('(%s==%d ? ',varNamesInfo.IndexVar,portIndex-1);
                                                                                                                                                                                                                addressOp='&';
                                                                                                                                                                                                                portDims=instancePorts(portIndex).Dim;
                                                                                                                                                                                                                portType=instancePorts(portIndex).Type;

                                                                                                                                                                                                                if isempty(portType)
                                                                                                                                                                                                                    arrayIdx='';
                                                                                                                                                                                                                    addressOp='';
                                                                                                                                                                                                                elseif prod(portDims)>1
                                                                                                                                                                                                                    arrayIdx='[0]';
                                                                                                                                                                                                                else
                                                                                                                                                                                                                    arrayIdx='';
                                                                                                                                                                                                                end
                                                                                                                                                                                                                varName=varNames(sInfoPorts(portIndex).Name);
                                                                                                                                                                                                                writer.print('((type*)%s%s%s) : ',addressOp,varName,arrayIdx);
                                                                                                                                                                                                            end

                                                                                                                                                                                                            writer.print('0%s',repmat(')',1,closingCount));


                                                                                                                                                                                                            function generateGetPortSignalMacro(writer,...
                                                                                                                                                                                                                functionName,...
                                                                                                                                                                                                                variableNames,...
                                                                                                                                                                                                                instances,...
                                                                                                                                                                                                                allCompletedInfo,...
                                                                                                                                                                                                                sInfoPortName,...
                                                                                                                                                                                                                instancePortName,...
                                                                                                                                                                                                                varNamesInfo,...
                                                                                                                                                                                                                generateInstancePortsMacroFcn)
                                                                                                                                                                                                                if nargin<9
                                                                                                                                                                                                                    generateInstancePortsMacroFcn=@generateInstancePortsMacro;
                                                                                                                                                                                                                end

                                                                                                                                                                                                                writer.print('\n#define %s(type, S, idx)\\\n',functionName);


                                                                                                                                                                                                                writer.print('  (%s = (idx), ',varNamesInfo.IndexVar);
                                                                                                                                                                                                                closingParenCount=1;
                                                                                                                                                                                                                for ii=1:numel(allCompletedInfo)
                                                                                                                                                                                                                    varNames=variableNames{ii};
                                                                                                                                                                                                                    instance=instances(ii);
                                                                                                                                                                                                                    sInfo=allCompletedInfo(ii);

                                                                                                                                                                                                                    sInfoPorts=sInfo.(sInfoPortName);
                                                                                                                                                                                                                    instancePorts=instance.(instancePortName);

                                                                                                                                                                                                                    closingParenCount=closingParenCount+1;

                                                                                                                                                                                                                    writer.print('    (%s == %d ? ',varNamesInfo.InstanceVar,ii);
                                                                                                                                                                                                                    generateInstancePortsMacroFcn(writer,sInfoPorts,instancePorts,varNames,varNamesInfo);
                                                                                                                                                                                                                    writer.print('\\\n');
                                                                                                                                                                                                                    writer.print('  : ');
                                                                                                                                                                                                                end
                                                                                                                                                                                                                writer.print('0%s\n\n',repmat(')',1,closingParenCount));



                                                                                                                                                                                                                function generateInstancePortsBody(writer,sInfoPorts,instancePorts,varNames,outputType,simStructOptions)
                                                                                                                                                                                                                    numPorts=numel(sInfoPorts);
                                                                                                                                                                                                                    beginPorts(writer,numPorts,simStructOptions);
                                                                                                                                                                                                                    for portIndex=1:numPorts
                                                                                                                                                                                                                        varIndex=sInfoPorts(portIndex).VarIndex;

                                                                                                                                                                                                                        beginCurrentPort(writer,portIndex,numPorts);
                                                                                                                                                                                                                        if varIndex>0&&varIndex<=numel(instancePorts)
                                                                                                                                                                                                                            portType=instancePorts(portIndex).Type;
                                                                                                                                                                                                                            varName=varNames(sInfoPorts(portIndex).Name);
                                                                                                                                                                                                                            if isempty(portType)

                                                                                                                                                                                                                                writer.print('\nreturn (%s*)%s;',outputType,varName);
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                portDims=instancePorts(portIndex).Dim;
                                                                                                                                                                                                                                if prod(portDims)>1
                                                                                                                                                                                                                                    arrayIdx='[0]';
                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                    arrayIdx='';
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                writer.print('\nreturn (%s*)&%s%s;',outputType,varName,arrayIdx);
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        endCurrentPort(writer,numPorts);
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                    endPorts(writer,numPorts);


                                                                                                                                                                                                                    function generateGetSFcnParamScalarBody(writer,sInfoPorts,instancePorts,varNames,outputType,simStructOptions)
                                                                                                                                                                                                                        numPorts=numel(sInfoPorts);
                                                                                                                                                                                                                        beginPorts(writer,numPorts,simStructOptions);
                                                                                                                                                                                                                        for portIndex=1:numPorts
                                                                                                                                                                                                                            varIndex=sInfoPorts(portIndex).VarIndex;
                                                                                                                                                                                                                            beginCurrentPort(writer,portIndex,numPorts);
                                                                                                                                                                                                                            if varIndex>0&&varIndex<=numel(instancePorts)
                                                                                                                                                                                                                                portType=instancePorts(portIndex).Type;
                                                                                                                                                                                                                                varName=varNames(sInfoPorts(portIndex).Name);
                                                                                                                                                                                                                                if isempty(portType)

                                                                                                                                                                                                                                    writer.print('\nreturn *(%s*)%s;',outputType,varName);
                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                    portDims=instancePorts(portIndex).Dim;
                                                                                                                                                                                                                                    if prod(portDims)>1
                                                                                                                                                                                                                                        arrayIdx='[0]';
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        arrayIdx='';
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    writer.print('\nreturn (%s)%s%s;',outputType,varName,arrayIdx);
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                            endCurrentPort(writer,numPorts);
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        endPorts(writer,numPorts);



                                                                                                                                                                                                                        function stubInfo=generateGetPortScalarFunction(writer,...
                                                                                                                                                                                                                            functionName,...
                                                                                                                                                                                                                            variableNames,...
                                                                                                                                                                                                                            instances,...
                                                                                                                                                                                                                            allCompletedInfo,...
                                                                                                                                                                                                                            sInfoPortName,...
                                                                                                                                                                                                                            instancePortName,...
                                                                                                                                                                                                                            varNamesInfo,...
                                                                                                                                                                                                                            simStructOptions,...
                                                                                                                                                                                                                            outputType)
                                                                                                                                                                                                                            sig=sprintf('%s %s(SimStruct *S, int_T idx)',outputType,functionName);
                                                                                                                                                                                                                            stubInfo=newSimStructStub(functionName,sig,outputType);
                                                                                                                                                                                                                            stubInfo.Line=writer.beginStr();

                                                                                                                                                                                                                            numInstances=numel(allCompletedInfo);
                                                                                                                                                                                                                            beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                                                                                            for ii=1:numel(allCompletedInfo)
                                                                                                                                                                                                                                varNames=variableNames{ii};
                                                                                                                                                                                                                                instance=instances(ii);
                                                                                                                                                                                                                                sInfo=allCompletedInfo(ii);

                                                                                                                                                                                                                                beginCurrentInstance(writer,varNamesInfo,ii,numInstances);

                                                                                                                                                                                                                                sInfoPorts=sInfo.(sInfoPortName);
                                                                                                                                                                                                                                instancePorts=instance.(instancePortName);

                                                                                                                                                                                                                                generateGetSFcnParamScalarBody(writer,sInfoPorts,instancePorts,varNames,outputType,simStructOptions);
                                                                                                                                                                                                                                endCurrentInstance(writer,ii,numInstances);
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                            endInstances(writer);
                                                                                                                                                                                                                            stubInfo.Definition=writer.endStr();


                                                                                                                                                                                                                            function stubInfo=generateGetSFcnParamX(writer,functionName,dimensionsFunction,index)
                                                                                                                                                                                                                                sig=sprintf('mwSize %s(SimStruct *S, int_T idx)',functionName);
                                                                                                                                                                                                                                stubInfo=newSimStructStub(functionName,sig,'mwSize');
                                                                                                                                                                                                                                stubInfo.Line=writer.beginStr();
                                                                                                                                                                                                                                writer.print('%s {\n',sig);
                                                                                                                                                                                                                                writer.print('    return (%s(S, idx))[%d];\n',dimensionsFunction,index);
                                                                                                                                                                                                                                writer.print('}\n\n');
                                                                                                                                                                                                                                stubInfo.Definition=writer.endStr();


                                                                                                                                                                                                                                function stubInfo=generateGetPortSignalFunction(writer,...
                                                                                                                                                                                                                                    functionName,...
                                                                                                                                                                                                                                    variableNames,...
                                                                                                                                                                                                                                    instances,...
                                                                                                                                                                                                                                    allCompletedInfo,...
                                                                                                                                                                                                                                    sInfoPortName,...
                                                                                                                                                                                                                                    instancePortName,...
                                                                                                                                                                                                                                    varNamesInfo,...
                                                                                                                                                                                                                                    simStructOptions,...
                                                                                                                                                                                                                                    outputType,...
                                                                                                                                                                                                                                    generateInstancePortsFcn)
                                                                                                                                                                                                                                    if nargin<11
                                                                                                                                                                                                                                        generateInstancePortsFcn=@generateInstancePortsBody;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    if nargin<10
                                                                                                                                                                                                                                        outputType='void';
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    sig=sprintf('%s *%s(SimStruct *S, int_T idx)',outputType,functionName);
                                                                                                                                                                                                                                    stubInfo=newSimStructStub(functionName,sig,outputType);
                                                                                                                                                                                                                                    stubInfo.Line=writer.beginStr();

                                                                                                                                                                                                                                    numInstances=numel(allCompletedInfo);
                                                                                                                                                                                                                                    beginInstances(writer,sig,varNamesInfo,numInstances,simStructOptions);
                                                                                                                                                                                                                                    for ii=1:numel(allCompletedInfo)
                                                                                                                                                                                                                                        varNames=variableNames{ii};
                                                                                                                                                                                                                                        instance=instances(ii);
                                                                                                                                                                                                                                        sInfo=allCompletedInfo(ii);

                                                                                                                                                                                                                                        sInfoPorts=sInfo.(sInfoPortName);
                                                                                                                                                                                                                                        instancePorts=instance.(instancePortName);
                                                                                                                                                                                                                                        beginCurrentInstance(writer,varNamesInfo,ii,numInstances);
                                                                                                                                                                                                                                        generateInstancePortsFcn(writer,sInfoPorts,instancePorts,varNames,outputType,simStructOptions);
                                                                                                                                                                                                                                        endCurrentInstance(writer,ii,numInstances)
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    endInstances(writer);
                                                                                                                                                                                                                                    stubInfo.Definition=writer.endStr();


                                                                                                                                                                                                                                    function preIncludeFile=generatePreInclude(mainFile,nameGenerator,allCompletedInfos,instances,varNamesInfo,simStructStubs,simStructOptions)
                                                                                                                                                                                                                                        directory=fileparts(mainFile);
                                                                                                                                                                                                                                        preIncludeFile=fullfile(directory,'simstruc_wrapper.h');





                                                                                                                                                                                                                                        varsMacro=sprintf('#define %s(x) \\\n  %s()',varNamesInfo.VarsMacro,varNamesInfo.VarsMacro);
                                                                                                                                                                                                                                        if simStructOptions.UseInstanceVar
                                                                                                                                                                                                                                            varsMacro=sprintf('%s;\\\n  EXTERN int_T %s',varsMacro,varNamesInfo.InstanceVar);
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        if~simStructOptions.FunctionWrappers
                                                                                                                                                                                                                                            varsMacro=sprintf('%s;\\\n  EXTERN int_T %s',varsMacro,varNamesInfo.IndexVar);
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        for infoIndex=1:numel(instances)
                                                                                                                                                                                                                                            sldvInfo=instances(infoIndex);
                                                                                                                                                                                                                                            completedInfo=allCompletedInfos(infoIndex);

                                                                                                                                                                                                                                            instanceName=get_encoded_instance_name(infoIndex);
                                                                                                                                                                                                                                            variableNames=generateVariableNames(completedInfo,nameGenerator,instanceName);

                                                                                                                                                                                                                                            for kk=1:numel(sldvInfo.InputPortInfo)
                                                                                                                                                                                                                                                originalName=completedInfo.Inputs(kk).Name;
                                                                                                                                                                                                                                                inputName=variableNames(originalName);
                                                                                                                                                                                                                                                inputDims=sldvInfo.InputPortInfo(kk).Dim;

                                                                                                                                                                                                                                                varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                completedInfo.Inputs(kk),...
                                                                                                                                                                                                                                                inputDims,...
                                                                                                                                                                                                                                                inputName,'EXTERN'...
                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                            for kk=1:numel(sldvInfo.ParameterPortInfo)
                                                                                                                                                                                                                                                originalName=completedInfo.Parameters(kk).Name;
                                                                                                                                                                                                                                                paramName=variableNames(originalName);
                                                                                                                                                                                                                                                paramDims=sldvInfo.ParameterPortInfo(kk).Dim;

                                                                                                                                                                                                                                                if sldvInfo.ParameterPortInfo(kk).HasValue&&...
                                                                                                                                                                                                                                                    canWriteValue(sldvInfo.ParameterPortInfo(kk).Value)
                                                                                                                                                                                                                                                    qualifiers='EXTERN const';
                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                    qualifiers='EXTERN';
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                completedInfo.Parameters(kk),...
                                                                                                                                                                                                                                                paramDims,...
                                                                                                                                                                                                                                                paramName,qualifiers...
                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            for kk=1:numel(sldvInfo.DialogParameterInfo)
                                                                                                                                                                                                                                                originalName=completedInfo.DialogParameters(kk).Name;
                                                                                                                                                                                                                                                paramName=variableNames(originalName);
                                                                                                                                                                                                                                                paramDims=sldvInfo.DialogParameterInfo(kk).Dim;

                                                                                                                                                                                                                                                if sldvInfo.DialogParameterInfo(kk).HasValue&&...
                                                                                                                                                                                                                                                    canWriteValue(sldvInfo.DialogParameterInfo(kk).Value)
                                                                                                                                                                                                                                                    qualifiers='EXTERN const';
                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                    qualifiers='EXTERN';
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                completedInfo.DialogParameters(kk),...
                                                                                                                                                                                                                                                paramDims,...
                                                                                                                                                                                                                                                paramName,qualifiers,...
true...
                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                            for kk=1:numel(completedInfo.DWorks)
                                                                                                                                                                                                                                                sDwork=completedInfo.DWorks(kk);
                                                                                                                                                                                                                                                varIndex=sDwork.VarIndex;
                                                                                                                                                                                                                                                originalName=sDwork.Name;
                                                                                                                                                                                                                                                dworkName=nameGenerator.varName(originalName,instanceName);

                                                                                                                                                                                                                                                if varIndex>0&&varIndex<=numel(sldvInfo.DWorkInfo)

                                                                                                                                                                                                                                                    iDWork=sldvInfo.DWorkInfo(varIndex);

                                                                                                                                                                                                                                                    varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                    sDwork,...
                                                                                                                                                                                                                                                    iDWork.Dim,...
                                                                                                                                                                                                                                                    dworkName,'EXTERN'...
                                                                                                                                                                                                                                                    );
                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                    varsMacro=sprintf('%s;\\\n  EXTERN char* %s',varsMacro,dworkName);
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                            for kk=1:numel(sldvInfo.OutputPortInfo)
                                                                                                                                                                                                                                                originalName=completedInfo.Outputs(kk).Name;
                                                                                                                                                                                                                                                outputName=variableNames(originalName);
                                                                                                                                                                                                                                                outputDims=sldvInfo.OutputPortInfo(kk).Dim;

                                                                                                                                                                                                                                                varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                completedInfo.Outputs(kk),...
                                                                                                                                                                                                                                                outputDims,...
                                                                                                                                                                                                                                                outputName,'EXTERN'...
                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                            for kk=1:numel(sldvInfo.DiscStateInfo)
                                                                                                                                                                                                                                                originalName=completedInfo.DiscreteStates(kk).Name;
                                                                                                                                                                                                                                                discName=variableNames(originalName);
                                                                                                                                                                                                                                                discDims=sldvInfo.DiscStateInfo(kk).Dim;

                                                                                                                                                                                                                                                varsMacro=generatePreIncludeVar(varsMacro,...
                                                                                                                                                                                                                                                completedInfo.DiscreteStates(kk),...
                                                                                                                                                                                                                                                discDims,...
                                                                                                                                                                                                                                                discName,'EXTERN');
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end



                                                                                                                                                                                                                                        for ii=1:numel(simStructStubs)
                                                                                                                                                                                                                                            if simStructStubs(ii).IsInternal
                                                                                                                                                                                                                                                varsMacro=sprintf('%s;\\\n EXTERN %s',varsMacro,simStructStubs(ii).Declaration);
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        variableNames=cell(1,numel(instances));
                                                                                                                                                                                                                                        for ii=1:numel(instances)
                                                                                                                                                                                                                                            variableNames{ii}=generateVariableNames(allCompletedInfos(ii),...
                                                                                                                                                                                                                                            nameGenerator,...
                                                                                                                                                                                                                                            get_encoded_instance_name(ii));
                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                        writer=sldv.code.internal.CWriter(preIncludeFile,'w');

                                                                                                                                                                                                                                        writer.print('#ifdef __cplusplus\n');
                                                                                                                                                                                                                                        writer.print('#define EXTERN extern "C"\n');
                                                                                                                                                                                                                                        writer.print('#else /* __cplusplus */\n');
                                                                                                                                                                                                                                        writer.print('#define EXTERN extern\n');
                                                                                                                                                                                                                                        writer.print('#endif /* __cplusplus */\n\n');


                                                                                                                                                                                                                                        writer.print('%s\n\n',varsMacro);

                                                                                                                                                                                                                                        if~simStructOptions.FunctionWrappers

                                                                                                                                                                                                                                            writer.print('#define %s %s\n',nameGenerator.ssFunction('ssGetInputPortRealSignal'),...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetInputPortSignal'));
                                                                                                                                                                                                                                            writer.print('#define %s %s\n',nameGenerator.ssFunction('ssGetOutputPortRealSignal'),...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetOutputPortSignal'));

                                                                                                                                                                                                                                            writer.print('#define %s(x, i)      ((%s(x, i))[1])\n',...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetSFcnParam___N'),...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetSFcnParam___Dimensions'));
                                                                                                                                                                                                                                            writer.print('#define %s(x, i)      ((%s(x, i))[0])\n',...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetSFcnParam___M'),...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetSFcnParam___Dimensions'));


                                                                                                                                                                                                                                            writer.print('#define %s %s\n',...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetRealDiscStates'),...
                                                                                                                                                                                                                                            nameGenerator.ssFunction('ssGetDiscStates'));

                                                                                                                                                                                                                                            generateGetPortSignalMacro(writer,nameGenerator.ssFunction('ssGetInputPortSignal'),...
                                                                                                                                                                                                                                            variableNames,instances,allCompletedInfos,...
                                                                                                                                                                                                                                            'Inputs','InputPortInfo',varNamesInfo);
                                                                                                                                                                                                                                            generateGetPortSignalMacro(writer,nameGenerator.ssFunction('ssGetOutputPortSignal'),...
                                                                                                                                                                                                                                            variableNames,instances,allCompletedInfos,...
                                                                                                                                                                                                                                            'Outputs','OutputPortInfo',varNamesInfo);
                                                                                                                                                                                                                                            generateGetPortSignalMacro(writer,nameGenerator.ssFunction('ssGetRunTimeParamInfo___Data'),...
                                                                                                                                                                                                                                            variableNames,instances,allCompletedInfos,...
                                                                                                                                                                                                                                            'Parameters','ParameterPortInfo',varNamesInfo);
                                                                                                                                                                                                                                            generateGetPortSignalMacro(writer,nameGenerator.ssFunction('ssGetSFcnParam___Data'),...
                                                                                                                                                                                                                                            variableNames,instances,allCompletedInfos,...
                                                                                                                                                                                                                                            'DialogParameters','DialogParameterInfo',varNamesInfo);
                                                                                                                                                                                                                                            generateGetPortSignalMacro(writer,nameGenerator.ssFunction('ssGetDWork'),...
                                                                                                                                                                                                                                            variableNames,instances,allCompletedInfos,...
                                                                                                                                                                                                                                            'DWorks','DWorkInfo',varNamesInfo);

                                                                                                                                                                                                                                            writer.print('#define __MW_INSTRUM_SFCNMETHOD_ENTER(S) ((void)0)\n');
                                                                                                                                                                                                                                            writer.print('#define __MW_INSTRUM_SFCNMETHOD_EXIT(S) ((void)0)\n');
                                                                                                                                                                                                                                            writer.print('#define __MW_INSTRUM_SFCNMETHOD_EXIT_TERMINATE(S) ((void)0)\n');
                                                                                                                                                                                                                                            writer.print('#define __MW_INSTRUM_SFCNMETHOD_ENTER_START(S) ((void)0)\n');
                                                                                                                                                                                                                                            writer.print('#define __MW_INSTRUM_SFCNUPLOAD_COVERAGE_SYNTHESIS(S) ((void)0)\n');
                                                                                                                                                                                                                                            writer.print('\n');
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        function out=generateCodeInformation(msgId,descVal,sid,objKind,fileKind)

                                                                                                                                                                                                                                            if nargin<4
                                                                                                                                                                                                                                                objKind='variable';
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            if nargin<5
                                                                                                                                                                                                                                                fileKind='sfcnMain';
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            fullName=Simulink.ID.getFullName(sid);
                                                                                                                                                                                                                                            msg=message(msgId,descVal,fullName);
                                                                                                                                                                                                                                            str=msg.getString();

                                                                                                                                                                                                                                            out.objKind=objKind;
                                                                                                                                                                                                                                            out.fileKind=fileKind;
                                                                                                                                                                                                                                            out.msg=str;




                                                                                                                                                                                                                                            function stubInfo=beginSsGetDataTypeSwitch(writer,functionName,retType)
                                                                                                                                                                                                                                                sig=sprintf('%s %s(SimStruct *S, DTypeId dataTypeId)',retType,functionName);
                                                                                                                                                                                                                                                stubInfo=newSimStructStub(functionName,sig,retType);
                                                                                                                                                                                                                                                stubInfo.Line=writer.beginStr();
                                                                                                                                                                                                                                                writer.beginBlock('\n\n%s {',sig);
                                                                                                                                                                                                                                                writer.beginBlock('\nswitch(dataTypeId) {');


                                                                                                                                                                                                                                                function writeSsGetDataTypeCase(writer,caseId,caseValue)
                                                                                                                                                                                                                                                    if ischar(caseId)
                                                                                                                                                                                                                                                        writer.print('\ncase %s:',caseId);
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        writer.print('\ncase %d:',caseId);
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if ischar(caseValue)
                                                                                                                                                                                                                                                        writer.print('\n    return %s;',caseValue);
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        writer.print('\n    return %d;',caseValue);
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    function writeSsGetDataTypeDefault(writer,defaultValue)
                                                                                                                                                                                                                                                        writer.print('\ndefault:');
                                                                                                                                                                                                                                                        if ischar(defaultValue)
                                                                                                                                                                                                                                                            writer.print('\n    return %s;',defaultValue);
                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                            writer.print('\n    return %d;',defaultValue);
                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                        function writeSsGetDataTypeRandomDefault(writer,returnType,defaultValue)
                                                                                                                                                                                                                                                            if nargin<3
                                                                                                                                                                                                                                                                defaultValue='0';
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            if nargin<2
                                                                                                                                                                                                                                                                returnType='int';
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            writer.print('\ndefault: {');

                                                                                                                                                                                                                                                            if ischar(defaultValue)
                                                                                                                                                                                                                                                                writer.print('\n    volatile %s rand_result = %s;',returnType,defaultValue);
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                writer.print('\n    volatile %s rand_result = %d;',returnType,defaultValue);
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            writer.print('\n    return rand_result;');
                                                                                                                                                                                                                                                            writer.print('\n}'),



                                                                                                                                                                                                                                                            function endSsGetDataTypeSwitch(writer)
                                                                                                                                                                                                                                                                writer.endBlock('\n}\n');
                                                                                                                                                                                                                                                                writer.endBlock('\n}\n');


                                                                                                                                                                                                                                                                function stubInfo=generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                    functionName,outputType,...
                                                                                                                                                                                                                                                                    outputFcn,...
                                                                                                                                                                                                                                                                    varargin)
                                                                                                                                                                                                                                                                    p=inputParser;
                                                                                                                                                                                                                                                                    p.addOptional('DefaultValue',0);
                                                                                                                                                                                                                                                                    p.addOptional('VolatileDefault',false);
                                                                                                                                                                                                                                                                    p.parse(varargin{:});

                                                                                                                                                                                                                                                                    defaultValue=p.Results.DefaultValue;
                                                                                                                                                                                                                                                                    isVolatileDefault=p.Results.VolatileDefault;

                                                                                                                                                                                                                                                                    stubInfo=beginSsGetDataTypeSwitch(writer,functionName,outputType);


                                                                                                                                                                                                                                                                    types=typeInfo.PrimitiveTypes.keys();
                                                                                                                                                                                                                                                                    for ii=1:numel(types)
                                                                                                                                                                                                                                                                        typeName=types{ii};
                                                                                                                                                                                                                                                                        type=typeInfo.PrimitiveTypes(typeName);
                                                                                                                                                                                                                                                                        writeSsGetDataTypeCase(writer,typeName,outputFcn(type));
                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                    userTypes=typeInfo.UserTypes.keys();
                                                                                                                                                                                                                                                                    for ii=1:numel(userTypes)
                                                                                                                                                                                                                                                                        currentInfo=typeInfo.UserTypes(userTypes{ii});
                                                                                                                                                                                                                                                                        t=currentInfo.Type;
                                                                                                                                                                                                                                                                        if isa(t,'embedded.numerictype')
                                                                                                                                                                                                                                                                            writeSsGetDataTypeCase(writer,currentInfo.DTypeID,outputFcn(t));
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                    if isVolatileDefault
                                                                                                                                                                                                                                                                        writeSsGetDataTypeRandomDefault(writer,outputType,defaultValue);
                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                        writeSsGetDataTypeDefault(writer,defaultValue);
                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                    endSsGetDataTypeSwitch(writer);
                                                                                                                                                                                                                                                                    stubInfo.Definition=writer.endStr();


                                                                                                                                                                                                                                                                    function res=getFxpCategory(t)
                                                                                                                                                                                                                                                                        signPrefix='';
                                                                                                                                                                                                                                                                        if t.isfloat
                                                                                                                                                                                                                                                                            switch t.WordLength
                                                                                                                                                                                                                                                                            case 32
                                                                                                                                                                                                                                                                                res='FXP_STORAGE_SINGLE';
                                                                                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                                                                                res='FXP_STORAGE_DOUBLE';
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                            if~t.SignednessBool
                                                                                                                                                                                                                                                                                signPrefix='U';
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            res=sprintf('FXP_STORAGE_%sINT%d',signPrefix,t.WordLength);
                                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                                        function trivial=fxpIsScalingTrivial(t)
                                                                                                                                                                                                                                                                            if t.Bias==0&&t.Slope==1
                                                                                                                                                                                                                                                                                trivial=1;
                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                trivial=0;
                                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                                            function res=fxpIsScalingPow2(t)
                                                                                                                                                                                                                                                                                if t.Bias==0&&t.Slope==1&&t.isbinarypointscalingset
                                                                                                                                                                                                                                                                                    res=1;
                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                    res=0;
                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                function generateFixedPointStubs(writer,typeInfo)
                                                                                                                                                                                                                                                                                    writer.print('\n\n/* Fixedpoint functions (if fixedpoint.h has been included) */\n\n');
                                                                                                                                                                                                                                                                                    writer.print('#ifdef FIXPOINT_SPEC_H\n');

                                                                                                                                                                                                                                                                                    generateDataTypeSizeFcn(writer,'size_t','ssGetDataTypeStorageContainerSize',typeInfo);

                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeStorageContainCat','fxpStorageContainerCategory',...
                                                                                                                                                                                                                                                                                    @getFxpCategory,...
                                                                                                                                                                                                                                                                                    'DefaultValue','FXP_STORAGE_UINT8',...
                                                                                                                                                                                                                                                                                    'VolatileDefault',true);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeIsFxpFltApiCompat','int',...
                                                                                                                                                                                                                                                                                    @(t)1,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,...
                                                                                                                                                                                                                                                                                    'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeIsFixedPoint','int',...
                                                                                                                                                                                                                                                                                    @(t)t.isfixed,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeIsFloatingPoint','int',...
                                                                                                                                                                                                                                                                                    @(t)t.isfloat,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFxpWordLength','int',...
                                                                                                                                                                                                                                                                                    @(t)t.WordLength,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFxpContainWordLen','int',...
                                                                                                                                                                                                                                                                                    @(t)t.WordLength,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFxpIsSigned','int',...
                                                                                                                                                                                                                                                                                    @(t)t.SignednessBool,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFxpIsScalingTrivial','int',...
                                                                                                                                                                                                                                                                                    @fxpIsScalingTrivial,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFxpIsScalingPow2','int',...
                                                                                                                                                                                                                                                                                    @fxpIsScalingPow2,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFractionLength','int',...
                                                                                                                                                                                                                                                                                    @(t)t.FractionLength,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeBias','double',...
                                                                                                                                                                                                                                                                                    @(t)sprintf('%f',t.Bias),...
                                                                                                                                                                                                                                                                                    'DefaultValue','0.0','VolatileDefault',false);
                                                                                                                                                                                                                                                                                    generateGetDataTypeFunction(writer,typeInfo,...
                                                                                                                                                                                                                                                                                    'ssGetDataTypeFixedExponent','int',...
                                                                                                                                                                                                                                                                                    @(t)t.FixedExponent,...
                                                                                                                                                                                                                                                                                    'DefaultValue',0,'VolatileDefault',false);

                                                                                                                                                                                                                                                                                    writer.print('#endif /* FIXPOINT_SPEC_H */\n\n');



