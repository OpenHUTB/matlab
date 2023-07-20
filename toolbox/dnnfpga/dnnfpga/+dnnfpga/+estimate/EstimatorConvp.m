classdef EstimatorConvp<handle




    properties


IPtoConvDelay

ConvtoOPDelay
    end

    methods


        function TileTime=AssembleTileResult(this,TileInfo,TileOpt,TileCompute,TileInBurst,TileOutBurst,InternalArchParam)
            if(strcmp(InternalArchParam.doubleBuffer,'true'))
                TileProcessCycle=max(TileCompute,max(TileInBurst,TileOutBurst));
                TileProcessCycleOpt=max(TileOpt.TileComputationCycleOpt,max(TileOpt.TileLoadInputCycleOpt,TileOpt.TileWriteOutputCycleOpt));
            elseif(strcmp(InternalArchParam.doubleBuffer,'false'))
                TileProcessCycle=TileCompute+TileInBurst+TileOutBurst;
                TileProcessCycleOpt=TileOpt.TileComputationCycleOpt+TileOpt.TileLoadInputCycleOpt+TileOpt.TileWriteOutputCycleOpt;
            end

            TileTime.TileProcessCycle=TileProcessCycle;
            TileTime.TileComputationCycle=TileCompute;
            TileTime.InputBusrtCycle=TileInBurst;
            TileTime.OutputBusrtCycle=TileOutBurst;


            TileTime.TileProcessCycleOpt=TileProcessCycleOpt;
            TileTime.TileComputationCycleOpt=TileOpt.TileComputationCycleOpt;
            TileTime.TileLoadInputCycleOpt=TileOpt.TileLoadInputCycleOpt;
            TileTime.TileWriteOutputCycleOpt=TileOpt.TileWriteOutputCycleOpt;
        end

        function layerResult=accuTileToLayer(this,layerResult,OneTileResult)
            layerResult.LayerProcessCycle=layerResult.LayerProcessCycle+OneTileResult.TileProcessCycle;
            layerResult.LayerComputationCycle=layerResult.LayerComputationCycle+OneTileResult.TileComputationCycle;
            layerResult.LayerInputCycle=layerResult.LayerInputCycle+OneTileResult.InputBusrtCycle;
            layerResult.LayerOutputCycle=layerResult.LayerOutputCycle+OneTileResult.OutputBusrtCycle;

            layerResult.LayerProcessCycleOpt=layerResult.LayerProcessCycleOpt+OneTileResult.TileProcessCycleOpt;
            layerResult.LayerComputationCycleOpt=layerResult.LayerComputationCycleOpt+OneTileResult.TileComputationCycleOpt;
            layerResult.LayerInputCycleOpt=layerResult.LayerInputCycleOpt+OneTileResult.TileLoadInputCycleOpt;
            layerResult.LayerOutputCycleOpt=layerResult.LayerOutputCycleOpt+OneTileResult.TileWriteOutputCycleOpt;
        end

        function layerResult=getlayerResultInit(this)
            layerResult.LayerProcessCycle=0;
            layerResult.LayerComputationCycle=0;
            layerResult.LayerInputCycle=0;
            layerResult.LayerOutputCycle=0;

            layerResult.LayerProcessCycleOpt=0;
            layerResult.LayerComputationCycleOpt=0;
            layerResult.LayerInputCycleOpt=0;
            layerResult.LayerOutputCycleOpt=0;
        end

        function param=emitParam(this,TileInfo,param)


            param.origImgSize=[TileInfo.IndeltaY,TileInfo.IndeltaX,TileInfo.inputN]';
            param.paddingMode=TileInfo.paddingMode;
            param.imageTilePos=TileInfo.imageTilePos;
            param.nextTilePos=TileInfo.nextTilePos;
        end
    end

    methods


        function ConvolutionOverhead=getConvolutionOverhead(this,boardName)


            ConvolutionOverhead.execution=0;

            ConvolutionOverhead.start=34;

            ConvolutionOverhead.end=33;
        end

        function MaxPoolOverhead=getMaxPoolOverhead(this,boardName)

            MaxPoolOverhead.execution=0;
            MaxPoolOverhead.start=34;
            MaxPoolOverhead.end=33;
        end

        function LrnOverhead=getLrnOverhead(this,boardName)

            LrnOverhead.execution=0;
            LrnOverhead.start=34;
            LrnOverhead.end=33;
        end

    end
end