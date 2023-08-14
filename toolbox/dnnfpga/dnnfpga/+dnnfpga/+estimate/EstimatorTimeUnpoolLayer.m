classdef EstimatorTimeUnpoolLayer<dnnfpga.estimate.EstimatorTimeConvLayer




    methods


        function ConvTileCompTime=GetConvTileCompTime(this,TileInfo,HWparams,cc,param,conv2Processor,calData)



            param=this.emitParam(TileInfo,param);








            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,cc);


            BurstSize=cc.convWeightBurstLength;
            tConv=conv2Processor.calUnpoolTime(lc,HWparams.TargetPlatform,HWparams.TargetFrequency,BurstSize,calData);


            this.getConvDelay(HWparams.TargetPlatform);
            ConvTileCompTime=tConv+this.IPtoConvDelay+this.ConvtoOPDelay;
        end

    end
end
