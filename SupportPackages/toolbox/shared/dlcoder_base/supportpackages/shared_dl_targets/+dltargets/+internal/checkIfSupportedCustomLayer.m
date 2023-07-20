function checkIfSupportedCustomLayer(layer,codegenLayerValidator)








    layerClassName=class(layer);


    assert(~coder.internal.hasPublicStaticMethod(layerClassName,'matlabCodegenRedirect'),'dlcoder_spkg:cnncodegen:DLCoderInternalError');

    cppClassName=dltargets.internal.getCustomLayerClassName(layer);

    targetLib=codegenLayerValidator.getTargetLib();

    if~dltargets.internal.hasCodegenPragmaInClassDef(layerClassName)
        if iCheckIfMWAuthoredCustomLayers(layerClassName)

            errMsg=message('dlcoder_spkg:cnncodegen:unsupported_layer',cppClassName,targetLib);
        else
            errMsg=message('dlcoder_spkg:cnncodegen:NoCodegenPragmaInCustomLayer',cppClassName);
        end
        codegenLayerValidator.handleError(layer,errMsg);
    end


    isLayerInDLNetwork=isa(codegenLayerValidator.getNetwork,'dlnetwork');
    if~dlcoderfeature('DLArrayInDAGCustomLayer')&&~isLayerInDLNetwork&&isa(layer,'nnet.layer.Formattable')
        errMsg=message('dlcoder_spkg:cnncodegen:FormattableNotSupported',cppClassName);
        codegenLayerValidator.handleError(layer,errMsg);
    end


    functionLayerMsg=iCheckFunctionLayerCompatibility(layer);
    if~isempty(functionLayerMsg)
        errMsg=functionLayerMsg;
        codegenLayerValidator.handleError(layer,errMsg);
    end


    internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    if(internalLayer{1}.NumStates>0)
        errMsg=message('dlcoder_spkg:cnncodegen:CustomLayersWithStateNotSupported',cppClassName);
        codegenLayerValidator.handleError(layer,errMsg);
    end


    metaClassData=metaclass(layer);
    metaClassProperties=metaClassData.PropertyList;
    thisClassPropertiesIdx=arrayfun(@(x)isequal(x.DefiningClass,metaClassData),metaClassProperties);
    thisClassUnaccessiblePropertiesIdx=arrayfun(@(x)strcmp(x.GetAccess,"private")||strcmp(x.GetAccess,"protected"),metaClassProperties(thisClassPropertiesIdx));


    if any(thisClassUnaccessiblePropertiesIdx)
        errMsg=message('dlcoder_spkg:cnncodegen:PrivateLayerParameter',cppClassName);
        codegenLayerValidator.handleError(layer,errMsg);
    end

    customClassPropertyNames=cell(1,nnz(thisClassPropertiesIdx));
    [customClassPropertyNames{:}]=metaClassProperties(thisClassPropertiesIdx).Name;

    for iProp=1:numel(customClassPropertyNames)
        paramVal=layer.(customClassPropertyNames{iProp});







        if((isa(paramVal,'double')||isa(paramVal,'single'))||...
            (isscalar(paramVal)&&(isnumeric(paramVal)||islogical(paramVal)))&&~isdlarray(paramVal))

        elseif(ischar(paramVal)||isstring(paramVal)||(iscell(paramVal)&&all(cellfun(@ischar,paramVal)))...
            &&~isdlarray(paramVal))

        else
            errMsg=message('dlcoder_spkg:cnncodegen:UnsupportedLayerParameter',cppClassName);
            codegenLayerValidator.handleError(layer,errMsg);
        end
    end


    layerInfo=codegenLayerValidator.getLayerInfo(layer.Name);



    allowAnyOutputFormats=dlcoderfeature('AllowAnyFormatsCustomLayer')&&strcmp(targetLib,'none')&&isLayerInDLNetwork;
    if~allowAnyOutputFormats
        errMsg=iValidateOutputFormats(cppClassName,layer.OutputNames,layerInfo.outputFormats,targetLib);
        if~isempty(errMsg)
            codegenLayerValidator.handleError(layer,errMsg);
        end
    end

    errMsg=iValidateBatchSize(layerInfo,cppClassName);
    if~isempty(errMsg)
        codegenLayerValidator.handleError(layer.Name,errMsg);
    end

end


function bool=iCheckIfMWAuthoredCustomLayers(layerClassName)
    internalPackageNames=dltargets.internal.getDLTPackageNamePrefixes();
    bool=any(startsWith(layerClassName,internalPackageNames));
end

function errMsg=iCheckFunctionLayerCompatibility(layer)
    errMsg=message.empty;
    if isa(layer,'nnet.internal.cnn.coder.layer.FunctionLayer')
        checkLayerMsgId=layer.CodegenCompatibilityMessageID;
        if~isempty(checkLayerMsgId)
            errMsg=message(checkLayerMsgId,layer.Name);
        end
    end
end


function errMsg=iValidateOutputFormats(cppClassName,outputNames,outputFormats,targetLib)
    errMsg=message.empty();
    for iOut=1:numel(outputFormats)
        if~any(strcmp(outputFormats{iOut},["CT","CB","CBT","SSC","SSCT","SSCB","SSCBT"]))
            errMsg=message('dlcoder_spkg:cnncodegen:InvalidDlarrayOutputFormat',cppClassName,outputFormats{iOut},...
            outputNames{iOut},targetLib);
            return;
        end
    end

end

function errMsg=iValidateBatchSize(layerInfo,cppClassName)

    errMsg=message.empty();


    inputSizes=layerInfo.inputSizes;
    inputFormats=layerInfo.inputFormats;

    if~contains(inputFormats{1},'B')
        inputBatchSize=1;
    else
        batchDim=strfind(inputFormats{1},'B');
        inputBatchSize=inputSizes{1}(batchDim);
    end

    outputSizes=layerInfo.outputSizes;
    outputFormats=layerInfo.outputFormats;


    for iOut=1:numel(outputSizes)

        if~contains(outputFormats{iOut},'B')
            outputBatchSize=1;
        else
            batchDim=strfind(outputFormats{iOut},'B');
            outputBatchSize=outputSizes{iOut}(batchDim);
        end

        if outputBatchSize~=inputBatchSize
            errMsg=message('dlcoder_spkg:cnncodegen:InvalidBatchSizeOutput',cppClassName,inputBatchSize,...
            outputBatchSize);
            return;
        end
    end

end
