classdef EstimatorTimeLrnLayer<dnnfpga.estimate.EstimatorTransfer&dnnfpga.estimate.EstimatorConvp

    properties
LrnSingleExecutionDelay
    end

    methods
        function LrnLayerTime=GetLayerTime(this,cnnp,HWparams,param,InternalArchParam,cc)
            tileIRParams=cnnp.getTileIR(param);
            cc=cnnp.getCC.conv;
            dataTransNum=cnnp.getCC.op0.dataTransNum;
            conv2Processor=cnnp.getConvProcessor;
            LrnLayerTime.layer=this.getlayerResultInit;
            for i=1:length(tileIRParams)
                TileInfo=this.EstimatorGetTileInfo(tileIRParams{i},dataTransNum);
                OneTileResult=this.GetTileTime(TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor);
                if i==1
                    LrnLayerTime.firstTile=OneTileResult;
                end

                LrnLayerTime.layer=this.accuTileToLayer(LrnLayerTime.layer,OneTileResult);
            end
        end

        function LrnTileTime=GetTileTime(this,TileInfo,HWparams,InternalArchParam,cc,param,conv2Processor)
            TileOpt=this.getTileOpt(TileInfo,HWparams,InternalArchParam);
            TileCompute=this.GetLrnTileCompTime(TileInfo,HWparams,cc,param,conv2Processor);
            TileInBurst=this.getTileInBurst(TileInfo,HWparams,InternalArchParam);
            TileOutBurst=this.getTileOutBurst(TileInfo,HWparams,InternalArchParam);
            LrnTileTime=this.AssembleTileResult(TileInfo,TileOpt,TileCompute,TileInBurst,TileOutBurst,InternalArchParam);
        end

        function LrnTileCompTime=GetLrnTileCompTime(this,TileInfo,HWparams,cc,param,conv2Processor)
            param=this.emitParam(TileInfo,param);
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,cc);
            tLrn=conv2Processor.calLrnTime(lc);
            this.getLrnDelay(HWparams.TargetPlatform);















            LrnTileCompTime=tLrn;



        end

        function TileOpt=getTileOpt(this,TileInfo,HWparams,InternalArchParam)

            TileOpt.TileComputationCycleOpt=0;

            TileOpt.TileLoadInputCycleOpt=TileInfo.IndeltaX*TileInfo.IndeltaY*TileInfo.inputN/floor(InternalArchParam.DDRBitWidth/HWparams.dataType);

            TileOpt.TileWriteOutputCycleOpt=(TileInfo.OutdeltaX*TileInfo.OutdeltaY*TileInfo.outputM/floor(InternalArchParam.DDRBitWidth/HWparams.dataType))*1.1;
        end

        function getLrnDelay(this,boardName)
            LrnOverhead=this.getLrnOverhead(boardName);
            this.LrnSingleExecutionDelay=LrnOverhead.execution;
            this.IPtoConvDelay=LrnOverhead.start;
            this.ConvtoOPDelay=LrnOverhead.end;
        end
    end
end
