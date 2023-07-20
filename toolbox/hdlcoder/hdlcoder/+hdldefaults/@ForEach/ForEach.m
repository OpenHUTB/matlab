classdef ForEach<hdlimplbase.EmlImplBase



    methods
        function this=ForEach(block)
            supportedBlocks={...
            'built-in/ForEach',...
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

