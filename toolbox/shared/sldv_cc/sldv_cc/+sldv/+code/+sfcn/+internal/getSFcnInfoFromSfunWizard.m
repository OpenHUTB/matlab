function sldvInfo=getSFcnInfoFromSfunWizard(wizardData)









    numContinuous=str2double(wizardData.SfunWizardData.NumberOfContinuousStates);
    if numContinuous~=0
        msg=message('sldv_sfcn:sldv_sfcn:ContinuousStatesNotSupported');
        throw(MException('sldv:ContinuousStatesNotSupported',...
        msg.getString()));
    end

    numDiscrete=str2double(wizardData.SfunWizardData.NumberOfDiscreteStates);

    sldvInfo=sldv.code.sfcn.internal.StaticSFcnInfoWriter(wizardData.LangExt);

    sfunData=wizardData.SfunWizardData;

    hasInputs=str2double(sfunData.InputPortWidth)~=0;
    hasOutputs=str2double(sfunData.OutputPortWidth)~=0;

    if hasInputs
        addPorts(sldvInfo,sldvInfo.InputType,sfunData.InputPorts);
    end

    if hasOutputs
        addPorts(sldvInfo,sldvInfo.OutputType,sfunData.OutputPorts);
    end

    if~isempty(sfunData.NumberOfParameters)
        numParameters=str2double(sfunData.NumberOfParameters);
    else
        numParameters=0;
    end

    addPorts(sldvInfo,sldvInfo.ParameterType,sfunData.Parameters,...
    numParameters);

    if numDiscrete>0
        sldvInfo.addVarDecl(sldvInfo.DiscreteType,'xD','real_T',1);
    end

    useSimStruct=str2double(sfunData.UseSimStruct)~=0;
    if useSimStruct
        sldvInfo.addVarDecl(sldvInfo.SimStructType,'S','SimStruct',1);
        sldvInfo.HasSimStruct=true;
    end


    declareOutput(sldvInfo,sfunData,hasInputs,hasOutputs,numParameters,numDiscrete);
    if numDiscrete>0
        declareUpdate(sldvInfo,sfunData,hasInputs,hasOutputs,numParameters);
    end

    sldvInfo.Transpose2DMatrix=false;


    if useSimStruct
        mainFile=sprintf('#include <simstruc.h>\n');
    else
        mainFile=sprintf('#include <tmwtypes.h>\n#include <string.h>\n');
    end




    [mainFile,hasBusHeaderFile]=getBusHeaders(mainFile,sfunData);
    if hasBusHeaderFile
        busHeaderFile=[sfunData.SfunName,'_bus.h'];
        mainFile=sprintf('#include "%s"\n',busHeaderFile);
    end

    mainFile=sprintf('%s%s\n\n%s\n',mainFile,sfunData.IncludeHeadersText,sfunData.ExternalDeclaration);

    modelName=bdroot(wizardData.blockName);
    targetLang=get_param(modelName,'TargetLang');
    targetIsCxx=strcmpi(targetLang,'C++');


    outputSig=getOutputSignature(sfunData,hasInputs,hasOutputs,numParameters,numDiscrete);
    if~targetIsCxx
        outputSig=getExternCSignature(outputSig);
    end
    if numDiscrete>0
        updateSig=getUpdateSignature(sfunData,hasInputs,hasOutputs,numParameters,numDiscrete);
        if~targetIsCxx
            updateSig=getExternCSignature(updateSig);
        end
    else
        updateSig='';
    end

    mainFile=sprintf('%s\n%s\n%s\n\n',mainFile,outputSig,updateSig);

    sldvInfo.setMainFileBody(mainFile);


    function addPorts(sldvSFcnInfo,portType,vars,numPorts)
        if nargin<4
            numPorts=numel(vars.Name);
        end

        for ii=1:numPorts
            name=vars.Name{ii};
            type=getVarType(vars,ii);

            sldvSFcnInfo.addVarDecl(portType,name,type,ii);
        end



        function argIndex=addFunctionArgs(sldvSFcnInfo,functionName,vars,argIndex)
            numInputs=numel(vars.Name);
            for ii=1:numInputs
                name=vars.Name{ii};
                type=getVarType(vars,ii);

                sldvSFcnInfo.addFunctionArg(functionName,...
                sldvSFcnInfo.RhsParam,...
                argIndex,...
                name,...
                type,...
                'pointer',...
                true);
                argIndex=argIndex+1;
            end


            function argIndex=addFunctionArgsWithSize(sldvSFcnInfo,functionName,vars,argIndex,numInputs)

                for ii=1:numInputs
                    name=vars.Name{ii};
                    type=getVarType(vars,ii);

                    sldvSFcnInfo.addFunctionArg(functionName,...
                    sldvSFcnInfo.RhsParam,...
                    argIndex,...
                    name,...
                    type,...
                    'pointer',...
                    true);
                    argIndex=argIndex+1;
                    sizeName=sprintf('numel(%s)',name);
                    sldvSFcnInfo.addFunctionArg(functionName,...
                    sldvSFcnInfo.RhsParam,...
                    argIndex,...
                    sizeName,...
                    'SizeArg',...
                    'direct',...
                    true);
                    argIndex=argIndex+1;
                end


                function argIndex=addParameterSizes(sldvSFcnInfo,functionName,vars,argIndex,numPorts)


                    if nargin<5
                        numPorts=numel(vars.Name);
                    end

                    for ii=1:numPorts
                        dimensionVector=str2num(vars.Dimensions{ii});
                        numRows=dimensionVector(1);

                        if numRows<0

                            sizeName=sprintf('numel(%s)',vars.Name{ii});
                            sldvSFcnInfo.addFunctionArg(functionName,...
                            sldvSFcnInfo.RhsParam,...
                            argIndex,...
                            sizeName,...
                            'SizeArg',...
                            'direct',...
                            true);

                            argIndex=argIndex+1;
                        end
                    end


                    function argIndex=addDiscreteArgs(sldvInfo,functionType,argIndex,isConst)
                        if isConst
                            paramType='const real_T';
                        else
                            paramType='real_T';
                        end
                        sldvInfo.addFunctionArg(functionType,...
                        sldvInfo.RhsParam,argIndex,'xD',paramType,'pointer',true);
                        argIndex=argIndex+1;


                        function argIndex=addSimStructArg(sldvInfo,functionType,argIndex,sfunData)

                            useSimStruct=str2double(sfunData.UseSimStruct)~=0;
                            if useSimStruct
                                sldvInfo.addFunctionArg(functionType,...
                                sldvInfo.RhsParam,argIndex,'S','struct SimStruct','pointer',false);
                                argIndex=argIndex+1;
                            end



                            function declareOutput(sldvInfo,sfunData,hasInputs,hasOutputs,numParameters,numDiscrete)
                                functionType='Output';
                                functionName=[sfunData.SfunName,'_Outputs_wrapper'];
                                includeInputs=~strcmp(sfunData.DirectFeedThrough,'0');

                                sldvInfo.addFunctionSpec(functionType,functionName);
                                argIndex=1;
                                if includeInputs&&hasInputs
                                    argIndex=addFunctionArgs(sldvInfo,functionType,sfunData.InputPorts,argIndex);
                                end
                                if hasOutputs
                                    argIndex=addFunctionArgs(sldvInfo,functionType,sfunData.OutputPorts,argIndex);
                                end

                                if numDiscrete>0
                                    argIndex=addDiscreteArgs(sldvInfo,functionType,argIndex,true);
                                end

                                if numParameters>0
                                    argIndex=addFunctionArgsWithSize(sldvInfo,functionType,sfunData.Parameters,argIndex,numParameters);
                                end

                                argIndex=addParameterSizes(sldvInfo,functionType,sfunData.OutputPorts,argIndex);

                                if includeInputs&&hasInputs
                                    argIndex=addParameterSizes(sldvInfo,functionType,sfunData.InputPorts,argIndex);
                                end

                                addSimStructArg(sldvInfo,functionType,argIndex,sfunData);


                                function declareUpdate(sldvInfo,sfunData,hasInputs,hasOutputs,numParameters)


                                    functionType='Update';
                                    sldvInfo.addFunctionSpec(functionType,[sfunData.SfunName,'_Update_wrapper']);

                                    argIndex=1;
                                    if hasInputs
                                        argIndex=addFunctionArgs(sldvInfo,functionType,sfunData.InputPorts,argIndex);
                                    end

                                    if hasOutputs
                                        argIndex=addFunctionArgs(sldvInfo,functionType,sfunData.OutputPorts,argIndex);
                                    end
                                    argIndex=addDiscreteArgs(sldvInfo,functionType,argIndex,false);

                                    if numParameters>0
                                        argIndex=addFunctionArgsWithSize(sldvInfo,functionType,sfunData.Parameters,argIndex,numParameters);
                                    end

                                    if hasOutputs
                                        argIndex=addParameterSizes(sldvInfo,functionType,sfunData.OutputPorts,argIndex);
                                    end

                                    if hasInputs
                                        argIndex=addParameterSizes(sldvInfo,functionType,sfunData.InputPorts,argIndex);
                                    end
                                    addSimStructArg(sldvInfo,functionType,argIndex,sfunData);


                                    function type=getVarType(vars,ii)
                                        if isfield(vars,'Bus')&&strcmp(vars.Bus{ii},'on')
                                            type=vars.Busname{ii};
                                        elseif strcmp(vars.DataType{ii},'fixpt')||strcmp(vars.DataType{ii},'cfixpt')

                                            if strcmp(vars.Complexity{ii},'COMPLEX_YES')
                                                complexPrefix='c';
                                            else
                                                complexPrefix='';
                                            end
                                            if strcmp(vars.IsSigned{ii},'0')
                                                signPrefix='u';
                                            else
                                                signPrefix='';
                                            end
                                            wordLength=str2double(vars.WordLength{ii});
                                            if wordLength<=8
                                                wordLength=8;
                                            elseif wordLength<=16
                                                wordLength=16;
                                            elseif wordLength<=32
                                                wordLength=32;
                                            else
                                                wordLength=64;
                                            end
                                            type=sprintf('%s%sint%d_T',complexPrefix,signPrefix,wordLength);
                                        else
                                            type=vars.DataType{ii};
                                        end


                                        function args=getFunctionArgs(vars,args,isConst)
                                            if nargin<3
                                                isConst=false;
                                            end

                                            if isConst
                                                modifier='const ';
                                            else
                                                modifier='';
                                            end

                                            numInputs=numel(vars.Name);
                                            for ii=1:numInputs
                                                name=vars.Name{ii};
                                                type=getVarType(vars,ii);

                                                args{end+1}=sprintf('%s%s *%s',modifier,type,name);%#ok;
                                            end


                                            function args=getFunctionArgsWithSize(vars,numInputs,args)

                                                for ii=1:numInputs
                                                    name=vars.Name{ii};
                                                    type=getVarType(vars,ii);

                                                    args{end+1}=sprintf('const %s *%s',type,name);%#ok;
                                                    args{end+1}=sprintf('const int_T');%#ok;
                                                end

                                                function args=getParameterSizes(vars,args,numPorts)


                                                    if nargin<5
                                                        numPorts=numel(vars.Name);
                                                    end

                                                    for ii=1:numPorts
                                                        dimensionVector=str2num(vars.Dimensions{ii});
                                                        numRows=dimensionVector(1);

                                                        if numRows<0
                                                            args{end+1}='const int_T';%#ok;
                                                        end
                                                    end


                                                    function externC=getExternCSignature(plainSignature)
                                                        externC=sprintf('#ifdef __cplusplus\nextern "C"\n#endif\n%s',plainSignature);


                                                        function sig=getOutputSignature(sfunData,hasInputs,hasOutputs,numParameters,numDiscrete)
                                                            functionName=[sfunData.SfunName,'_Outputs_wrapper'];
                                                            includeInputs=~strcmp(sfunData.DirectFeedThrough,'0');

                                                            args={};

                                                            if includeInputs&&hasInputs
                                                                args=getFunctionArgs(sfunData.InputPorts,args,true);
                                                            end
                                                            if hasOutputs
                                                                args=getFunctionArgs(sfunData.OutputPorts,args);
                                                            end

                                                            if numDiscrete>0
                                                                args{end+1}='const real_T *xD';
                                                            end

                                                            if numParameters>0
                                                                args=getFunctionArgsWithSize(sfunData.Parameters,numParameters,args);
                                                            end

                                                            args=getParameterSizes(sfunData.OutputPorts,args);

                                                            if includeInputs&&hasInputs
                                                                args=getParameterSizes(sfunData.InputPorts,args);
                                                            end

                                                            useSimStruct=str2double(sfunData.UseSimStruct)~=0;
                                                            if useSimStruct
                                                                args{end+1}='SimStruct*';
                                                            end

                                                            sig=sprintf('void %s(%s);',functionName,strjoin(args,', '));


                                                            function sig=getUpdateSignature(sfunData,hasInputs,hasOutputs,numParameters,numDiscrete)


                                                                functionName=[sfunData.SfunName,'_Update_wrapper'];
                                                                args={};

                                                                if hasInputs
                                                                    args=getFunctionArgs(sfunData.InputPorts,args,true);
                                                                end

                                                                if hasOutputs
                                                                    args=getFunctionArgs(sfunData.OutputPorts,args);
                                                                end

                                                                if numDiscrete>0
                                                                    args{end+1}='real_T *xD';
                                                                end

                                                                if numParameters>0
                                                                    args=getFunctionArgsWithSize(sfunData.Parameters,numParameters,args);
                                                                end

                                                                if hasOutputs
                                                                    args=getParameterSizes(sfunData.OutputPorts,args);
                                                                end

                                                                if hasInputs
                                                                    args=getParameterSizes(sfunData.InputPorts,args);
                                                                end
                                                                useSimStruct=str2double(sfunData.UseSimStruct)~=0;
                                                                if useSimStruct
                                                                    args{end+1}='SimStruct*';
                                                                end

                                                                sig=sprintf('void %s(%s);',functionName,strjoin(args,', '));


                                                                function[mainFile,hasBusHeader]=getBusHeadersForPorts(mainFile,ports,alreadyGenerated)
                                                                    hasBusHeader=false;
                                                                    for ii=1:numel(ports.Bus)
                                                                        if strcmp(ports.Bus{ii},'on')
                                                                            busName=ports.Busname{ii};
                                                                            if~alreadyGenerated.isKey(busName)
                                                                                slObj=evalin('base',busName);
                                                                                headerFile=strtrim(slObj.HeaderFile);
                                                                                alreadyGenerated(busName)=headerFile;

                                                                                if~isempty(headerFile)
                                                                                    mainFile=sprintf('%s#include "%s"\n',mainFile,headerFile);
                                                                                else
                                                                                    hasBusHeader=true;
                                                                                end
                                                                            end
                                                                        end
                                                                    end


                                                                    function[mainFile,hasBusHeader]=getBusHeaders(mainFile,sfunData)
                                                                        alreadyGenerated=containers.Map('KeyType','char','ValueType','char');

                                                                        [mainFile,busHeaderInput]=getBusHeadersForPorts(mainFile,sfunData.InputPorts,alreadyGenerated);
                                                                        [mainFile,busHeaderOutput]=getBusHeadersForPorts(mainFile,sfunData.OutputPorts,alreadyGenerated);
                                                                        hasBusHeader=busHeaderInput|busHeaderOutput;


