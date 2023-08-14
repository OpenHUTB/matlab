classdef FrameConversionHDLEmission<hdlimplbase.HDLDirectCodeGen



    methods
        function this=FrameConversionHDLEmission(block)
            supportedBlocks={...
            'built-in/FrameConversion',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Frame Conversion HDL emission',...
            'HelpText','Frame Conversion code generation via direct HDL emission');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        [outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,originalBlkPath,targetBlkPath)
        hdlcode=emit(this,hC)
        generateSLBlock(this,hC,targetBlkPath)
        v=getHelpInfo(this,blkPath)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
    end

end

