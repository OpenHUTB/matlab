function networkFileNames=regenerateDeepLearningParameters(net,paramsInfoDirectory,networkName,overrideParameters)






















    persistent mexIsCalledMap;
    persistent noParamsRegeneratedMap;

    mexIsCalledMap=iInitializeMap(mexIsCalledMap);
    noParamsRegeneratedMap=iInitializeMap(noParamsRegeneratedMap);

    fileList=dir(paramsInfoDirectory);


    fileNames={fileList(~[fileList.isdir]).name};









    regexpExpr=['^networkParamsInfo_(c\d_)?',char(networkName),'(\d_)?\w*(.bin)$'];
    matchedExprs=regexp(fileNames,regexpExpr);
    matchedEntries=cellfun(@(x)~isempty(x)&&x==1,matchedExprs);
    logFileNames=fileNames(matchedEntries);

    if numel(logFileNames)==0
        if isempty(networkName)
            error(message('dlcoder_spkg:postCodegenUpdate:NoParamsInfoFile',paramsInfoDirectory));
        else
            error(message('dlcoder_spkg:postCodegenUpdate:NoParamsInfoFileForNetworkName',networkName,paramsInfoDirectory));
        end
    end



    networkInfo=dltargets.internal.NetworkInfo(net);


    networkWrapperIdentifier='';

    networkFileSaver=dltargets.internal.NetworkFileSaver(networkInfo,networkWrapperIdentifier);
    networkIdentifier=networkFileSaver.getNetworkIdentifier;


    matchedNetworkParamsInfoIndx=[];
    for iFile=1:numel(logFileNames)
        [fileID,errMsg]=fopen(fullfile(paramsInfoDirectory,logFileNames{iFile}),'r');
        if~isempty(errMsg)
            error(errMsg);
        end






        targetLibrary=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
        unsupportedTargetLibraries=["none","arm-compute-mali","cmsis-nn"];
        if any(strcmp(targetLibrary,unsupportedTargetLibraries))
            fclose(fileID);
            error(message('dlcoder_spkg:postCodegenUpdate:UnsupportedTargetLibForUpdate',targetLibrary));
        end


        encodedNetworkIdentifier=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
        if strcmp(networkIdentifier,encodedNetworkIdentifier)
            matchedNetworkParamsInfoIndx(end+1)=iFile;%#ok
        end

        fclose(fileID);
    end

    if numel(matchedNetworkParamsInfoIndx)>1


        error(message('dlcoder_spkg:postCodegenUpdate:MultipleParamsInfoFile',paramsInfoDirectory));
    elseif isempty(matchedNetworkParamsInfoIndx)

        error(message('dlcoder_spkg:postCodegenUpdate:IncorrectNetworkHash'));
    end


    matchedNetworkParamsInfoFile=logFileNames{matchedNetworkParamsInfoIndx};
    [fileID,errMsg]=fopen(fullfile(paramsInfoDirectory,matchedNetworkParamsInfoFile),'r');
    if~isempty(errMsg)
        error(errMsg);
    end

















    dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);


    dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);


    verInfo=ver('matlab');
    versionForGeneratedCode=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
    if(~strcmp(verInfo.Version,versionForGeneratedCode))
        fclose(fileID);
        error(message('dlcoder_spkg:postCodegenUpdate:VersionMismatch'));
    end


    quantizationSpecificationType=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
    if strcmp(quantizationSpecificationType,'global')
        fclose(fileID);
        if strcmp(targetLibrary,'tensorrt')
            error(message('dlcoder_spkg:postCodegenUpdate:TensorRTQuantizationNotSupported'));
        else
            error(message('dlcoder_spkg:postCodegenUpdate:GlobalQuantizationNotSupported'));
        end
    end



    inputSizes=jsondecode(dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID));
    if~iscell(inputSizes)


        inputSizesCell=mat2cell(inputSizes,ones(1,size(inputSizes,1)));
        networkInfo=dltargets.internal.NetworkInfo(net,inputSizesCell);
    else
        networkInfo=dltargets.internal.NetworkInfo(net,inputSizes);
    end


    netClassName=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
    codegenTarget=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);
    codegenDir=dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID);

    parameterFilesDirectory=iResolveParameterFilesDirectory(fileList,fileNames,...
    matchedNetworkParamsInfoFile,codegenTarget,codegenDir,overrideParameters,fileID);

    rowMajorCustomLayerNames=iReadRowMajorCustomLayers(fileID);
    [activationLayerIndices,activationPortIndices]=iReadActivationLayerAndPortIndices(fileID);
    dlConfig=iReadClasses(fileID);


    fclose(fileID);


    dltargets.internal.NetworkFileSaver.saveFilesForNetworkUpdate(networkInfo,netClassName,dlConfig,...
    parameterFilesDirectory,codegenTarget,rowMajorCustomLayerNames,activationLayerIndices,activationPortIndices);


    fileList=dir(parameterFilesDirectory);
    fileNames={fileList(~[fileList.isdir]).name};

    networkFilesPrefix=char(strcat('cnn_',networkName));

    networkFileNames=fileNames(strncmp(fileNames,networkFilesPrefix,numel(networkFilesPrefix)));
    networkFileNames=networkFileNames(cellfun(@(x)endsWith(x,'.bin'),networkFileNames));


    if strcmp(codegenTarget,'mex')
        if~isKey(mexIsCalledMap,networkIdentifier)
            infoMsg=message('dlcoder_spkg:postCodegenUpdate:CallClearMex');
            disp(infoMsg.string);
            mexIsCalledMap(networkIdentifier)=true;
        end
    end


    if isempty(networkFileNames)
        if~isKey(noParamsRegeneratedMap,networkIdentifier)
            infoMsg=message('dlcoder_spkg:postCodegenUpdate:NoParamsRegenerated');
            disp(infoMsg.string);
            noParamsRegeneratedMap(networkIdentifier)=true;
        end
    end


end

function rowMajorCustomLayerNames=iReadRowMajorCustomLayers(fileID)

    [numRowMajorCustomLayers,count]=fread(fileID,1,'uint32');
    assert(count==1);
    rowMajorCustomLayerNames=cell(1,numRowMajorCustomLayers);
    for iLayer=1:numRowMajorCustomLayers
        rowMajorCustomLayerNames{1,iLayer}=char(dltargets.internal.utils.SaveLayerFilesUtils.readStringValues(fileID));
    end

end


function[activationLayerIndices,activationPortIndices]=iReadActivationLayerAndPortIndices(fileID)

    [numActivationLayers,count]=fread(fileID,1,'uint32');
    assert(count==1);
    activationLayerIndices=zeros(1,numActivationLayers);
    for iLayer=1:numActivationLayers
        [activationLayerIndices(iLayer),count]=fread(fileID,1,'int32');
        assert(count==1,"Expected to read one character");
    end

    activationPortIndices=zeros(1,numActivationLayers);
    for iPort=1:numActivationLayers
        [activationPortIndices(iPort),count]=fread(fileID,1,'int32');
        assert(count==1," Expected to read one character");
    end

end

function aClass=iReadClasses(fileID)

    [numBytes,count]=fread(fileID,1,'uint64');
    assert(count==1);
    [byteArray,count]=fread(fileID,numBytes,'uint8');
    assert(count==numBytes);
    aClass=getArrayFromByteStream(uint8(byteArray));

end

function aMap=iInitializeMap(aMap)
    if isempty(aMap)
        aMap=containers.Map;
    end
end

function paramsInfoDirectoryAbsolutePath=iResolveParameterFilesDirectory(fileList,fileNames,...
    matchedNetworkParamsInfoFile,codegenTarget,codegenDir,overrideParameters,fileID)


    matchedNetworkParamsInfoData=fileList(strcmp(fileNames,matchedNetworkParamsInfoFile));
    paramsInfoDirectoryAbsolutePath=matchedNetworkParamsInfoData.folder;

    if strcmpi(codegenTarget,'mex')
        if~overrideParameters&&~strcmp(codegenDir,paramsInfoDirectoryAbsolutePath)
            fclose(fileID);
            error(message('dlcoder_spkg:postCodegenUpdate:CodegenDirectoryMismatch',...
            paramsInfoDirectoryAbsolutePath,codegenDir));
        end
        paramsInfoDirectoryAbsolutePath=codegenDir;

    else
        if overrideParameters
            warning(message('dlcoder_spkg:postCodegenUpdate:IgnoreOverrideParameterFiles'));
        end




    end

end
