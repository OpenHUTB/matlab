classdef LookupHDLEmission<hdlimplbase.HDLDirectCodeGen



    methods
        function this=LookupHDLEmission(block)
            supportedBlocks={...
            'built-in/Lookup',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Lookup table HDL emission',...
            'HelpText','Lookup table code generation via direct HDL emission');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames','Inline');

        end

    end

    methods
        hdlcode=emit(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        fixblkinhdllib(this,blkh)
    end

end

