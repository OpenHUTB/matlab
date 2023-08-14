classdef fpgaDeployment<dnnfpga.bitstreambase.abstractDeployment




    properties(Access=private)
        m_fpgaLayer={}
    end

    methods(Access=public,Hidden=true)
        function obj=fpgaDeployment(deployableNetwork,platform,...
            streamingMode,streamingContinuous,...
            useCustomBaseAddr,inputBaseAddr,outputBaseAddr)

            if nargin<3
                streamingMode=false;
            end
            if nargin<4
                streamingContinuous=false;
            end
            if nargin<5
                useCustomBaseAddr=false;
            end
            obj@dnnfpga.bitstreambase.abstractDeployment(deployableNetwork,platform);
            layers=deployableNetwork.getLayers();
            for i=1:length(layers)
                if(strcmpi(class(layers{i}),'dnnfpga.deployablenetwork.fpgaLayer'))
                    assert(isempty(obj.m_fpgaLayer),'Can''t handle multiple FPGA layers');
                    obj.m_fpgaLayer=layers{i};
                end
            end
            if(~isempty(obj.m_fpgaLayer))
                obj.m_fpgaLayer.setPlatform(obj.m_platform);
                obj.m_fpgaLayer.setStreamingMode(streamingMode);
                obj.m_fpgaLayer.setStreamingContinuous(streamingContinuous);
                if useCustomBaseAddr
                    offsetMap=obj.m_fpgaLayer.getDDROffsetMap();
                    offsetMap('InputDataOffsetAlt')=inputBaseAddr;
                    offsetMap('OutputResultOffsetAlt')=outputBaseAddr;
                end
            end
        end
    end

    methods(Access=public)
        function pass=check(this)
            pass=true;
        end

        function init(this,verbose)
            this.m_deployableNetwork.init(verbose);
        end

        function output=predict(this,input,resetBefore,resetAfter)
            fpgaLayer=this.m_deployableNetwork.getSingletonFPGALayer;
            if resetBefore
                fpgaLayer.resetState();
            end
            output=this.m_deployableNetwork.predict(input);
            if resetAfter
                fpgaLayer.resetState();
            end
        end

        function setupProfiler(this,option)
            this.m_platform.setupProfiler(option);
        end

        function rawLogs=scanProfiler(this,option)


            fpgaLayer=this.m_deployableNetwork.getSingletonFPGALayer;



            rawLogs=this.m_platform.scanProfiler(option,fpgaLayer);
        end
    end

    methods(Access=public,Static=true)
        function YFormatted=formatPredictions(Y)

            Y=squeeze(Y);
            if(numel(size(Y))==2)

                YFormatted=permute(Y,[2,1]);
            else
                YFormatted=Y;
            end
        end

    end
end


