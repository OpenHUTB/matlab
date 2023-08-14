classdef DualPortRam<hdldefaults.abstractRam



    methods
        function this=DualPortRam(block)
            supportedBlocks={...
            'none',...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Generic Dual-port RAM Block HDL instantiation',...
            'HelpText','Generic Dual-port RAM Block code generation via direct HDL instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc);

            this.initParam('dualport');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC,BlockParam)
        hdlcode=emitRamWrapper(this,hC)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hdlcode=emit(this,hC)
        generateClocks(this,~,hC)
    end

end

