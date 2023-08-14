classdef pskDemodulator<hdlcommblks.internal.AbstractCommHDL


































    methods
        function this=pskDemodulator(block)




            supportedBlocks={...
            ['commdigbbndpm3/QPSK',newline,'Demodulator',newline,'Baseband'],...
            ['commdigbbndpm3/BPSK',newline,'Demodulator',newline,'Baseband'],...
            ['commdigbbndpm3/M-PSK',newline,'Demodulator',newline,'Baseband'],...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Elaboration for PSK Demodulator',...
            'HelpText','HDL code generation for PSK Demodulator via elaboration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);


        end

    end

    methods
        prm=buildBlockParams(this,hC)
        prm=buildSysObjParams(this,sysObjHandle)
        newC=elaborateBPSK(this,prm)
        newC=elaborateMPSK(this,prm)
        val=hasDesignDelay(~,~,~)
        outputDTC(this,hN,decision,outsig)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        [derot,newC]=derotate(this,prm,insig)
        hNewC=elaborate(this,hN,hC)
        newC=elaborateQPSK(this,prm)
        tf=isHardDecision(this,hC)
        decision=qpskCompareAndDecide(this,prm,derot)
        newLUT=remapLUT(this,origLUT,mapping)
        compout_sig=slicerCompares(this,hN,cmpops,derot_sig)
        decision=slicerLUT(this,hN,LUTvalues,compout_sig,decision_name)
        v=validateBlock(this,hC)
    end

end

