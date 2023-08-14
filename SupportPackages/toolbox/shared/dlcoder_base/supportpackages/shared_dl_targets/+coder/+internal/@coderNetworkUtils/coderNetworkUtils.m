%#codegen




classdef coderNetworkUtils




    methods(Hidden=true)
        function obj=coderNetworkUtils()
            coder.allowpcode('plain');
        end
    end

    methods(Static)



        checkAndWarnForHalfInput(classType);

        validateMatFileAndVariableName(matfile,variableName);

        errorForSimulinkUpdateLearnables(ctx);

        callValidateNetworkImpl(dlnet,dlConfig,networkInfo);


        [SortedInputLayerIndices,SortedOutputLayerIndices,SortedNetworkInputSizes]=getSortedIOLayerIndices(net,InputLayers,OutputLayers);

        [layerid,opPortid]=getLayerIndex(net,layerarg);

        layerid=getLayerId(net,layerName);

        portid=getPortNum(layer,portname);


        dlarrayData=getDlarrayDataFromNumericData(numericData,dataFormat);

        outData=prepareVectorDataCcode(inData)

        unique_name=getUniqueName(matFile,networkName,dataType,inputSizes);

        checkForSimulink();

        targetLib=getTargetLib;

        dataType=getTargetDataType(ctx);

        registerDependencies();

        isMexCodeConfig();

        isSfunCodeConfig();

        isSfunOrRtwCodeConfig();

        isCustomBLASCallbackEnabled();

        isBlasEnabled();

        canUseMultiThreading();

        varargout=customLayerPredict(layer,isInputFormatted,inputDlarrayFormat,states,varargin)

        out=transposeHWDims(in);

        outData=permuteCNNVectorData(inData,targetLib)

        tf=hasPermuteForTarget(targetLibrary)

        dataType=populateDataType(dlconfig,dlCodegenOptionsCallback,networkIdentifier);


        [quantSpecMatFile,networkFcnName]=parseCoderLoadNetworkVarargin(varargin);


        layerProps=getCustomLayerProps(networkInfo);


        learnables=permuteLearnables(learnables,isCustomLayerLearnables,customLayers);
        learnableLayerInfo=getLearnableLayerInfo(networkInfo);


        validateLearnables(expectedLearnablesSizes,learnables);
        outString=prepareSizeForErrorMessage(size);


        exampleSequenceLengths=getExampleSequenceLengths(net);


        fileID=initializeProfilingFile(isProfilingEnabled,networkName,numLayers);
        timer=startTimer(isProfilingEnabled);
        printElapsedTimeToFile(isProfilingEnabled,timer,fileID,layerIndex,layerName);
        closeProfilingFile(fileID)
    end
end
