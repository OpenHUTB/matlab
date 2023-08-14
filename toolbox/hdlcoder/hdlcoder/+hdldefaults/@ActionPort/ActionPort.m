classdef ActionPort<hdlimplbase.EnablePortBase





    methods
        function this=ActionPort(block)
            supportedBlocks={...
            'built-in/ActionPort',...
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

    methods(Hidden)
        function v=validateBlock(this,hC)
            v=baseValidateEnablePort(this,hC);
        end
    end

end

