classdef HDLCRCGenerator<hdlcommblks.internal.abstractCRC






























    methods
        function this=HDLCRCGenerator(block)












            supportedBlocks={...
            'commhdlcrc/General CRC Generator HDL Optimized',...
'comm.HDLCRCGenerator'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for General CRC Generator HDL Optimized',...
            'HelpText','HDL Support for General CRC Generator HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end

    end

    methods
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        nComp=elaborate(this,hN,hC)
    end

end

