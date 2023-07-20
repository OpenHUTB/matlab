classdef EstimatorTimeSigmoidLayer<dnnfpga.estimate.EstimatorTransfer

    methods


        function SigmoidLayerTime=GetLayerTime(this,hPC,cnnp,param,HWparams,InternalArchParam,layerIndex,NumofFcLayers,calData)
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

            LayerCompute=this.GetSigmoidLayerCompTime(hPC,param,cnnp,calData);
            LayerOpt=this.getLayerOpt(LayerInfo,HWparams);
            SigmoidLayerTime.layer=this.AssembleLayerResult(LayerOpt,LayerCompute,LayerInBurst,LayerOutBurst,InternalArchParam);

        end

        function SigmoidLayerCompTime=GetSigmoidLayerCompTime(this,hPC,param,cnnp,calData)
            nc=this.resolveNC(param);
            cc=cnnp.getCC();

            if(strcmp(cc.kernelDataType,'single'))
                cc.opBitWidthLimit=32;
            elseif(strcmp(cc.kernelDataType,'half'))
                cc.opBitWidthLimit=16;
            else
                cc.opBitWidthLimit=8;
            end


            NumLayers=nc.layerNumMinusOne;


            NumRAMInvolved=2;

            ClockValue=hPC.TargetFrequency;
            boardType=hPC.TargetPlatform;




            LayerConfigTime=cc.layerConfigNumWLimit;












            InputDataReadFromMemoryLatency=ceil((param.matrixSize(1)/cc.threadNumLimit))*1;
            CompletePathLatency=cc.InputOutputLatency+cc.DataMemReadLatency+cc.SingleProdLatency+cc.ExpLatency+cc.SingleSumLatency+...
            cc.DivideLatency+(cc.Int16_To_SingleLatency*log2(cc.threadNumLimit));

            TotalPathLatency=NumLayers*(InputDataReadFromMemoryLatency+CompletePathLatency);


            SigmoidLayerCompTime=(LayerConfigTime+TotalPathLatency);

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
