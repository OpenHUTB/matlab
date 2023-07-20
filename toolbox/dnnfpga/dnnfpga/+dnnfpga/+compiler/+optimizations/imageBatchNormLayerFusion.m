function xformedNet=imageBatchNormLayerFusion(net,verbose)














    if isa(net,'SeriesNetwork')
        xformedLayerArray=xformLayerArray(net,verbose);
    elseif isa(net,'DAGNetwork')||isa(net,'dlnetwork')
        xformedlgraph=xformLayerGraph(net,verbose);
    end


    if isa(net,'SeriesNetwork')
        xformedNet=assembleNetwork(xformedLayerArray);
    elseif isa(net,'DAGNetwork')
        xformedNet=assembleNetwork(xformedlgraph);
    elseif isa(net,'dlnetwork')
        xformedNet=dlnetwork(xformedlgraph);
    end

end




function newlayers=xformLayerArray(net,verbose)
    layers=net.Layers;
    newlayers=layers;
    if isa(layers(1),'nnet.cnn.layer.ImageInputLayer')&&...
        isa(layers(2),'nnet.cnn.layer.BatchNormalizationLayer')

        n=layers(1).InputSize(3);


        b=layers(2);
        b.Name="__"+string(b.Name)+"__";


        wtsz=[1,1,n,n];
        wts=zeros(wtsz);
        for i=1:n
            wts(1,1,i,i)=1;
        end
        bsz=[1,1,n];
        bias=zeros(bsz);

        name=layers(2).Name;
        c=convolution2dLayer(1,n,Name=name);
        c.Weights=wts;
        c.Bias=bias;


        newlayers=[layers(1);c;b;layers(3:end)];


        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:BatchNormReplaced',name),1,verbose);
    end
end




function lgraph=xformLayerGraph(net,verbose)
    lgraph=net.layerGraph;

    [list,map]=getImageBNormSequences(lgraph);

    for j=1:numel(list)

        src=list{j}(1);
        dst=list{j}(2);


        n=map(src).InputSize(3);


        bnorm=map(dst);
        dstnew="__"+string(dst)+"__";
        bnorm.Name=dstnew;

        bnormDests=getLayerDestinations(net,dst);

        lgraph=lgraph.removeLayers(dst);
        lgraph=lgraph.addLayers(bnorm);
        lgraph=lgraph.connectLayers(src,dstnew);
        lgraph=lgraph.connectLayers(dstnew,bnormDests);


        wtsz=[1,1,n,n];
        wts=zeros(wtsz);
        for i=1:n
            wts(1,1,i,i)=1;
        end
        bsz=[1,1,n];
        bias=zeros(bsz);

        name=dst;
        c=convolution2dLayer(1,n,Name=name);
        c.Weights=wts;
        c.Bias=bias;


        lgraph=lgraph.disconnectLayers(src,dstnew);
        lgraph=lgraph.addLayers(c);
        lgraph=lgraph.connectLayers(src,name);
        lgraph=lgraph.connectLayers(name,dstnew);


        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:BatchNormReplaced',name),1,verbose);
    end
end





function[list,map]=getImageBNormSequences(lgraph)
    list={};
    index=1;

    map=createLayerNameToLayerMap(lgraph);

    for i=1:height(lgraph.Connections)
        src=lgraph.Connections.Source{i};
        dst=lgraph.Connections.Destination{i};
        src=extractLayerName(src);
        dst=extractLayerName(dst);
        if isa(map(src),'nnet.cnn.layer.ImageInputLayer')&&...
            isa(map(dst),'nnet.cnn.layer.BatchNormalizationLayer')
            list{index}=[src,dst];%#ok<AGROW> 
            index=index+1;
        end
    end
end



function lnames=getLayerDestinations(net,layername)
    cnx=net.Connections;
    cnxTF=strcmp(cnx.Source,layername);
    lnames=cnx.Destination(cnxTF);
    lnames=string(lnames);
end





function y=extractLayerName(x)
    parts=strsplit(x,'/');
    y=string(parts{1});
end



function map=createLayerNameToLayerMap(lgraph)
    map=containers.Map();
    for i=1:numel(lgraph.Layers)
        layer=lgraph.Layers(i);


        map(layer.Name)=layer;
    end
end


