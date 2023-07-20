function xformedNet=flattenCStyleFcLayerFusion(net,verbose)


















    networkWrapper=dltargets.internal.NetworkInfo(net,[]);







    xformedNetworkWrapper=fuseFlattenFCLayers(networkWrapper,verbose);
    if isa(net,'SeriesNetwork')||isa(net,'DAGNetwork')
        xformedNet=assembleNetwork(xformedNetworkWrapper.SortedLayerGraph);
    elseif isa(net,'dlnetwork')
        xformedNet=dlnetwork(xformedNetworkWrapper.SortedLayerGraph);
    end

end




function networkInfo=fuseFlattenFCLayers(networkInfo,verbose)



    flattenFC=analyzeDLNetwork(networkInfo);

    if~isempty(flattenFC)


        [xformedlgraph,flattenLayerNames]=xformNetwork(networkInfo,flattenFC,verbose);


        networkInfo.SortedLayerGraph=toposort(xformedlgraph);


        remove(networkInfo.LayerInfoMap,flattenLayerNames);
    end
end



function flattenFC=analyzeDLNetwork(networkInfo)

    layerArray=networkInfo.SortedLayerGraph.Layers;
    nameToLayerObj=dltargets.internal.optimizations.internal.getNameToLayerObjMap(layerArray);


    findFlattenFCPattern=@findFlattenFCPattern;


    flattenFC=dltargets.internal.optimizations.internal.breadthFirstSearch(...
    networkInfo.DiGraph,networkInfo.InputNames,...
    nameToLayerObj,findFlattenFCPattern,networkInfo.LayerInfoMap);
end



function flattenFC=findFlattenFCPattern(layerName,nameToLayerObj,flattenFC,diG,layerInfoMap)


    if~isFlatten(nameToLayerObj,layerName)
        return;
    end

    flattenLayer=nameToLayerObj(layerName);


    nextLayersNames=successors(diG,layerName);


    flattenInfo=layerInfoMap(layerName);
    inputSize=flattenInfo.inputSizes{1};


    isKerasFlatten=isKeras(nameToLayerObj,layerName);

    numNextLayers=numel(nextLayersNames);



    for i=1:numNextLayers

        nextLayerName=nextLayersNames{i};


        if isFullyConnected(nameToLayerObj,nextLayerName)
            FCLayer=nameToLayerObj(nextLayerName);
            inputInfo=struct("inputSize",inputSize,"flattenLayer",flattenLayer,...
            "isDC",false,"isKeras",isKerasFlatten);
            FCgroup=struct("FCLayer",FCLayer,"inputsInfo",inputInfo);
            flattenFC(nextLayerName)=FCgroup;
            continue;
        end



        [isJoin,isDC]=isJoinLayer(nextLayerName,nameToLayerObj,diG,layerInfoMap);


        if isJoin



            if(numNextLayers>1)
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFlattenJoinSharedInput',...
                class(flattenLayer),class(nameToLayerObj(nextLayerName)));
                error(msg);
            end


            layersAfterNames=successors(diG,nextLayerName);
            layersBeforeNames=predecessors(diG,nextLayerName);



            areLayersFlatten=allInputsFlatten(nameToLayerObj,layersBeforeNames);
            if~all(areLayersFlatten)||(~isDC&&~allFlattenSame(nameToLayerObj,layersBeforeNames))
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFlattenNotAllInputs',...
                class(flattenLayer),class(nameToLayerObj(nextLayerName)));
                error(msg);
            end


            if isDC

                if anySharedInputs(layersBeforeNames,diG)
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFlattenDCFlattensShareInput',...
                    class(flattenLayer),class(nameToLayerObj(nextLayerName)));
                    error(msg);
                end
            end



            for j=1:numel(layersAfterNames)
                layerAfterName=layersAfterNames{j};


                if~isFullyConnected(nameToLayerObj,layerAfterName)
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFlattenFCAfterJoin',...
                    class(flattenLayer),class(nameToLayerObj(nextLayerName)),class(nameToLayerObj(layerAfterName)));
                    error(msg);
                end

                FCLayer=nameToLayerObj(layerAfterName);


                inputInfo=struct("inputSize",inputSize,"flattenLayer",flattenLayer,...
                "isDC",isDC,"isKeras",isKerasFlatten);


                if flattenFC.isKey(layerAfterName)


                    mapValue=flattenFC(layerAfterName);
                    mapValue.inputsInfo(end+1)=inputInfo;
                    flattenFC(layerAfterName)=mapValue;
                else


                    FCgroup=struct("FCLayer",FCLayer,"inputsInfo",inputInfo);
                    flattenFC(layerAfterName)=FCgroup;
                end
            end

        else
            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFlattenPair',...
            class(nameToLayerObj(layerName)),class(nameToLayerObj(nextLayerName)));
            error(msg);
        end
    end

end




function[isJoin,isDC]=isJoinLayer(layerName,nameToLayerObj,diG,layerInfoMap)
    isJoin=true;
    isDC=false;


    if isDepthConcat(nameToLayerObj,layerName)
        isDC=true;
        return;
    end


    if isElementwiseJoin(layerName,diG,layerInfoMap)
        return;
    end


    isJoin=false;
end





function isElement=isElementwiseJoin(layerName,diG,layerInfoMap)


    isElement=true;


    prevLayers=predecessors(diG,layerName);
    if~(numel(prevLayers)>1)
        isElement=false;
        return;
    end



    layerInfo=layerInfoMap(layerName);
    inputSizes=layerInfo.inputSizes;
    outputSize=layerInfo.outputSizes{1};


    for i=1:numel(inputSizes)
        inputSize=inputSizes{i};
        if~isequal(inputSize,outputSize)
            isElement=false;
            return;
        end
    end
end



function isFlatten=isFlatten(nameToLayerObj,layerName)
    isFlatten=isa(nameToLayerObj(layerName),'nnet.keras.layer.FlattenCStyleLayer')||...
    isa(nameToLayerObj(layerName),'nnet.onnx.layer.FlattenLayer');
end



function isKeras=isKeras(nameToLayerObj,layerName)
    isKeras=isa(nameToLayerObj(layerName),'nnet.keras.layer.FlattenCStyleLayer');
end



function isFullyConnected=isFullyConnected(nameToLayerObj,layerName)
    isFullyConnected=isa(nameToLayerObj(layerName),'nnet.cnn.layer.FullyConnectedLayer');
end



function isDepthConcat=isDepthConcat(nameToLayerObj,layerName)
    isDepthConcat=isa(nameToLayerObj(layerName),'nnet.cnn.layer.DepthConcatenationLayer');
end



function out=allInputsFlatten(nameToLayerObj,prevLayers)
    isFlat=@(name)isFlatten(nameToLayerObj,name);
    out=cellfun(isFlat,prevLayers);
end






function out=allFlattenSame(nameToLayerObj,prevLayers)
    out=false;



    isK=@(name)isKeras(nameToLayerObj,name);
    areK=cellfun(isK,prevLayers);


    if all(areK)||all(~areK)
        out=true;
    end
end





function out=anySharedInputs(layerNames,diG)
    allInputs={};
    for i=1:numel(layerNames)
        inputLayers=predecessors(diG,layerNames{i});
        allInputs=[allInputs,inputLayers];
    end

    uniqueInputs=unique(allInputs);
    out=numel(uniqueInputs)<numel(allInputs);
end



function[xformedlgraph,flattenLayerNames]=xformNetwork(networkInfo,flattenFC,verbose)


    modifiedFlattenFC=modifyFlattenFC(flattenFC);

    flattenFCKeys=modifiedFlattenFC.keys;

    xformedlgraph=networkInfo.SortedLayerGraph;
    flattenLayerNames={};


    for eachKey=flattenFCKeys
        [xformedlgraph,flattenLayerNames]=applyPatternToDAG(xformedlgraph,networkInfo.Connections,...
        modifiedFlattenFC(eachKey{:}),networkInfo.DiGraph,flattenLayerNames,verbose);
    end


    xformedlgraph=removeLayers(xformedlgraph,flattenLayerNames);

end






function modifiedFlattenFC=modifyFlattenFC(flattenFC)


    modifiedFlattenFC=containers.Map;


    for eachKey=flattenFC.keys

        FCname=eachKey{:};
        flattenFC_group=flattenFC(FCname);
        FCLayer=flattenFC_group.FCLayer;


        inputsInfo=flattenFC_group.inputsInfo;
        numInputs=numel(inputsInfo);
        inputSizes=cell(1,numInputs);
        flattenLayers=cell(1,numInputs);



        isKerasFlatten=zeros(1,numInputs);


        for i=1:numInputs

            inputInfo=inputsInfo(i);


            inputSizes{i}=inputInfo.inputSize;
            flattenLayers{i}=inputInfo.flattenLayer;


            isDC=inputInfo.isDC;
            isKerasFlatten(i)=inputInfo.isKeras;
        end


        modifiedFC=modifyFC(FCLayer,inputSizes,isDC,isKerasFlatten);
        FCgroup.FCLayer=modifiedFC;
        FCgroup.flattenLayers=flattenLayers;
        modifiedFlattenFC(FCname)=FCgroup;
    end
end



function[lgraph,flattenLayerNames]=applyPatternToDAG(lgraph,connectivity,flattenFC_group,diG,flattenLayerNames,verbose)


    FCLayer=flattenFC_group.FCLayer;
    FCLayerName=FCLayer.Name;


    lgraph=replaceLayer(lgraph,FCLayerName,[FCLayer]);%#ok<*NBRAK>


    FlattenLayers=flattenFC_group.flattenLayers;
    numFlatten=size(FlattenLayers,2);


    for i=1:numFlatten

        flattenLayerName=FlattenLayers{i}.Name;


        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FusedLayersIntoFCLayer',flattenLayerName,FCLayerName),1,verbose);



        if any(find(strcmp(flattenLayerNames,flattenLayerName)))
            continue;
        end


        flattenLayerNames{end+1}=flattenLayerName;



        prevLayer=predecessors(diG,flattenLayerName);
        prevLayer=prevLayer{:};
        connStructPrev=connectivity(prevLayer);
        connMapPrev=getConnMap(connStructPrev);
        assert(connMapPrev.isKey(flattenLayerName));
        prevLayerName=[prevLayer,'/',connMapPrev(flattenLayerName).sourcePortname];



        nextLayers=successors(diG,flattenLayerName);
        connStructFlatten=connectivity(flattenLayerName);
        assert(numel(nextLayers)==numel(connStructFlatten));
        connMapFlatten=getConnMap(connStructFlatten);


        for j=1:numel(connStructFlatten)
            nextLayer=nextLayers{j};
            nextLayerConn=connMapFlatten(nextLayer);
            nextLayerName=[nextLayer,'/',nextLayerConn.destPortname];

            lgraph=lgraphDisconnectFlatten(lgraph,flattenLayerName,nextLayerName,prevLayerName);
        end
    end

end




function connMap=getConnMap(connStruct)
    connMap=containers.Map;
    for i=1:numel(connStruct)
        conn=connStruct(i);
        connMap(conn.outputLayer)=conn;
    end
end




function lgraph=lgraphDisconnectFlatten(lgraph,FlattenLayerName,NextLayerName,PrevLayerName)

    lgraph=disconnectLayers(lgraph,FlattenLayerName,NextLayerName);


    lgraph=disconnectLayers(lgraph,PrevLayerName,FlattenLayerName);
    lgraph=connectLayers(lgraph,PrevLayerName,NextLayerName);
end




function newFCLayer=modifyFC(FCLayer,inputSizes,isDC,isKerasFlatten)


    fcLayerOutputSize=length(FCLayer.Bias);



    newFCLayer=fullyConnectedLayer(fcLayerOutputSize,'Name',FCLayer.Name);
    newFCLayer.Weights=zeros(size(FCLayer.Weights));
    newFCLayer.Bias=FCLayer.Bias;



    startIndex=1;




    if isDC
        numIters=numel(inputSizes);
    else
        numIters=1;
    end


    for i=1:numIters

        inputSize=inputSizes{i};


        arrayLen=prod(inputSize);




        workingSet=startIndex:(startIndex+arrayLen-1);





        x=reshape(workingSet,inputSize);
        if isKerasFlatten(i)
            index=reshape(permute(x,[3,2,1]),[arrayLen,1]);
        else
            index=reshape(permute(x,[2,1,3]),[arrayLen,1]);
        end


        w=zeros(fcLayerOutputSize,arrayLen);


        for ii=1:arrayLen
            w(:,index(ii))=FCLayer.Weights(:,startIndex+ii-1);
        end


        newFCLayer.Weights(1:end,workingSet)=w(1:end,workingSet);


        startIndex=startIndex+arrayLen;
    end
end


