classdef RectQAMDemodulator<hdlcommblks.internal.AbstractCommHDL

































    methods
        function this=RectQAMDemodulator(block)




            supportedBlocks={...
            ['commdigbbndam3/Rectangular QAM',newline,'Demodulator',newline,'Baseband'],...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Elaboration for Rectangular QAM Demodulator',...
            'HelpText','HDL code generation for Rectangular QAM Demodulator via elaboration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);


        end

    end

    methods
        prm=buildBlockParams(this,hC,hN)
        prm=buildSysObjParams(this,hC,hN,sysObjHandle)
        val=hasDesignDelay(~,~,~)
        makeOutput(this,prm,e,LUTidx)
        [re,im]=trivialDerotate(this,prm,e)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

