function net_mod=wrapResize2DLayers(net,processor)




















    cc=processor.getCC();

    lgraph=net.layerGraph;
    NA=nnet.internal.cnn.analyzer.NetworkAnalyzer(net);
    layers=NA.ExternalLayers;
    n=numel(layers);

    for i=1:n
        if isa(layers(i),'nnet.cnn.layer.Resize2DLayer')

            LA=NA.LayerAnalyzers(i);


            validateLayer(LA,cc);


            children=LA.Outputs.Destination(:);
            parent1=LA.Inputs.Source{1};
            if numel(LA.Inputs.Source)==2
                parent2=LA.Inputs.Source{2};
            else
                parent2=[];
            end


            name=LA.Name;
            ipsize=LA.Inputs.Size{1};
            opsize=LA.Outputs.Size{1};
            rsz=dnnfpga.custom.Resize2DLayer(ipsize(1:2),opsize(1:2),Name=name);

            if isa(net,'SeriesNetwork')

                lgraph=replaceLayer(lgraph,layers(i).Name,rsz);

            elseif isa(net,'DAGNetwork')||isa(net,'dlnetwork')

                lgraph=removeLayers(lgraph,layers(i).Name);


                lgraph=addLayers(lgraph,rsz);


                lgraph=connectLayers(lgraph,parent1,rsz.Name);
                for j=1:numel(children)
                    child=children{j};
                    lgraph=connectLayers(lgraph,rsz.Name,child);
                end


                if~isempty(parent2)
                    p2id=getIDfromName(layers,parent2);
                    p2LA=NA.LayerAnalyzers(p2id);
                    if size(p2LA.Outputs,1)==1&&numel(p2LA.Outputs.Destination{:})==1
                        lgraph=removeLayers(lgraph,parent2);
                    end
                end
            end
        end
    end


    if isa(net,'SeriesNetwork')
        net_mod=assembleNetwork(lgraph.Layers);
    elseif isa(net,'DAGNetwork')
        net_mod=assembleNetwork(lgraph);
    elseif isa(net,'dlnetwork')
        net_mod=dlnetwork(lgraph);
    end

end

function validateLayer(LA,cc)



    LINELEN=cc.addp.ResizeLineLen;
    MAXSCALE=cc.addp.ResizeNearestScale;
    MINSCALE=2;

    layer=LA.ExternalLayer;
    inputsize1=LA.Inputs.Size{1};
    inputsize1=inputsize1(1:2);
    try
        inputsize2=LA.Inputs.Size{2};
        inputsize2=inputsize2(1:2);
    catch
        inputsize2=[];
    end

    if inputsize1(1)>LINELEN||inputsize1(2)>LINELEN
        property='number of columns in the input';
        name=layer.Name;
        if inputsize1(1)>LINELEN
            value=inputsize1(1);
        elseif inputsize1(2)>LINELEN
            value=inputsize1(2);
        end
        supported=sprintf('less than or equal to %d',LINELEN);
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize1',...
        property,name,value,supported);
        error(msg);
    end
    if~strcmpi(layer.Method,'nearest')
        property='Method property';
        name=layer.Name;
        value=layer.Method;
        supported='nearest';
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize2',...
        property,name,value,supported);
        error(msg);
    end
    if~strcmpi(layer.GeometricTransformMode,'half-pixel')
        property='GeometricTransformMode property';
        name=layer.Name;
        value=layer.GeometricTransformMode;
        supported='half-pixel';
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize2',...
        property,name,value,supported);
        error(msg);
    end
    if~strcmpi(layer.NearestRoundingMode,'round')
        property='NearestRoundingMode property';
        name=layer.Name;
        value=layer.NearestRoundingMode;
        supported='round';
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize2',...
        property,name,value,supported);
        error(msg);
    end
    if~isempty(layer.Scale)
        validateScale(layer.Name,layer.Scale,MINSCALE,MAXSCALE);
    end
    if~isempty(layer.OutputSize)
        calculatedScale=layer.OutputSize./inputsize1;
        validateScale(layer.Name,calculatedScale,MINSCALE,MAXSCALE);
    end
    if layer.EnableReferenceInput
        calculatedScale=inputsize2./inputsize1;
        validateScale(layer.Name,calculatedScale,MINSCALE,MAXSCALE);
    end
end

function id=getIDfromName(layers,name)
    fn=@(layer)strcmp(layer.Name,name);
    tf=arrayfun(fn,layers);
    ids=1:numel(layers);
    id=ids(tf);
end

function validateScale(name,scale,MINSCALE,MAXSCALE)
    property='ratio of the output size to the input size';
    scaleStr="["+num2str(scale)+"]";
    if any(isIntegral(scale)==false)
        supported='an integer';
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize1',...
        property,name,scaleStr,supported);
        error(msg);
    end
    if any(scale<MINSCALE)
        supported=sprintf('greater than or equal to %d',MINSCALE);
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize1',...
        property,name,scaleStr,supported);
        error(msg);
    end
    if any(scale>MAXSCALE)
        supported=sprintf('lesser than or equal to %d',MAXSCALE);
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedResize1',...
        property,name,scaleStr,supported);
        error(msg);
    end
end


function tf=isIntegral(x)
    tf=ceil(x)==x;
end


