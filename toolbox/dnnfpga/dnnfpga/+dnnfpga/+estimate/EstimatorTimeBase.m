classdef EstimatorTimeBase<handle



    methods
        function TileInfo=EstimatorGetTileInfo(this,tileIRParam,dataTransNum)
            if(nargin<3)
                dataTransNum=1;
            end

            TileInfo.OutdeltaY=tileIRParam.resultTilePos(2)-tileIRParam.resultTilePos(1);
            TileInfo.OutdeltaX=tileIRParam.resultTilePos(4)-tileIRParam.resultTilePos(3);

            TileInfo.IndeltaY=tileIRParam.imageTilePos(2)-tileIRParam.imageTilePos(1);
            TileInfo.IndeltaX=tileIRParam.imageTilePos(4)-tileIRParam.imageTilePos(3);

            TileInfo.inputN=tileIRParam.inputFeatureNum;
            TileInfo.outputM=tileIRParam.outputFeatureNum;


            if(mod(TileInfo.inputN,dataTransNum)~=0)
                TileInfo.inputN=ceil(TileInfo.inputN/dataTransNum)*dataTransNum;
            end


            if(mod(TileInfo.outputM,dataTransNum)~=0)
                TileInfo.outputM=ceil(TileInfo.outputM/dataTransNum)*dataTransNum;
            end

            TileInfo.weightR=tileIRParam.origOpSizeValue(1);
            TileInfo.weightC=tileIRParam.origOpSizeValue(2);
            TileInfo.lrnLocalSize=tileIRParam.lrnLocalSize;
            TileInfo.type=tileIRParam.type;

            TileInfo.paddingMode=tileIRParam.paddingMode;
            TileInfo.imageTilePos=tileIRParam.imageTilePos;
            TileInfo.nextTilePos=tileIRParam.nextTilePos;
        end
    end

end

