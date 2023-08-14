classdef NetworkFileSaver<handle




    properties

NetworkInfo
    end

    properties(Access=private)

NetworkIdentifier


EncodedLayerInfo
    end

    methods(Access=public)


        function obj=NetworkFileSaver(networkInfo,networkWrapperIdentifier)


            assert(~isempty(networkInfo)&&isa(networkInfo,'dltargets.internal.NetworkInfo'));

            obj.NetworkInfo=networkInfo;


            layers=networkInfo.SortedLayers;
            numLayers=getNumLayers(obj);

            obj.EncodedLayerInfo=cell(1,numLayers);
            for iLayer=1:numLayers
                structForSerialization=dltargets.internal.compbuilder.CodegenCompBuilder.doSerialize(layers(iLayer),obj);
                obj.EncodedLayerInfo{iLayer}=jsonencode(structForSerialization);
            end


            obj.NetworkIdentifier=computeNetworkIdentifier(obj,networkWrapperIdentifier);
        end

        function layers=getLayers(obj)
            layers=obj.NetworkInfo.SortedLayers;
        end

        function numLayers=getNumLayers(obj)
            numLayers=obj.NetworkInfo.NumLayers;
        end

        function networkIdentifier=getNetworkIdentifier(obj)
            networkIdentifier=obj.NetworkIdentifier;
        end

        function encodedLayerInfo=getEncodedLayerInfo(obj)
            encodedLayerInfo=obj.EncodedLayerInfo;
        end

        function generateNetworkInfoFile(obj,netClassName,dlConfig,codegenDir,...
            codegenTarget,rowMajorCustomLayerNames,activationLayerIndices,...
            activationPortIndices,quantizationSpecificationType)














            logFilePrefix='networkParamsInfo';
            logFilePostfix='.bin';


            fileName=dltargets.internal.utils.LayerToCompUtils.getCompFileName(logFilePrefix,codegenDir,codegenTarget);
            fileName=[fileName,'_',netClassName,logFilePostfix];
            dltargets.internal.utils.SaveLayerFilesUtils.checkForWindowsLongPath(fileName);



            [status,msg]=mkdir(codegenDir);
            assert(status,msg);


            [fileID,errMsg]=fopen(fileName,'w');
            assert(fileID,errMsg);


            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,dlConfig.TargetLibrary);


            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,obj.NetworkIdentifier);


            verInfo=ver('matlab');
            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,verInfo.Version);


            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,quantizationSpecificationType);


            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,...
            jsonencode(obj.NetworkInfo.CodegenInputSizes));


            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,netClassName);
            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,codegenTarget);
            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,codegenDir);


            numRowMajorCustomLayers=numel(rowMajorCustomLayerNames);
            fwrite(fileID,numRowMajorCustomLayers,'uint32');
            for iLayer=1:numRowMajorCustomLayers
                dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,rowMajorCustomLayerNames{iLayer});
            end


            fwrite(fileID,numel(activationLayerIndices),'uint32');
            for iActivationLayer=1:numel(activationLayerIndices)
                fwrite(fileID,activationLayerIndices(iActivationLayer),'int32');
            end


            assert(numel(activationPortIndices)==numel(activationLayerIndices));
            for iActivationPort=1:numel(activationPortIndices)
                fwrite(fileID,activationPortIndices(iActivationPort),'int32');
            end


            iWriteClasses(fileID,dlConfig);


            fclose(fileID);
        end

    end

    methods(Access=private)
        function networkIdentifier=computeNetworkIdentifier(obj,networkWrapperIdentifier)
            digester=matlab.internal.crypto.BasicDigester("Blake-2b");


            digester.addData(getByteStreamFromArray(obj.EncodedLayerInfo));


            digester.addData(getByteStreamFromArray(obj.NetworkInfo.SortedLayerGraph.Connections));


            digester.addData(num2str(obj.NetworkInfo.isQuantizedDLNetwork()));


            digester.addData(getByteStreamFromArray(obj.NetworkInfo.getSkipLayersForQuantization()));


            if~isempty(networkWrapperIdentifier)
                digester.addData(networkWrapperIdentifier);
            end


            networkIdentifier=char(matlab.internal.crypto.hexEncode(digester.computeDigestFinalAndReset()));
        end
    end

    methods(Static)

        function saveFilesForNetworkUpdate(networkInfo,netClassName,dlConfig,codegenDir,...
            codegenTarget,rowMajorCustomLayerNames,activationLayerIndices,activationPortIndices)

            transformProperties=dltargets.internal.TransformProperties(networkInfo,activationLayerIndices);






            quantizationInfo=dltargets.internal.createQuantizerInfo(networkInfo,dlConfig);


            networkInfo=dltargets.internal.optimizations.optimizeNetwork(networkInfo,dlConfig,transformProperties);




            tensorrtQuantSpecMatFile='';

            netClassName=convertStringsToChars(netClassName);
            codegenDir=convertStringsToChars(codegenDir);
            codegenTarget=convertStringsToChars(codegenTarget);

            globalDnnContext=dltargets.internal.cnnbuildpir(networkInfo,...
            netClassName,...
            codegenDir,...
            codegenTarget,...
            dlConfig,...
            transformProperties,...
            rowMajorCustomLayerNames,...
            tensorrtQuantSpecMatFile);


            batchSize=networkInfo.CodegenInputSizes{1}(4);

            globalDnnContext.invokeDnnBackendPostEmission(netClassName,dlConfig,batchSize,quantizationInfo,...
            activationLayerIndices,activationPortIndices,networkInfo);

        end

        function generateNetworkInfoFileForUnsupportedTargets(netClassName,codegenDir,codegenTarget,targetLibrary)






            logFilePrefix='networkParamsInfo';
            logFilePostfix='.bin';


            fileName=dltargets.internal.utils.LayerToCompUtils.getCompFileName(logFilePrefix,codegenDir,codegenTarget);
            fileName=[fileName,'_',netClassName,logFilePostfix];



            [status,msg]=mkdir(codegenDir);
            assert(status,msg);


            [fileID,errMsg]=fopen(fileName,'w');
            assert(fileID,errMsg);





            dltargets.internal.utils.SaveLayerFilesUtils.writeStringValues(fileID,targetLibrary);


            fclose(fileID);
        end

    end

end

function iWriteClasses(fileID,aClass)

    dlConfigByteArray=getByteStreamFromArray(aClass);
    fwrite(fileID,numel(dlConfigByteArray),'uint64');
    fwrite(fileID,dlConfigByteArray,'uint8');

end
