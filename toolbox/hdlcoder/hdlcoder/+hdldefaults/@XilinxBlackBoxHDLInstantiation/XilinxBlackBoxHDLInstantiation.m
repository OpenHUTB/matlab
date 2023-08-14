classdef XilinxBlackBoxHDLInstantiation<hdldefaults.abstractBBox



    methods
        function this=XilinxBlackBoxHDLInstantiation(block)
            supportedBlocks={...
            'built-in/SubSystem',...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Xilinx BlackBox HDL instantiation',...
            'HelpText','Instantiate a Xilinx Entity without recursively doing codegeneration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc,...
            'ArchitectureNames',{'XilinxBlackBox'},...
            'Hidden',true);


        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hdlcode=emit(this,hC)
        [port,portpath]=findioport(this,blk,is_inport)
        stateInfo=getStateInfo(this,hC)
        blktype=getportdatatype(this,blk,is_inport)
        val=hasDesignDelay(~,~,~)
        printdatatype(this,sysname,pstruct)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
        str=xilinxhdlname(this,strin,isport)
    end

end

