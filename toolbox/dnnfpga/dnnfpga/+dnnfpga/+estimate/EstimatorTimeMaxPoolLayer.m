classdef EstimatorTimeMaxPoolLayer<dnnfpga.estimate.EstimatorTransfer&dnnfpga.estimate.EstimatorConvp

    properties
MaxPoolSingleExecutionDelay
    end

    methods
        function MaxPoolLayerTime=GetLayerTime(this,cnnp,HWparams,param,InternalArchParam)
            tileIRParams=cnnp.getTileIR(param);
            cc=cnnp.getCC.conv;
            dataTransNum=cnnp.getCC.op0.dataTransNum;
            conv2Processor=cnnp.getConvProcessor;
            MaxPoolLayerTime.layer=this.getlayerResultInit;
            for i=1:length(tileIRParams)
                TileInfo=this.EstimatorGetTileInfo(tileIRParams{i},dataTransNum);
                OneTileResult=this.GetTileTime(TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor);
                if i==1
                    MaxPoolLayerTime.firstTile=OneTileResult;
                end

                MaxPoolLayerTime.layer=this.accuTileToLayer(MaxPoolLayerTime.layer,OneTileResult);
            end
        end

        function MaxPoolTileTime=GetTileTime(this,TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor)
            TileOpt=this.getTileOpt(TileInfo,HWparams,InternalArchParam);
            TileCompute=this.GetMaxPoolTileCompTime(TileInfo,HWparams,cc,param,conv2Processor);
            TileInBurst=this.getTileInBurst(TileInfo,HWparams,InternalArchParam);
            TileOutBurst=this.getTileOutBurst(TileInfo,HWparams,InternalArchParam);
            MaxPoolTileTime=this.AssembleTileResult(TileInfo,TileOpt,TileCompute,TileInBurst,TileOutBurst,InternalArchParam);
        end

        function MaxPoolTileCompTime=GetMaxPoolTileCompTime(this,TileInfo,HWparams,cc,param,conv2Processor)
            param=this.emitParam(TileInfo,param);
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,cc);
            tMaxpool=conv2Processor.calMaxpoolTime(lc);

            this.getMaxPoolDelay(HWparams.TargetPlatform);
























            if cc.kernelDataType=="single"
                tExtra=11;
            else
                tExtra=24;
            end

            MaxPoolTileCompTime=tMaxpool+this.IPtoConvDelay+this.ConvtoOPDelay-tExtra;
        end

        function TileOpt=getTileOpt(this,TileInfo,HWparams,InternalArchParam)
            OneTileTotalOp=TileInfo.IndeltaX*TileInfo.IndeltaY*TileInfo.inputN;
            TileOpt.TileComputationCycleOpt=OneTileTotalOp/(3*3*HWparams.ConvThreadNumber);

            TileOpt.TileLoadInputCycleOpt=TileInfo.IndeltaX*TileInfo.IndeltaY*TileInfo.inputN/floor(InternalArchParam.DDRBitWidth/HWparams.dataType);

            TileOpt.TileWriteOutputCycleOpt=(TileInfo.OutdeltaX*TileInfo.OutdeltaY*TileInfo.outputM/floor(InternalArchParam.DDRBitWidth/HWparams.dataType))*1.1;
        end

        function getMaxPoolDelay(this,boardName)
            MaxpoolOverhead=this.getMaxPoolOverhead(boardName);
            this.MaxPoolSingleExecutionDelay=MaxpoolOverhead.execution;
            this.IPtoConvDelay=MaxpoolOverhead.start;
            this.ConvtoOPDelay=MaxpoolOverhead.end;
        end
    end
end


