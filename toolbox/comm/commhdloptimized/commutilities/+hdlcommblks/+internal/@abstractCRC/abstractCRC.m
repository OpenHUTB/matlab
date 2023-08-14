classdef abstractCRC<hdlcommblks.internal.AbstractCommHDL































    methods
        function this=abstractCRC(~)










        end

    end

    methods
        y=GF2multiply(~,A,B)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        dins=demuxSignal(~,hN,inSignal,sname)
        cptNet=elabCRCCompute(this,topNet,blockInfo,inRate)
        ctlNet=elabCRCControl(~,topNet,blockInfo,inRate)
        genNet=elaborateCRCGen(this,topNet,blockInfo,inRate,isDetector)
        blockInfo=getBlockInfo(this,hC)
        muxSignal(~,hN,sArray,sVector)
    end

end

