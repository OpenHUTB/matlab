classdef Snapshot<handle






    properties
RasterData
    end

    methods
        function this=Snapshot(rasterData)
            this.RasterData=uint8(rasterData);
        end

        function base64String=getFigureURI(this)

            encodedBytes=matlab.internal.imencode(this.RasterData,'png');
            base64String=char("data:image/png;base64,"+matlab.net.base64encode(encodedBytes));
        end

        function asyncUpdateURI(this,editorId,figureId)


            bp=backgroundPool;
            parfeval(bp,@()this.publishAsynUpdate(editorId,figureId),0);
        end


        function addTransparentPlane(this,mask)





            if nargin==1
                mask=[1,0.9412,1];
            end
            if ndims(this.RasterData)==3&&size(this.RasterData,3)==3
                intmask=round(mask*255);
                rgbPixels=this.RasterData;
                red=rgbPixels(:,:,1);
                green=rgbPixels(:,:,2);
                blue=rgbPixels(:,:,3);
                isNotSpecial=red~=intmask(1)|green~=intmask(2)|blue~=intmask(3);



                alpha=zeros(size(red));
                alpha(isNotSpecial)=255;


                this.RasterData=cat(3,rgbPixels,alpha);
            end
        end
    end

    methods(Static)

        function state=useBackgroundThread


            import matlab.internal.editor.EODataStore
            state=false;
            if EODataStore.getRootField('SynchronousOutput')
                return
            end



            return

            manager=parallel.internal.pool.PoolManager.getInstance;
            pools=getAllPools(manager,parallel.internal.pool.PoolApiTag.Background);
            state=~isempty(pools);
        end

    end

    methods(Access=private)
        function publishAsynUpdate(this,editorId,figureId)
            base64String=this.getFigureURI(editorId,figureId);
            channel="/liveeditor/figure/deferredjavaimage/"+editorId;
            message.publish(channel,struct("figureId",figureId,"image",base64String));
        end
    end
end