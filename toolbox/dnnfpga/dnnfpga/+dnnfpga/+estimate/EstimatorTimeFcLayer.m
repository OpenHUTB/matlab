classdef EstimatorTimeFcLayer<dnnfpga.estimate.EstimatorTransfer


    methods


        function FcLayerTime=GetLayerTime(this,hPC,cnnp,param,HWparams,InternalArchParam,layerIndex,NumofFcLayers,calData)
            LayerInfo=this.getLayerInfo(param);

            if layerIndex==1
                LayerInBurst=this.getLayerInBurst(LayerInfo);
            else
                LayerInBurst=0;
            end

            if layerIndex==NumofFcLayers
                LayerOutBurst=this.getLayerOutBurst(LayerInfo);
            else
                LayerOutBurst=0;
            end

            LayerCompute=this.GetFcLayerCompTime(hPC,param,cnnp,calData);
            LayerOpt=this.getLayerOpt(LayerInfo,HWparams);
            FcLayerTime.layer=this.AssembleLayerResult(LayerOpt,LayerCompute,LayerInBurst,LayerOutBurst,InternalArchParam);

        end


        function FcLayerCompTime=GetFcLayerCompTime(this,hPC,param,cnnp,calData)
            nc=this.resolveNC(param);
            cc=cnnp.getCC();

            if(strcmp(cc.kernelDataType,'single'))
                cc.opBitWidthLimit=32;
            elseif(strcmp(cc.kernelDataType,'half'))
                cc.opBitWidthLimit=16;
            else
                cc.opBitWidthLimit=8;
            end



            WeightSize=nc.WeightSize/cc.threadNumLimit;
            bitWidth=cc.opDDRBitWidthLimit;
            DDRToBitWidthRatio=(bitWidth/cc.opBitWidthLimit);
            BurstSize=cc.coefFifoSizeLimit*(cc.threadNumLimit/DDRToBitWidthRatio)/2;
            NumLayers=nc.layerNumMinusOne;

            NumRAMInvolved=2;
            ReadyDelay=1;
            BurstDelay=1;
            FSMDelay=1;

            ClockValue=hPC.TargetFrequency;
            boardType=hPC.TargetPlatform;


            DDRRespTime=dnnfpga.processorbase.fcProcessor.getBoardResposeTime(BurstSize,ClockValue,boardType);
            DDRRespTime=round(DDRRespTime);



            TimeForOneWeightBURSTRead=ReadyDelay+BurstDelay+DDRRespTime+FSMDelay;

            TotalFCWeightReadTimeWithAXI=(round(double(WeightSize)/BurstSize))*TimeForOneWeightBURSTRead;

            LayerConfigTime=cc.layerConfigNumWLimit;


            NFFLoopLatency=cc.RAWHazardLatencyThreshold;
            RAMReadLatency=NumRAMInvolved*cc.MemReadLatency;
            TotalPathLatency=NumLayers*(NFFLoopLatency+RAMReadLatency);



            FcLayerCompTime=(TotalFCWeightReadTimeWithAXI+LayerConfigTime+TotalPathLatency);


        end

        function LayerTime=AssembleLayerResult(this,LayerOpt,LayerCompute,LayerInBurst,LayerOutBurst,InternalArchParam)
            if(strcmp(InternalArchParam.doubleBuffer,'true'))
                LayerProcessCycle=max(LayerCompute,max(LayerInBurst,LayerOutBurst));
                LayerProcessCycleOpt=max(LayerOpt.LayerComputationCycleOpt,max(LayerOpt.LayerLoadInputCycleOpt,LayerOpt.LayerWriteOutputCycleOpt));
            elseif(strcmp(InternalArchParam.doubleBuffer,'false'))
                LayerProcessCycle=LayerCompute+LayerInBurst+LayerOutBurst;
                LayerProcessCycleOpt=LayerOpt.LayerComputationCycleOpt+LayerOpt.LayerLoadInputCycleOpt+LayerOpt.LayerWriteOutputCycleOpt;
            end

            LayerTime.LayerProcessCycle=LayerProcessCycle;
            LayerTime.LayerComputationCycle=LayerCompute;
            LayerTime.LayerInputBusrtCycle=LayerInBurst;
            LayerTime.LayerOutputBusrtCycle=LayerOutBurst;


            LayerTime.LayerProcessCycleOpt=LayerProcessCycleOpt;
            LayerTime.LayerComputationCycleOpt=LayerOpt.LayerComputationCycleOpt;
            LayerTime.LayerLoadInputCycleOpt=LayerOpt.LayerLoadInputCycleOpt;
            LayerTime.LayerWriteOutputCycleOpt=LayerOpt.LayerWriteOutputCycleOpt;
        end


        function LayerOpt=getLayerOpt(this,LayerInfo,HWparams)

            LayerOpt.LayerComputationCycleOpt=ceil(LayerInfo.input*LayerInfo.output/HWparams.FcThreadNumber);

            LayerOpt.LayerLoadInputCycleOpt=ceil(LayerInfo.input*LayerInfo.input/4);

            LayerOpt.LayerWriteOutputCycleOpt=ceil(LayerInfo.input*LayerInfo.output/4);
        end

        function LayerInfo=getLayerInfo(this,param)
            LayerInfo.input=param.matrixSize(1,1);
            LayerInfo.output=param.matrixSize(1,2);
        end




        function nc=resolveNC(~,param)

            nc.layerNumMinusOne=length(param);
            weightSize=0;
            weightSize=weightSize+prod(param.matrixSize+[1,0]);
            nc.WeightSize=weightSize;

            nc.result_count=3;
        end
    end
end
