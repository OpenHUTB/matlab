classdef pskModulator<hdlcommblks.internal.AbstractCommHDL
































    methods
        function this=pskModulator(block)




            supportedBlocks={...
            ['commdigbbndpm3/QPSK',newline,'Modulator',newline,'Baseband'],...
            ['commdigbbndpm3/BPSK',newline,'Modulator',newline,'Baseband'],...
            ['commdigbbndpm3/M-PSK',newline,'Modulator',newline,'Baseband'],...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Elaboration for PSK Modulator',...
            'HelpText','HDL code generation for PSK Modulator via elaboration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);


        end

    end

    methods
        prm=buildBlockParams(this,hC)
        prm=buildSysObjParams(this,hC,sysObjHandle)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

