classdef ThirdPartyBlackBox<hdldefaults.abstractBBox



    methods
        function this=ThirdPartyBlackBox(block)
            mlock;
        end

    end

    methods
        [port,portpath]=findioport(this,blk,varargin)
        stateInfo=getStateInfo(this,hC)
        blktype=getportdatatype(this,blk,is_inport)
        val=hasDesignDelay(~,~,~)
        printdatatype(this,sysname,pstruct,thirdpname)
        r=isCharacterizableBlock(~)
    end

end

