classdef LookupHDLInstantiation<hdlimplbase.HDLDirectCodeGen



    methods
        function this=LookupHDLInstantiation(block)
            supportedBlocks={...
            'built-in/Lookup',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Lookup table HDL instantiation',...
            'HelpText','Lookup table code generation via instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames','Instantiate');


        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        elaborate(this,hN,hC)
        hdlcode=emit(this,hC)
        stateInfo=getStateInfo(this,hC)
        mainEarlyElaborate(this,hN,hC)
        mainElaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

