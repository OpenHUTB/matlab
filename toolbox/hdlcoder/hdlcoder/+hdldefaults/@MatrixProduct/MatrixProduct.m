classdef MatrixProduct<hdldefaults.Product



    methods
        function this=MatrixProduct(block)
            supportedBlocks={...
            'built-in/Product',...
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
        matrixMul=getMatMulKind(this)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
    end
end
