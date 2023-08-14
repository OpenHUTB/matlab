classdef MultiplyAccumulateSerial<hdldefaults.MultiplyAccumulate



    methods
        function this=MultiplyAccumulateSerial(block)
            supportedBlocks={...
'hdlsllib/HDL Operations/Multiply-Accumulate'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'ArchitectureNames','Serial',...
            'Block',block);


        end

    end

    methods(Hidden)
        em=getElabMode(~)
    end

end

