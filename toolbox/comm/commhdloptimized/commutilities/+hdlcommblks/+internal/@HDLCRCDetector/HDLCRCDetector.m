classdef HDLCRCDetector<hdlcommblks.internal.abstractCRC






























    methods
        function this=HDLCRCDetector(block)












            supportedBlocks={...
            'commhdlcrc/General CRC Syndrome Detector HDL Optimized',...
'comm.HDLCRCDetector'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for General CRC Syndrome Detector HDL Optimized',...
            'HelpText','HDL Support for General CRC Syndrome Detector HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end

    end

    methods
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        cmpNet=elabCRCCompare(~,topNet,blockInfo,inRate)
        nComp=elaborate(this,hN,hC)
        elaborateCRCDetNetwork(this,topNet,blockInfo)
    end

end

