classdef fixedPointFrontend<dnnfpga.compiler.abstractDNNCompilerStage





    methods(Access=public,Hidden=true)
        function obj=fixedPointFrontend(varargin)
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function fpgaParamLayers=doit(~,input,processor,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'Verbose',1);
            addParameter(p,'LegLevel',0);


            parse(p,varargin{:});
            net=input.net;
            argin=input.argin;



            added=[argin,'Verbose',p.Results.Verbose,'LegLevel',p.Results.LegLevel];

            layerObjects=dnnfpga.compiler.fixedPointFrontend.createLayerObjects(net);
            fpgaParamLayers=dnnfpga.compiler.fixedPointFrontend.getParams(net,layerObjects,processor,added{:});
        end
    end


    methods(Access=private,Static=true)

        function fpgaParamLayers=getParams(net,layerObjects,processor,varargin)

            fpgaParamLayers={};
            parameterFactory=dnnfpga.layer.paramFactory;
            fpgaParamLayers=parameterFactory.createParams(net,layerObjects,processor,varargin{:});

        end

        function layerObjects=createLayerObjects(net)

            net=dnnfpga.compiler.optimizations.optimizeNetwork(net);

            layerFactory=dnnfpga.layer.layerFactory;
            layerObjects={};
            numLayers=numel(net.Layers);

            for i=1:numLayers
                layer=net.Layers(i);
                layerObjects{i}=layerFactory.createLayerObject(layer);
            end

        end
    end

end
