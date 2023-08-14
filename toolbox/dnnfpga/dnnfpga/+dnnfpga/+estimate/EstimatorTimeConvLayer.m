classdef EstimatorTimeConvLayer<dnnfpga.estimate.EstimatorTransfer&dnnfpga.estimate.EstimatorConvp

    properties
ConvSingleExecutionDelay
    end


    methods

        function ConvLayerTime=GetLayerTime(this,cnnp,HWparams,param,InternalArchParam,calData)
            tileIRParams=cnnp.getTileIR(param);
            cc=cnnp.getCC.conv;
            dataTransNum=cnnp.getCC.op0.dataTransNum;
            conv2Processor=cnnp.getConvProcessor;
            ConvLayerTime.layer=this.getlayerResultInit;
            for i=1:length(tileIRParams)
                TileInfo=this.EstimatorGetTileInfo(tileIRParams{i},dataTransNum);
                OneTileResult=this.GetTileTime(TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor,calData);
                if i==1
                    ConvLayerTime.firstTile=OneTileResult;
                end

                ConvLayerTime.layer=this.accuTileToLayer(ConvLayerTime.layer,OneTileResult);
            end
        end


        function ConvTileTime=GetTileTime(this,TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor,calData)
            if(InternalArchParam.kernelSize==3)
                TileCompute=this.GetConvTileCompTime(TileInfo,HWparams,cc,param,conv2Processor,calData);
            elseif(InternalArchParam.kernelSize==1)
                TileCompute=this.GetConvTileCompTimeOnebyOneKernel(TileInfo,HWparams);
            end
            TileInBurst=this.getTileInBurst(TileInfo,HWparams,InternalArchParam,calData);
            TileOutBurst=this.getTileOutBurst(TileInfo,HWparams,InternalArchParam,calData);
            TileOpt=this.getTileOpt(TileInfo,HWparams,InternalArchParam);
            ConvTileTime=this.AssembleTileResult(TileInfo,TileOpt,TileCompute,TileInBurst,TileOutBurst,InternalArchParam);
        end

        function ConvTileCompTime=GetConvTileCompTime(this,TileInfo,HWparams,cc,param,conv2Processor,calData)


            param=this.emitParam(TileInfo,param);







            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,cc);

            BurstSize=ceil((prod(cc.opSize)*cc.threadNumLimitSquared+cc.threadNumLimit*cc.biasFactor)/cc.opDDRRatio);
            tConv=conv2Processor.calConvTime(lc,HWparams.TargetPlatform,HWparams.TargetFrequency,BurstSize,calData);

            this.getConvDelay(HWparams.TargetPlatform);

























            ConvTileCompTime=tConv+this.IPtoConvDelay+this.ConvtoOPDelay;
        end

        function ConvTileCompTimeOnebyOneKernel=GetConvTileCompTimeOnebyOneKernel(this,TileInfo,HWparams)


            ConvTileCompTimeOnebyOneKernel=[];






















        end

        function TileOpt=getTileOpt(this,TileInfo,HWparams,InternalArchParam)
            OneTileTotalMAC=TileInfo.OutdeltaX*TileInfo.OutdeltaY*TileInfo.weightR*TileInfo.weightC*TileInfo.inputN*TileInfo.outputM;

            if(InternalArchParam.kernelSize==3)
                TileOpt.TileComputationCycleOpt=ceil(OneTileTotalMAC/(3*3*HWparams.ConvThreadNumber*HWparams.ConvThreadNumber));
            elseif(InternalArchParam.kernelSize==1)
                TileOpt.TileComputationCycleOpt=ceil(OneTileTotalMAC/(1*1*HWparams.ConvThreadNumber*HWparams.ConvThreadNumber));
            end

            TileOpt.TileLoadInputCycleOpt=ceil(TileInfo.IndeltaX*TileInfo.IndeltaY*TileInfo.inputN/floor(InternalArchParam.DDRBitWidth/HWparams.dataType));

            TileOpt.TileWriteOutputCycleOpt=ceil((TileInfo.OutdeltaX*TileInfo.OutdeltaY*TileInfo.outputM/floor(InternalArchParam.DDRBitWidth/HWparams.dataType))*1.1);
        end

        function getConvDelay(this,boardName)
            ConvolutionOverhead=this.getConvolutionOverhead(boardName);
            this.ConvSingleExecutionDelay=ConvolutionOverhead.execution;
            this.IPtoConvDelay=ConvolutionOverhead.start;
            this.ConvtoOPDelay=ConvolutionOverhead.end;
        end

    end
end
