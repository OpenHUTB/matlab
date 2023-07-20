classdef NetworkInfo<handle








    properties(SetAccess=private)


InputLayers


OutputLayers



InputLayerSizes



CodegenInputSizes


BatchSize




InputLayerNameToInputSizeMap



InputLayerNameToInputNamesIdxMap



OutputLayerNameToOutputNamesIdxMap



OriginalSortedLayerGraph



InputNames
















PIRGraphInputNames



OutputNames



LayerExecutionSpecification



IsDLNetwork


NumLayers





DLQuantizerContext
    end

    properties(SetObservable,AbortSet)


SortedLayerGraph

    end

    properties(Dependent)
SortedLayers
    end


    properties(Access=public)

        LayerInfoMap;



        OriginalDLTIdxToLayerNameMap;


        NetworkIdentifier;
    end

    properties(SetAccess=public)


Connections












DiGraph
    end

    methods


        function obj=NetworkInfo(net,inputSizesCellArray,inputFormats)

            if nargin<2
                inputSizesCellArray=[];
            end

            if iscolumn(inputSizesCellArray)
                inputSizesCellArray=inputSizesCellArray';
            end

            if nargin<3
                inputFormats=cell(1,numel(net.InputNames));
                if isa(net,'dlnetwork')
                    exampleInputs=net.getExampleInputs;
                    if~isempty(exampleInputs)
                        inputFormats=cellfun(@(exampleInputType)dims(exampleInputType),exampleInputs,'UniformOutput',false);
                    end
                end
            end




            obj.LayerInfoMap=containers.Map;

            obj.InputLayerNameToInputSizeMap=containers.Map;

            obj.InputLayerNameToInputNamesIdxMap=containers.Map;

            obj.OutputLayerNameToOutputNamesIdxMap=containers.Map;

            obj.IsDLNetwork=isa(net,'dlnetwork');


            [obj.InputLayers,obj.OutputLayers]=dltargets.internal.getIOLayers(net);

            obj.InputNames=net.InputNames;
            obj.OutputNames=net.OutputNames;

            obj.InputLayerSizes=dltargets.internal.sharedNetwork.getNetworkInputSizes(net,obj.InputLayers);

            if isempty(inputSizesCellArray)


                setCodegenInputSizesForFPGA(obj);
            else
                obj.CodegenInputSizes=inputSizesCellArray;
            end



            obj.BatchSize=obj.CodegenInputSizes{1}(4);


            obj.LayerExecutionSpecification=deep.internal.quantization.getQuantizationInfoComposite(net);

            populateIOLayerNameToIONamesIdxMap(obj);

            obj.PIRGraphInputNames=obj.InputNames;

            populateInputNameToInputSizeMap(obj,obj.CodegenInputSizes);


            lgraph=dltargets.internal.utils.NetworkUtils.getLayerGraph(net);



            lgraph=dltargets.internal.utils.NetworkUtils.replaceLayersWithRedirectedLayers(lgraph);


            obj.SortedLayerGraph=toposort(lgraph);
            obj.NumLayers=numel(obj.SortedLayers);

            obj.OriginalSortedLayerGraph=obj.SortedLayerGraph;
            obj.OriginalDLTIdxToLayerNameMap=dltargets.internal.NetworkInfo.prepareDLTIdxToLayerNamesMap(obj.SortedLayerGraph);


            obj.NetworkIdentifier=dltargets.internal.getNetworkIdentifier(net);

            sortedConnections=obj.SortedLayerGraph.HiddenConnections;


            obj.parseSortedConnectionsTable(obj.SortedLayerGraph.Layers,...
            sortedConnections);


            obj.DiGraph=dltargets.internal.NetworkInfo.createDiGraph(obj.SortedLayerGraph);


            addlistener(obj,'SortedLayerGraph','PostSet',@dltargets.internal.NetworkInfo.updateNetworkInfo);


            exampleSequenceLengths=[];
            if isa(net,'dlnetwork')
                exampleSequenceLengths=coder.internal.coderNetworkUtils.getExampleSequenceLengths(net);
            end

            obj.LayerInfoMap=dltargets.internal.NetworkInfo.propagateSizesAndPopulateLayerInfo(net,obj.CodegenInputSizes,obj.SortedLayerGraph,...
            obj.InputLayerNameToInputSizeMap,inputFormats,exampleSequenceLengths);

        end

        function layerInfo=getLayerInfo(this,layerName)
            assert(isKey(this.LayerInfoMap,layerName));
            layerInfo=this.LayerInfoMap(layerName);
        end




        function out=saveobj(~)
            out=[];
        end

        function updateNetworkInfoPostFusion(obj,optimizedLayerGraph,fusedLayersMap,layerComps)







            layerIndicesBeforeFusion=1:obj.NumLayers;




            layersBeforeFusion=obj.OriginalSortedLayerGraph.Layers;
            layersAfterFusion=optimizedLayerGraph.Layers;

            for iLayer=layerIndicesBeforeFusion
                if isKey(fusedLayersMap,iLayer)

                    fusedLayerInfo=fusedLayersMap(iLayer);
                    layerIndexAfterFusion=fusedLayerInfo(1);
                    layerIndexOffset=fusedLayerInfo(2);
                    if layerIndexOffset>1


                        keyToRemove=layersBeforeFusion(iLayer).Name;
                        if isKey(obj.LayerInfoMap,keyToRemove)






                            remove(obj.LayerInfoMap,keyToRemove);
                        end

                        keyToAdd=layersAfterFusion(layerIndexAfterFusion).Name;



                        if~isKey(obj.LayerInfoMap,keyToAdd)





                            drivingLayerIndex=fusedLayerInfo(3);

                            keyFromDrivingLayer=layersBeforeFusion(drivingLayerIndex).Name;
                            valueToAdd=obj.LayerInfoMap(keyFromDrivingLayer);


                            obj.LayerInfoMap(keyToAdd)=valueToAdd;
                        end
                    end
                else

                    remove(obj.LayerInfoMap,layersBeforeFusion(iLayer).Name);
                end
            end




            updateOriginalLayersInLayerInfoMap(obj,layerComps)

            addPIRComponentsToLayerInfoMap(obj,...
            optimizedLayerGraph,layersAfterFusion,layerComps);


            obj.SortedLayerGraph=optimizedLayerGraph;
            obj.NumLayers=numel(layersAfterFusion);
        end

        function updateOriginalLayersInLayerInfoMap(obj,layerComps)
            for idx=1:numel(layerComps)
                currentComponent=layerComps(idx);
                compName=currentComponent.getName;
                if isKey(obj.LayerInfoMap,compName)
                    oldLayerInfoValue=obj.LayerInfoMap(compName);
                    [inputFormats,outputFormats]=...
                    dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(currentComponent);

                    if~isequal(inputFormats,oldLayerInfoValue.inputFormats)||...
                        ~isequal(outputFormats,oldLayerInfoValue.outputFormats)


                        [layerHasSequenceInput,layerHasSequenceOutputs]=...
                        iHasSequenceInputAndOutput(inputFormats,outputFormats);
                        valueToUpdate=dltargets.internal.LayerInfo(oldLayerInfoValue.inputSizes,...
                        inputFormats,oldLayerInfoValue.outputSizes,outputFormats,...
                        layerHasSequenceOutputs,layerHasSequenceInput,...
                        oldLayerInfoValue.hasDlarrayInputs);
                        obj.LayerInfoMap(compName)=valueToUpdate;
                    end
                end
            end
        end

        function isQuantizedNet=isQuantizedDLNetwork(obj)
            isQuantizedNet=(isprop(obj,'LayerExecutionSpecification')&&...
            ~isempty(obj.LayerExecutionSpecification));
        end

        function addPIRComponentsToLayerInfoMap(obj,optimizedLayerGraph,layersAfterFusion,layerComps)


            [~,diffLayerIndices]=setdiff({optimizedLayerGraph.Layers.Name},keys(obj.LayerInfoMap),'stable');

            passthroughIndices=[];
            for i=1:numel(diffLayerIndices)
                idxNewLayer=diffLayerIndices(i);
                keyToAdd=optimizedLayerGraph.Layers(idxNewLayer).Name;


                newLayer=layersAfterFusion(idxNewLayer);

                assert(isa(newLayer,'coder.internal.layer.PassThroughLayer')||...
                isa(newLayer,'coder.internal.layer.SequenceFoldingLayer')||...
                isa(newLayer,'coder.internal.layer.SequenceUnfoldingLayer')||...
                isa(newLayer,'coder.internal.layer.FlattenLayer'),...
                'Expected passThroughLayer, sequenceFoldingLayer, sequenceUnfoldingLayer or flattenLayer');

                if isa(newLayer,'coder.internal.layer.PassThroughLayer')
                    passthroughIndices=[passthroughIndices,diffLayerIndices(i)];
                else
                    iAddNewPIRComponentsToLayerInfoMap(obj,layerComps,idxNewLayer,newLayer,keyToAdd,optimizedLayerGraph)
                end

            end



            for i=1:length(passthroughIndices)
                idxNewLayer=passthroughIndices(i);
                keyToAdd=optimizedLayerGraph.Layers(idxNewLayer).Name;


                newLayer=layersAfterFusion(idxNewLayer);

                assert(isa(newLayer,'coder.internal.layer.PassThroughLayer'),...
                'Expected passThroughLayer');

                iAddNewPIRComponentsToLayerInfoMap(obj,layerComps,idxNewLayer,newLayer,keyToAdd,optimizedLayerGraph);
            end

        end

        function iAddNewPIRComponentsToLayerInfoMap(obj,layerComps,idxNewLayer,newLayer,keyToAdd,optimizedLayerGraph)
            newComponent=layerComps(idxNewLayer);

            [layerInputSize,layerInputFormat,layerOutputSize,layerOutputFormat,layerHasSequenceInput,...
            layerHasSequenceOutputs]=iGetNewLayerInfo(newComponent,obj.LayerInfoMap,optimizedLayerGraph,idxNewLayer);

            hasDlarrayInputsForCustomLayers=dltargets.internal.hasDlarrayInputsForCustomLayers(...
            newLayer,obj.IsDLNetwork);

            layerInfo=dltargets.internal.LayerInfo(layerInputSize,layerInputFormat,...
            layerOutputSize,layerOutputFormat,layerHasSequenceOutputs,layerHasSequenceInput,...
            hasDlarrayInputsForCustomLayers);

            obj.LayerInfoMap(keyToAdd)=layerInfo;
        end

        function skipLayers=getSkipLayersForQuantization(~)
            skipLayers={{''}};
        end

        function setDLQuantizerContext(this,context)
            this.DLQuantizerContext=context;
        end





        function updateOutputLayer(this,oldLayerName,newLayer)

            outputNames=this.OutputNames;
            this.OutputNames=[];
            outputNames{strcmp(outputNames,oldLayerName)}=newLayer.Name;
            this.OutputNames=outputNames;

            outputLayers=this.OutputLayers;
            this.OutputLayers=[];
            outputLayers{cellfun(@(x)strcmp(x.Name,oldLayerName),outputLayers)}=newLayer;
            this.OutputLayers=outputLayers;



            this.OutputLayerNameToOutputNamesIdxMap(newLayer.Name)=...
            this.OutputLayerNameToOutputNamesIdxMap(oldLayerName);
            this.OutputLayerNameToOutputNamesIdxMap.remove(oldLayerName);
        end

        function updatePIRGraphInputNames(this,networkInputPortIdx,newName)


            this.PIRGraphInputNames{networkInputPortIdx}=newName;
        end

    end


    methods

        function sortedLayers=get.SortedLayers(obj)

            sortedLayers=obj.SortedLayerGraph.Layers;

        end

        function batchSize=getBatchSize(obj)
            batchSize=obj.BatchSize;
        end

    end

    methods(Access=private)

        function parseSortedConnectionsTable(obj,sortedLayers,sortedConnections)
            connectivity=containers.Map;
            numEdges=size(sortedConnections,1);
            sortedInternalLayers=nnet.cnn.layer.Layer.getInternalLayers(sortedLayers);

            for iEdge=1:numEdges

                numPortsForEdge=size(sortedConnections.EndPorts{iEdge});
                for iPort=1:numPortsForEdge
                    sourceLayer=sortedInternalLayers{sortedConnections.EndNodes(iEdge,1)};
                    destLayer=sortedInternalLayers{sortedConnections.EndNodes(iEdge,2)};

                    sourceName=sourceLayer.Name;
                    destName=destLayer.Name;

                    sourcePortName=sourceLayer.OutputNames{sortedConnections.EndPorts{iEdge}(iPort,1)};
                    sourcePort=sortedConnections.EndPorts{iEdge}(iPort,1)-1;

                    destPortName=destLayer.InputNames{sortedConnections.EndPorts{iEdge}(iPort,2)};
                    destPort=sortedConnections.EndPorts{iEdge}(iPort,2)-1;

                    val=struct('outputLayer',destName,'sourceport',sourcePort,...
                    'destport',destPort,'sourcePortname',sourcePortName,...
                    'destPortname',destPortName);

                    if isKey(connectivity,sourceName)
                        outputs=connectivity(sourceName);
                        outputs(end+1)=val;%#ok<AGROW>
                        connectivity(sourceName)=outputs;
                    else
                        connectivity(sourceName)=val;
                    end
                end
            end

            obj.Connections=connectivity;

        end

        function populateInputNameToInputSizeMap(obj,inputSizes)

            for i=1:numel(obj.InputNames)
                obj.InputLayerNameToInputSizeMap(obj.InputNames{i})=inputSizes{i};
            end

        end

        function populateIOLayerNameToIONamesIdxMap(obj)

            for i=1:numel(obj.InputNames)
                obj.InputLayerNameToInputNamesIdxMap(obj.InputNames{i})=(i-1);
            end

            for i=1:numel(obj.OutputNames)
                obj.OutputLayerNameToOutputNamesIdxMap(obj.OutputNames{i})=(i-1);
            end
        end

        function setCodegenInputSizesForFPGA(obj)

            obj.CodegenInputSizes=cell(numel(obj.InputLayerSizes),1);
            for i=1:numel(obj.InputLayerSizes)
                obj.CodegenInputSizes{i}=[obj.InputLayerSizes{i},1];
                numDims=numel(obj.CodegenInputSizes{i});
                if numDims<4

                    obj.CodegenInputSizes{i}=[ones(1,4-numDims),obj.CodegenInputSizes{i}];
                end
            end

        end

    end


    methods(Static)


        function updateNetworkInfo(src,evnt)

            switch src.Name
            case 'SortedLayerGraph'




                obj=evnt.AffectedObject;

                sortedConnections=obj.SortedLayerGraph.HiddenConnections;


                obj.parseSortedConnectionsTable(obj.SortedLayerGraph.Layers,...
                sortedConnections);


                obj.DiGraph=dltargets.internal.NetworkInfo.createDiGraph(obj.SortedLayerGraph);

            otherwise
                assert(false);

            end
        end















        function layerInfoMap=...
            propagateSizesAndPopulateLayerInfo(net,inputSizes,sortedLayerGraph,inputLayerNameToInputSizeMap,inputFormats,exampleSequenceLengths)

            layers=sortedLayerGraph.Layers;
            numLayers=numel(layers);
            inputLayers=dltargets.internal.getIOLayers(net);


            [layerOutputSizes,layerOutputFormats,hasSequenceOutputs]=...
            dltargets.internal.getLayerOutputShapesAndSequenceInfo(net,inputSizes,inputFormats,exampleSequenceLengths);

            layerInfoMap=containers.Map;
            isaDLNetwork=isa(net,'dlnetwork');

            inputNamesToInputFormatMap=containers.Map(net.InputNames,inputFormats);

            for iLayer=1:numLayers

                currentLayer=layers(iLayer);

                [layerInputSize,layerInputFormat,layerHasSequenceInput]=...
                dltargets.internal.getLayerInputShapesAndSequenceInfo(iLayer,...
                sortedLayerGraph.HiddenConnections,layerOutputSizes,layerOutputFormats,...
                inputLayerNameToInputSizeMap,currentLayer,...
                inputNamesToInputFormatMap,isaDLNetwork,inputLayers);

                if iscell(layerOutputSizes{iLayer}(1))



                    layerOutSize=layerOutputSizes{iLayer};
                    layerOutputFormat=layerOutputFormats{iLayer};
                else
                    layerOutSize=layerOutputSizes(iLayer);
                    layerOutputFormat=layerOutputFormats(iLayer);
                end



                hasDlarrayInputsForCustomLayers=dltargets.internal.hasDlarrayInputsForCustomLayers(currentLayer,...
                isaDLNetwork);

                layerInfo=dltargets.internal.LayerInfo(layerInputSize,layerInputFormat,...
                layerOutSize,layerOutputFormat,hasSequenceOutputs(iLayer),layerHasSequenceInput,...
                hasDlarrayInputsForCustomLayers);

                layerInfoMap(layers(iLayer).Name)=layerInfo;
            end
        end



        function diG=createDiGraph(sortedLayerGraph)
            diG=sortedLayerGraph.extractPrivateDirectedGraph;


            sortedLayers=sortedLayerGraph.Layers;
            diG.Nodes.Name=arrayfun(@(x)x.Name,sortedLayers,'UniformOutput',false);
        end








        function layerInfoMap=constructLayerInfoMap(net,inputSizes,inputFormats)
            if nargin<3
                inputFormats=cell(1,numel(net.InputNames));


                if isa(net,'dlnetwork')
                    exampleInputs=net.getExampleInputs;
                    if~isempty(exampleInputs)
                        inputFormats=cellfun(@(exampleInputType)exampleInputType.dims,exampleInputs,'UniformOutput',false);
                    end
                end
            end

            sortedLayerGraph=toposort(dltargets.internal.utils.NetworkUtils.getLayerGraph(net));

            inputLayerNameToInputSizeMap=containers.Map;
            inputNames=net.InputNames;
            for i=1:numel(inputNames)
                inputLayerNameToInputSizeMap(inputNames{i})=inputSizes{i};
            end

            exampleSequenceLengths=[];
            if isa(net,'dlnetwork')
                exampleSequenceLengths=coder.internal.coderNetworkUtils.getExampleSequenceLengths(net);
            end

            layerInfoMap=dltargets.internal.NetworkInfo.propagateSizesAndPopulateLayerInfo(...
            net,inputSizes,sortedLayerGraph,inputLayerNameToInputSizeMap,inputFormats,...
            exampleSequenceLengths);
        end

        function obj=loadobj(~)
            obj=[];%#ok
            error(message('dlcoder_spkg:cnncodegen:DLCoderInternalError'));

        end

    end

    methods(Static,Access=private)
        function originalDLTIdxToLayerNamesMap=prepareDLTIdxToLayerNamesMap(sortedLayerGraph)











            originalDLTIdxToLayerNamesMap=containers.Map('KeyType','double','ValueType','any');

            layers=sortedLayerGraph.Layers;

            for idx=1:numel(layers)
                originalDLTIdxToLayerNamesMap(idx)=layers(idx).Name;
            end
        end
    end
end

function[hasSequenceInputs,hasSequenceOutputs]=iHasSequenceInputAndOutput(inputFormats,outputFormats)
    hasSequenceOutputs=contains(outputFormats,'T');
    hasSequenceInputs=contains(inputFormats,'T');
end

function[inputSizes,inputFormats,outputSizes,outputFormats,...
    hasSequenceInput,hasSequenceOutputs]=iGetNewLayerInfo(newLayerComp,layerInfoMap,optimizedLayerGraph,idxNewLayer)



    [inputFormats,outputFormats]=...
    dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(newLayerComp);




    [hasSequenceInput,hasSequenceOutputs]=...
    iHasSequenceInputAndOutput(inputFormats{1},outputFormats{1});

    [inputSizes,outputSizes]=iGetIOSizesForNewLayer(layerInfoMap,optimizedLayerGraph,idxNewLayer);
end

function[inputSizes,outputSizes]=iGetIOSizesForNewLayer(layerInfoMap,optimizedLayerGraph,idxNewLayer)



    newLayer=optimizedLayerGraph.Layers(idxNewLayer);

    if~isKey(layerInfoMap,newLayer.Name)
        if isa(newLayer,'coder.internal.layer.SequenceFoldingLayer')||isa(newLayer,'coder.internal.layer.FlattenLayer')


            newLayerOutputConnectionsInfo=dltargets.internal.getLayerOutputConnections(optimizedLayerGraph.HiddenConnections,...
            idxNewLayer);
            assert(~isempty(newLayerOutputConnectionsInfo));
            [inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingOutputConnections(newLayerOutputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph);

        else

            newLayerInputConnectionsInfo=dltargets.internal.getLayerInputConnections(optimizedLayerGraph.HiddenConnections,...
            idxNewLayer);
            if isa(newLayer,'coder.internal.layer.SequenceUnfoldingLayer')


                assert(~isempty(newLayerInputConnectionsInfo));
                [inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingInputConnections(newLayerInputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph);
            else
                assert(isa(newLayer,'coder.internal.layer.PassThroughLayer'));


                if~isempty(newLayerInputConnectionsInfo)
                    [inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingInputConnections(newLayerInputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph);
                else
                    newLayerOutputConnectionsInfo=dltargets.internal.getLayerOutputConnections(optimizedLayerGraph.HiddenConnections,...
                    idxNewLayer);
                    assert(~isempty(newLayerOutputConnectionsInfo));
                    [inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingOutputConnections(newLayerOutputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph);
                end
            end
        end
    end
end

function[inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingInputConnections(newLayerInputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph)


    idxPredecessorLayer=newLayerInputConnectionsInfo(1);


    idxPredecessorConnectedOuputPort=newLayerInputConnectionsInfo(2);
    predecessorLayerName=optimizedLayerGraph.Layers(idxPredecessorLayer).Name;


    inputSizes=layerInfoMap(predecessorLayerName).outputSizes(idxPredecessorConnectedOuputPort);
    if isa(newLayer,'coder.internal.layer.PassThroughLayer')

        outputSizes=inputSizes;
    elseif isa(newLayer,'coder.internal.layer.SequenceFoldingLayer')


        outputSizes={inputSizes{1},[1,inputSizes{1}(end),1]};
    elseif isa(newLayer,'coder.internal.layer.SequenceUnfoldingLayer')


        outputSizes=inputSizes;

        inputSizes={inputSizes{1},[1,inputSizes{1}(end),1]};
    else
        assert(isa(newLayer,'coder.internal.layer.FlattenLayer'))

        outputSizes={[1,1,prod(inputSizes{1}(1:3)),inputSizes{1}(end)]};
    end

end

function[inputSizes,outputSizes]=iGetIOSizesForNewLayerUsingOutputConnections(newLayerOutputConnectionsInfo,newLayer,layerInfoMap,optimizedLayerGraph)







    idxSuccessorLayer=newLayerOutputConnectionsInfo(1);



    idxsuccessorConnectedOuputPort=newLayerOutputConnectionsInfo(2);

    successorLayerName=optimizedLayerGraph.Layers(idxSuccessorLayer).Name;
    inputSizeSuccessor=layerInfoMap(successorLayerName).inputSizes(idxsuccessorConnectedOuputPort);




    if isa(newLayer,'coder.internal.layer.FlattenLayer')





        outputSizes={[1,1,prod(inputSizeSuccessor{1}(1:3)),inputSizeSuccessor{1}(end)]};
        inputSizes=inputSizeSuccessor;
    elseif isa(newLayer,'coder.internal.layer.SequenceFoldingLayer')
        outputSizes={inputSizeSuccessor{1},[1,inputSizeSuccessor{1}(end),1]};
        inputSizes=inputSizeSuccessor{1};
    else
        assert(isa(newLayer,'coder.internal.layer.PassThroughLayer'))
        outputSizes=inputSizeSuccessor;
        inputSizes=outputSizes;
    end
end