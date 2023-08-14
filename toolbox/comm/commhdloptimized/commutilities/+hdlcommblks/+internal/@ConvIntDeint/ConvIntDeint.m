classdef ConvIntDeint<hdlcommblks.internal.GenMuxIntDeint


































    methods
        function this=ConvIntDeint(block)




            supportedBlocks={...
            'commcnvintrlv2/Convolutional Interleaver',...
'commcnvintrlv2/Convolutional Deinterleaver'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Shift Reg implementation for Conv Int & Deint blocks',...
            'HelpText','Shift Reg implementation for Conv Int & Deint blocks');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'ShiftRegister'});

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        blockInfo=getBlockInfo(this,hC)
        [intdelay,N,B]=getIntDelay(this,hC)
        blockInfo=getSysObjInfo(this,sysObj)
        val=hasDesignDelay(~,~,~)
    end

end

