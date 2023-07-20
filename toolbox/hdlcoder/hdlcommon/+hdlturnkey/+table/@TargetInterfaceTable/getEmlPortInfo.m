function[portInfo,inferenceReport,errorMessage]=getEmlPortInfo(obj,inputDataParams,designFcnFilepath)





    portInfo='';
    errorMessage='';
    [designFcnDir,designFcnName,~]=fileparts(designFcnFilepath);


    if isempty(inputDataParams)
        cgInfo=obj.hTurnkey.hD.hCodeGen.hCHandle.cgInfo;


        if~isempty(cgInfo)
            inputDataParams=cgInfo.inputITCs;
        end
    end

    exInputTypes=coder.internal.Float2FixedConverter.convertTypesToExArgs(inputDataParams);
    mexDesignFcnName=[designFcnName,'_mex'];


    codegenCmd=@()codegen('-report','-args',exInputTypes,'-o',mexDesignFcnName,designFcnFilepath);
    inferenceReport=coder.internal.Helper.fevalInPath(codegenCmd,designFcnDir);
    if(isfield(inferenceReport,'internal')&&isa(inferenceReport.internal,'MException'))
        rethrow(inferenceReport.internal);
    end

    if~inferenceReport.summary.passed

        return
    end

    [inputList,outputList]=coder.internal.MTREEUtils.fcnInputOutputParamNames(mtree(fileread(designFcnFilepath)).root);
    structIOVariables={};
    for ii=1:length(inferenceReport.inference.Functions)

        fcnInferenceInfo=inferenceReport.inference.Functions(ii);


        if strcmpi(fcnInferenceInfo.FunctionName,designFcnName)
            [unicodemap,scriptText]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(inferenceReport.inference.Scripts(fcnInferenceInfo.ScriptID).ScriptText);
            allInputAndOuputVarsMxInfoLocations=fcnInferenceInfo.MxInfoLocations.findobj('NodeTypeName','inputVar','-or','NodeTypeName','outputVar');
            portInfoIndex=1;
            for jj=1:length(allInputAndOuputVarsMxInfoLocations)
                MxInfoLocations=allInputAndOuputVarsMxInfoLocations(jj);
                start=MxInfoLocations.TextStart+1;
                textLength=MxInfoLocations.TextLength;
                [start,textLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,start,textLength);
                stop=start+textLength-1;

                SymbolName=scriptText(start:stop);

                typeInfo=inferenceReport.inference.MxInfos{MxInfoLocations.MxInfoID};
                MxTypeInfo=inferenceReport.inference.MxInfos{MxInfoLocations.MxInfoID};


                if strcmpi(typeInfo.Class,'struct')
                    structIOVariables{end+1}=SymbolName;%#ok<AGROW>
                    continue;

                elseif strcmpi(MxTypeInfo.Class,'embedded.fi')
                    numericTypeInfo=inferenceReport.inference.MxArrays{MxTypeInfo.NumericTypeID};
                    isSigned=numericTypeInfo.SignednessBool;
                    WL=numericTypeInfo.WordLength;
                    FL=numericTypeInfo.FractionLength;
                    isComplex=typeInfo.Complex;

                    SLDataTypeStr=tostringInternalSlName(numericTypeInfo);


                elseif strcmpi(MxTypeInfo.Class,'logical')
                    FL=0;
                    WL=1;
                    isSigned=0;
                    isComplex=0;
                    SLDataTypeStr='ufix1';


                else
                    nt=numerictype(MxTypeInfo.Class);
                    WL=nt.WordLength;
                    FL=0;
                    isSigned=nt.SignednessBool;
                    isComplex=typeInfo.Complex;
                    SLDataTypeStr=MxTypeInfo.Class;
                end



                indexNonscalarDim=find(typeInfo.Size~=1);
                if isempty(indexNonscalarDim)
                    dims=1;
                else
                    dims=typeInfo.Size(indexNonscalarDim);
                end

                portInfo(portInfoIndex).PortName=SymbolName;
                if strcmpi(MxInfoLocations.NodeTypeName,'outputVar')
                    portInfo(portInfoIndex).PortType=hdlturnkey.IOType.OUT;
                    portIndex=find(cellfun(@(x)strcmpi(x,SymbolName),outputList)>0)-1;
                else
                    portInfo(portInfoIndex).PortType=hdlturnkey.IOType.IN;
                    portIndex=find(cellfun(@(x)strcmpi(x,SymbolName),inputList)>0)-1;
                end

                portInfo(portInfoIndex).PortIndex=portIndex;
                portInfo(portInfoIndex).Signed=isSigned;
                portInfo(portInfoIndex).WordLength=WL;
                portInfo(portInfoIndex).FractionLength=FL;
                portInfo(portInfoIndex).isBoolean=strcmpi(typeInfo.Class,'logical');
                portInfo(portInfoIndex).isSingle=strcmpi(typeInfo.Class,'single');
                portInfo(portInfoIndex).isComplex=isComplex;
                portInfo(portInfoIndex).isDouble=strcmpi(typeInfo.Class,'double');
                portInfo(portInfoIndex).isHalf=strcmpi(typeInfo.Class,'half');
                portInfo(portInfoIndex).isVector=~isempty(indexNonscalarDim);
                portInfo(portInfoIndex).Dimension=dims;
                portInfo(portInfoIndex).SLDataType=SLDataTypeStr;

                portInfoIndex=portInfoIndex+1;
            end


            break;
        end

    end

    if~isempty(structIOVariables)


        errorMessage=message('hdlcommon:workflow:UnsupportedIPCoreTurnkeyStructInputs',strjoin(structIOVariables,', ')).getString();
    end


    mexDesignFcnFile=[mexDesignFcnName,'.',mexext];
    clear(mexDesignFcnFile);
    delete(mexDesignFcnFile);
