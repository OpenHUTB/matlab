classdef pipelineRegister<hdldefaults.abstractReg



    methods
        function this=pipelineRegister(block)
            supportedBlocks={'none'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Pipeline Register HDL emission',...
            'HelpText','Pipeline Register code generation via direct HDL emission');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

    methods
        hdlcode=emit(this,hC)
        generateClocks(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
    end
end

