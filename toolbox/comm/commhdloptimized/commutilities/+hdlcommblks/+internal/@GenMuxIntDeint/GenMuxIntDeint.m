classdef GenMuxIntDeint<hdlcommblks.internal.AbstractCommHDL





































    methods
        function this=GenMuxIntDeint(block)




            supportedBlocks={...
            'commcnvintrlv2/General Multiplexed Interleaver',...
            'commcnvintrlv2/General Multiplexed Deinterleaver',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Shift Reg implementation for General Multiplexed Int & Deint blocks',...
            'HelpText','Shift Reg implementation for General Multiplexed Int & Deint blocks');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'ShiftRegister'});

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        nComp=elaborateIntDeint(this,hN,hC,intdelay,blkComment)
        elaborateIntDeintShiftReg(this,hN,hC,intdelay)
        blockInfo=getBlockInfo(this,hC)
        intdelay=getIntDelay(this,hC)
        blockInfo=getSysObjInfo(this,sysObj)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

