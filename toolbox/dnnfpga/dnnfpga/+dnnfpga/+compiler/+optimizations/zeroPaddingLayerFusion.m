function xformedNet=zeroPaddingLayerFusion(net,verbose)












    switch class(net)
    case 'SeriesNetwork'
        [xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformSeriesNetwork(net);
    case 'DAGNetwork'
        [xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformDAGNetwork(net);
    case 'dlnetwork'
        [xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformDLNetwork(net);
    otherwise
        xformedNet=net;
        fusedConv=false;
        fusedGroupConv=false;
        fusedMaxpool=false;
    end


    if fusedConv
        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FusedLayers',...
        'nnet.keras.layer.ZeroPadding2dLayer','nnet.cnn.layer.Convolution2DLayer'),1,verbose);
    end

    if fusedGroupConv
        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FusedLayers',...
        'nnet.keras.layer.ZeroPadding2dLayer','nnet.cnn.layer.GroupedConvolution2DLayer'),1,verbose);
    end

    if fusedMaxpool
        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FusedLayers',...
        'nnet.keras.layer.ZeroPadding2dLayer','nnet.cnn.layer.MaxPooling2DLayer'),1,verbose);
    end

end

function fusedLayer=fuseZeroPaddingLayer(srcLayer,dstLayer)
    paddingSize=[srcLayer.Top,srcLayer.Bottom,srcLayer.Left,srcLayer.Right];
    fusedLayer=dstLayer;
    fusedLayer.PaddingSize=fusedLayer.PaddingSize+paddingSize;
end

function[xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformSeriesNetwork(net)










    fusedConv=false;
    fusedGroupConv=false;
    fusedMaxpool=false;
    idsToRemove=[];

    layerArray=net.Layers;
    for i=1:numel(layerArray)
        if isa(layerArray(i),'nnet.keras.layer.ZeroPadding2dLayer')
            srcLayer=layerArray(i);
            dstLayer=layerArray(i+1);


            fusedConv=fusedConv||...
            isa(layerArray(i+1),'nnet.cnn.layer.Convolution2DLayer');
            fusedGroupConv=fusedGroupConv||...
            isa(layerArray(i+1),'nnet.cnn.layer.GroupedConvolution2DLayer');
            fusedMaxpool=fusedMaxpool||...
            isa(layerArray(i+1),'nnet.cnn.layer.MaxPooling2DLayer');


            if fusedConv||fusedGroupConv||fusedMaxpool
                fusedLayer=fuseZeroPaddingLayer(srcLayer,dstLayer);
                layerArray(i+1)=fusedLayer;
                idsToRemove=[idsToRemove,i];%#ok<AGROW> 
            else

                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',...
                srcLayer.Name,dstLayer.Name,srcLayer.Name);
                error(msg);
            end
        end
    end
    layerArray(idsToRemove)=[];
    xformedNet=assembleNetwork(layerArray);
end

function[xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformDAGNetwork(net)









    [lgraph,fusedConv,fusedGroupConv,fusedMaxpool,idsToRemove]=fuseLayersLGraph(net);
    lgraphMod=xformLGraph(lgraph,idsToRemove);
    xformedNet=assembleNetwork(lgraphMod);
end

function[xformedNet,fusedConv,fusedGroupConv,fusedMaxpool]=xformDLNetwork(net)










    [lgraph,fusedConv,fusedGroupConv,fusedMaxpool,idsToRemove]=fuseLayersLGraph(net);
    lgraphMod=xformLGraph(lgraph,idsToRemove);
    xformedNet=dlnetwork(lgraphMod);
end

function[lgraph,fusedConv,fusedGroupConv,fusedMaxpool,idsToRemove]=fuseLayersLGraph(net)










    layers=net.Layers;
    lgraph=layerGraph(net);
    connections=lgraph.Connections;

    layertype='nnet.keras.layer.ZeroPadding2dLayer';
    fn=@(x)isa(x,layertype);
    zpIDs=find(arrayfun(fn,layers));

    fusedConv=false;
    fusedGroupConv=false;
    fusedMaxpool=false;
    idsToRemove=[];

    for i=1:numel(zpIDs)

        ii=zpIDs(i);
        srclayer=layers(ii);
        srcname=srclayer.Name;
        entries=strcmp(connections.Source,srcname);
        dstnames=connections.Destination(entries);
        removelayer=true;
        for j=1:numel(dstnames)
            dstname=dstnames{j};
            dstID=getLayerID(layers,dstname);
            dstLayer=layers(dstID);


            fusedConv=fusedConv||...
            isa(dstLayer,'nnet.cnn.layer.Convolution2DLayer');
            fusedGroupConv=fusedGroupConv||...
            isa(dstLayer,'nnet.cnn.layer.GroupedConvolution2DLayer');
            fusedMaxpool=fusedMaxpool||...
            isa(dstLayer,'nnet.cnn.layer.MaxPooling2DLayer');


            if fusedConv||fusedGroupConv||fusedMaxpool
                fusedLayer=fuseZeroPaddingLayer(srclayer,dstLayer);
                lgraph=replaceLayer(lgraph,dstname,fusedLayer);
            else
                removelayer=false;

                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',...
                srclayer.Name,dstLayer.Name,srclayer.Name);
                error(msg);
            end
        end
        if removelayer


            idsToRemove=[idsToRemove,ii];%#ok<AGROW> 
        end
    end
end

function lgraph=xformLGraph(lgraph,idsToRemove)







    layers=lgraph.Layers;
    connections=lgraph.Connections;

    for i=1:numel(idsToRemove)
        index=idsToRemove(i);


        lgraph=removeLayers(lgraph,layers(index).Name);

        l=strcmp(connections.Destination,layers(index).Name);
        source=connections{l,'Source'};

        indices=find(strcmp(connections.Source,layers(index).Name));
        for j=1:numel(indices)

            destination=connections{indices(j),'Destination'};

            lgraph=connectLayers(lgraph,source{:},destination{:});
        end
    end
end

function id=getLayerID(layers,name)
    fn=@(layer)strcmp(layer.Name,name);
    id=find(arrayfun(fn,layers));
end
