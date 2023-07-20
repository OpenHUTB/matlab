

classdef DisplayTileManager<handle

    properties(Hidden)
TileSize



        MaxExtraTiles=40


        BackgroundTileImage=imread(fullfile(toolboxdir('images'),...
        'icons','BackgroundTile.png'));


        Interpolation='linear'
    end

    properties(Hidden)
        BackgroundTile images.internal.TexturedQuad
    end

    properties(Access=private)
        Tiles images.internal.TexturedQuad=images.internal.TexturedQuad.empty()


        xLims=[-1;-1]
        yLims=[-1;-1]


        ResolutionLevels=-1


        NeedsImageData logical
        HasImageData logical



        InCurrentViewPort logical



        InUseInCurrentUpdate logical



        IndexPointItr=matlab.graphics.axis.dataspace.IndexPointsIterator;
    end


    methods(Hidden)

        function obj=DisplayTileManager()



            obj.BackgroundTile=images.internal.TexturedQuad(obj.Interpolation);
            cdata=permute(obj.BackgroundTileImage,[3,2,1]);



            cdata(4,:,:)=uint8(50);
            obj.BackgroundTile.CData=cdata;
        end

        function reset(obj)

            delete(obj.Tiles);
            obj.Tiles=images.internal.TexturedQuad.empty();
            obj.xLims=[-1;-1];
            obj.yLims=[-1;-1];
            obj.ResolutionLevels=-1;
            obj.NeedsImageData=logical.empty();
            obj.HasImageData=logical.empty();
            obj.InCurrentViewPort=logical.empty();
            obj.InUseInCurrentUpdate=logical.empty();
        end

        function updateExistingTiles(obj,xLimsViewPort,yLimsViewPort,uState,reqResLevel)






            notInView=...
            obj.xLims(1,:)>xLimsViewPort(2)...
            |xLimsViewPort(1)>obj.xLims(2,:)...
            |obj.yLims(1,:)>yLimsViewPort(2)...
            |yLimsViewPort(1)>obj.yLims(2,:);
            obj.InCurrentViewPort=~notInView;

            for ind=1:numel(obj.Tiles)
                if obj.InCurrentViewPort(ind)&&obj.HasImageData(ind)...
                    &&obj.ResolutionLevels(ind)>=reqResLevel


                    obj.positionTile(ind,uState);
                    obj.Tiles(ind).Visible='on';
                else



                    obj.Tiles(ind).Visible='off';
                end
            end



            obj.InUseInCurrentUpdate(:)=false;
        end

        function positionBackgroundTile(obj,xLimsViewPort,yLimsViewPort,uState)

            obj.IndexPointItr.Vertices=[...
            xLimsViewPort(1),yLimsViewPort(1);
            xLimsViewPort(2),yLimsViewPort(2)];
            gWorldCoords=TransformPoints(uState.DataSpace,...
            uState.TransformUnderDataSpace,...
            obj.IndexPointItr);
            obj.BackgroundTile.XLimits=[gWorldCoords(1,1),gWorldCoords(1,2)];
            obj.BackgroundTile.YLimits=[gWorldCoords(2,1),gWorldCoords(2,2)];



            obj.BackgroundTile.Visible='on';
        end

        function newTile=manageTileAt(obj,xLims,yLims,resLevel,uState)

            newTile=[];



            tileInd=find(all(obj.xLims==xLims')...
            &all(obj.yLims==yLims')&obj.ResolutionLevels==resLevel);

            if~isempty(tileInd)


                obj.NeedsImageData(tileInd)=~obj.HasImageData(tileInd);
                obj.InUseInCurrentUpdate(tileInd)=true;
                return
            end


            newTile=images.internal.TexturedQuad(obj.Interpolation);


            obj.Tiles(end+1)=newTile;

            tileInd=numel(obj.Tiles);


            obj.xLims(:,tileInd)=xLims';
            obj.yLims(:,tileInd)=yLims';
            obj.ResolutionLevels(tileInd)=resLevel;

            obj.NeedsImageData(tileInd)=true;
            obj.InCurrentViewPort(tileInd)=true;
            obj.InUseInCurrentUpdate(tileInd)=true;

            obj.HasImageData(tileInd)=false;


            obj.positionTile(tileInd,uState);
        end

        function positionTile(obj,tileInd,uState)
            xLim=obj.xLims(:,tileInd);
            yLim=obj.yLims(:,tileInd);


            obj.IndexPointItr.Vertices=[xLim(1),yLim(1);xLim(2),yLim(2)];
            gWorldCoords=TransformPoints(uState.DataSpace,...
            uState.TransformUnderDataSpace,...
            obj.IndexPointItr);


            tQuad=obj.Tiles(tileInd);
            tQuad.XLimits=[gWorldCoords(1,1),gWorldCoords(1,2)];
            tQuad.YLimits=[gWorldCoords(2,1),gWorldCoords(2,2)];
        end

        function tileInds=getTilesThatNeedDataFromSource(obj)

            tileInds=find(obj.NeedsImageData);
        end

        function updateTileWithData(obj,tileInd,rawData,cdataMapping,alpha,alphaMapping,colorspace)
            tQuad=obj.Tiles(tileInd);
            tQuad.setCDataFrom(rawData,cdataMapping,alpha,alphaMapping,colorspace);


            obj.NeedsImageData(tileInd)=false;
            obj.HasImageData(tileInd)=true;
            obj.Tiles(tileInd).Visible='on';
        end

        function[xLims,yLims,resLevel]=getExtents(obj,tileInd)
            xLims=obj.xLims(:,tileInd);
            yLims=obj.yLims(:,tileInd);
            resLevel=obj.ResolutionLevels(tileInd);
        end

        function cleanUpPreviousResolutionTiles(obj)


            obj.BackgroundTile.Visible='off';

            numTilesToDelete=sum(~obj.InUseInCurrentUpdate)-obj.MaxExtraTiles;
            if numTilesToDelete>0



                tileRes=obj.ResolutionLevels;
                tileRes(obj.InUseInCurrentUpdate)=inf;
                [~,inds]=sort(tileRes);
                indsToDelete=inds(1:numTilesToDelete);

                delete(obj.Tiles(indsToDelete));
                obj.Tiles(indsToDelete)=[];
                obj.xLims(:,indsToDelete)=[];
                obj.yLims(:,indsToDelete)=[];
                obj.ResolutionLevels(:,indsToDelete)=[];
                obj.NeedsImageData(:,indsToDelete)=[];
                obj.HasImageData(:,indsToDelete)=[];
                obj.InCurrentViewPort(:,indsToDelete)=[];
                obj.InUseInCurrentUpdate(:,indsToDelete)=[];
            end
            [obj.Tiles(~obj.InUseInCurrentUpdate).Visible]=deal('off');
        end

        function resetPending(obj)
            obj.NeedsImageData(:)=false;
        end

        function forceGrayScaleRendering(obj,tf)
            [obj.Tiles.ForceGrayScaleRendering]=deal(tf);
        end
    end
end
