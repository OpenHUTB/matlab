classdef RectQAMModulator<hdlcommblks.internal.AbstractCommHDL
































    methods
        function this=RectQAMModulator(block)




            supportedBlocks={...
            ['commdigbbndam3/Rectangular QAM',newline,'Modulator',newline,'Baseband'],...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Elaboration for Rectangular QAM Modulator',...
            'HelpText','HDL code generation for Rectangular QAM Modulator via elaboration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);


        end

    end

    methods
        prm=buildBlockParams(this,hC,hN)
        prm=buildSysObjParams(this,hC,hN,sysObjHandle)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

