classdef ForEachNPU<hdlimplbase.EmlImplBase





    methods
        function this=ForEachNPU(block)
            supportedBlocks={...
            'built-in/Neighborhood',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        registerImplParamInfo(this);
    end

end

