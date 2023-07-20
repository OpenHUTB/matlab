classdef MultiplyAccumulateParallel<hdldefaults.MultiplyAccumulate



    methods
        function this=MultiplyAccumulateParallel(block)
            supportedBlocks={...
'hdlsllib/HDL Operations/Multiply-Accumulate'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'ArchitectureNames','Parallel',...
            'Block',block);


        end

    end

    methods
        latencyInfo=getLatencyInfo(~,~)
        stateInfo=getStateInfo(~,~)
    end


    methods(Hidden)
        em=getElabMode(~)
    end

end

