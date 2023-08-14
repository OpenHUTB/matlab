classdef MatrixGain<hdldefaults.Gain



    methods
        function this=MatrixGain(block)
            supportedBlocks={...
            'built-in/Gain',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Matrix Multiply',...
            'Deprecates',{});
        end
    end

    methods
        matMulStrategy=getMatMulStrategy(this,~)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
    end
end
