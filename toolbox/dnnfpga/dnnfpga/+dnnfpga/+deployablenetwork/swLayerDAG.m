classdef swLayerDAG<dnnfpga.deployablenetwork.abstractLayer



    properties(Access=public)
m_callback
m_layerName
        m_params=struct;
    end

    methods(Access=public,Hidden=true)
        function obj=swLayerDAG(component,inputSize,callback,varargin)
            if isprop(component,'name')
                name=component.name;
            end
            obj@dnnfpga.deployablenetwork.abstractLayer(name);
            obj.m_callback=callback;
            obj.m_layerName=name;
            obj.m_params.inputSize=inputSize;



            if isprop(component,'outputExp')
                obj.m_params.rescaleExp=component.outputExp;
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

