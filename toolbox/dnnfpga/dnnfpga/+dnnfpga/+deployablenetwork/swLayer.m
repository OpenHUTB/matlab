classdef swLayer<dnnfpga.deployablenetwork.abstractLayer



    properties(Access=public)
m_callback
m_layerName
        m_params=struct('weights',[],'bias',[]);
    end

    methods(Access=public,Hidden=true)
        function obj=swLayer(snLayer,callback,varargin)
            name=snLayer;
            if isprop(snLayer,'Name')
                name=snLayer.Name;
            end
            if isfield(snLayer,'phase')
                name=snLayer.phase;
            end

            obj@dnnfpga.deployablenetwork.abstractLayer(name);
            obj.m_callback=callback;
            obj.m_layerName=name;
            if nargin>2
                params=varargin{1};
                if isfield(params,'weights')
                    obj.m_params.weights=params.weights;
                end
                if isfield(params,'bias')
                    obj.m_params.bias=params.bias;
                end
            end
            if isprop(snLayer,'InputSize')
                obj.m_params.inputSize=snLayer.InputSize;
            end
            if isfield(snLayer,'InputSize')
                obj.m_params.inputSize=snLayer.InputSize;
            end

            if isfield(snLayer,'rescaleExp')


                obj.m_params.rescaleExp=snLayer.rescaleExp;
            end
            if isfield(snLayer,'OutputExpData')


                obj.m_params.outputExp=snLayer.OutputExpData;
            end

            if isfield(snLayer,'type')
                obj.m_params.layerType=snLayer.type;
            end

            if isa(snLayer,'nnet.cnn.layer.SoftmaxLayer')
                obj.m_params.layerType=class(snLayer);
            end


            if isfield(snLayer,'frontendLayers')
                obj.m_params.frontendLayers=snLayer.frontendLayers;
            end

            if isfield(snLayer,'outputSize')
                obj.m_params.outputSize=snLayer.outputSize;
            end

        end
    end

    methods(Access=public)
        function output=forward(this,input)
            output=this.m_callback(input);






        end

        function size=getInputSize(this)
            size=zeros(0);
            if isfield(this.m_params,'inputSize')
                size=this.m_params.inputSize;
            end
        end
    end
end

