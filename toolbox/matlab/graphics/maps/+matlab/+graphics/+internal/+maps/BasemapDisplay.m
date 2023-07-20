classdef(Sealed,ConstructOnLoad)BasemapDisplay<matlab.graphics.primitive.world.Group




    properties(Dependent,AffectsObject,AbortSet=true)
TileReader
TileZoomLevel
    end

    properties(Dependent,SetAccess=private)
UsingBasemap


MaxTileZoomLevel


TileSetMaxZoomLevel
    end

    properties(Transient,Access=private)

        CachedMaxTileZoomLevel=[]
    end

    properties(Transient,SetAccess=private)
        TileReader_I=[]
        TileZoomLevel_I=-1
        TileSetPropertiesChanged=true


        XTileLimits=[0,0]
        YTileLimits=[0,0]
        XLimits=[0,0]
        YLimits=[0,0]
        CachedTileZoomLevel=-1






        ZoomLevelReduction=0;

        QuadObjects matlab.graphics.internal.TileQuad...
        =matlab.graphics.internal.TileQuad.empty
        QuadManager=[]


        XTileSpaceOrigin=0
        YTileSpaceOrigin=0
        XTileSpaceExtent=1
        YTileSpaceExtent=1
    end

    properties(Hidden,Transient,NonCopyable)
BasemapAttributionText
    end

    properties(Transient,Hidden,AffectsObject)



        GrayscaleTiles=false
    end

    properties(Transient,SetAccess=private)

        GrayscaleForPrint=false
    end

    properties(Constant)


        MaxNumTileQuads=900
    end


    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(~)

            props={
            'TileReader','TileZoomLevel','MaxTileZoomLevel','UsingBasemap',...
            'XTileLimits','YTileLimits','XLimits','YLimits'
            };
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end


    methods
        function obj=BasemapDisplay(xt0,yt0,xtExtent,ytExtent)
            addDependencyConsumed(obj,{'dataspace','view','ref_frame'});
            constructTileQuadManager(obj)
            if nargin==4
                obj.XTileSpaceOrigin=xt0;
                obj.YTileSpaceOrigin=yt0;
                obj.XTileSpaceExtent=xtExtent;
                obj.YTileSpaceExtent=ytExtent;
            end

            txt=matlab.graphics.internal.maps.BasemapAttributionText;
            obj.BasemapAttributionText=txt;
            addNode(obj,txt)
        end


        function set.TileReader(obj,reader)
            obj.TileReader_I=reader;
            obj.TileSetPropertiesChanged=true;
            obj.BasemapAttributionText.BasemapChanged=true;
        end


        function reader=get.TileReader(obj)
            reader=obj.TileReader_I;
        end


        function set.TileZoomLevel(obj,tileZoomLevel)
            obj.TileZoomLevel_I=round(tileZoomLevel);
            obj.BasemapAttributionText.TileZoomLevel=round(tileZoomLevel);
        end


        function reader=get.TileZoomLevel(obj)
            reader=obj.TileZoomLevel_I;
        end

        function maxzoom=get.TileSetMaxZoomLevel(obj)
            reader=obj.TileReader;
            if~isempty(reader)&&isprop(reader,'TileSetMetadata')
                metadata=reader.TileSetMetadata;
                maxzoom=metadata.MaxZoomLevel;
            else
                maxzoom=7;
            end
        end

        function maxzoom=get.MaxTileZoomLevel(obj)
            reader=obj.TileReader;
            tileSetMaxZoomLevel=obj.TileSetMaxZoomLevel;
            if~isempty(reader)&&reader.UsingHighZoomLevelBasemap





                tileZoomLevel=min(obj.TileZoomLevel,tileSetMaxZoomLevel);
                [xTileLimits,yTileLimits]=discreteTileLimits(obj);
                maxzoom=readMaxZoomLevel(reader,...
                xTileLimits,yTileLimits,tileZoomLevel);
            else
                maxzoom=tileSetMaxZoomLevel;
            end
            obj.CachedMaxTileZoomLevel=maxzoom;
        end

        function tf=get.UsingBasemap(obj)
            tf=~isempty(obj.TileReader);
        end


        function doUpdate(obj,updateState)

            obj.ZoomLevelReduction=0;


            ds=updateState.DataSpace;
            xlimits=ds.XMapLimits;
            ylimits=ds.YMapLimits;


            xyLimitsUpdated=...
            ~isequal(obj.XLimits,xlimits)||...
            ~isequal(obj.YLimits,ylimits);


            obj.XLimits=xlimits;
            obj.YLimits=ylimits;


            tileZoomLevelUpdated=(obj.TileZoomLevel~=obj.CachedTileZoomLevel);

            if obj.TileSetPropertiesChanged
                updateTiles(obj)
                obj.TileSetPropertiesChanged=false;
            end


            if obj.GrayscaleForPrint&&~obj.GrayscaleTiles
                restoreColor(obj.QuadObjects)
                obj.GrayscaleForPrint=false;
            end


            if tileZoomLevelUpdated



                updateTileZoomLevel(obj)
            elseif xyLimitsUpdated


                cachedMaxTileZoom=obj.CachedMaxTileZoomLevel;
                if~isempty(cachedMaxTileZoom)&&cachedMaxTileZoom~=obj.MaxTileZoomLevel
                    updateTileZoomLevel(obj)
                else
                    updateTileLimits(obj)
                end
            end
            obj.CachedTileZoomLevel=obj.TileZoomLevel;


            if obj.GrayscaleTiles
                obj.GrayscaleForPrint=true;
                renderGrayscale(obj.QuadObjects)
            end



            postUpdateSource=ancestor(obj,'matlab.graphics.primitive.canvas.Canvas','node');
            loadTileCData(obj,postUpdateSource)
        end


        function tilequads=tileQuadsToLoad(obj)
            tilequads=tileQuadsToLoad(obj.QuadObjects);
        end


        function loadTileCData(obj,sourceObject)

            if obj.UsingBasemap
                quads=tileQuadsToLoad(obj);





                if~isempty(quads)
                    tileQuadReferences=matlab.graphics.chart.internal.maps.TileQuadReference(quads);
                    reader=obj.TileReader;
                    if isprop(reader,'SourceObject')
                        reader.SourceObject=sourceObject;
                    end
                    fillTileQuads(reader,tileQuadReferences)
                end
            end
        end


        function updateTiles(obj)
            if~obj.UsingBasemap
                removeTileQuadManager(obj)
                updateTileZoomLevel(obj)
            else
                if isempty(obj.QuadManager)
                    constructTileQuadManager(obj)
                    updateTileZoomLevel(obj)
                    updateTileLimits(obj)
                else
                    updateTileZoomLevel(obj)
                end
            end
        end


        function updateTileZoomLevel(obj,maxTileZoomLevel)
            if nargin<2
                maxTileZoomLevel=obj.MaxTileZoomLevel;
            end
            tileZoomLevel=max(0,min(maxTileZoomLevel,obj.TileZoomLevel));
            obj.TileZoomLevel=tileZoomLevel;
            resetTileQuadManager(obj)
        end
    end


    methods(Access=private)
        function constructTileQuadManager(obj)


            qm=matlab.graphics.chart.internal.maps.TileQuadManager(...
            @(tilequad,xTileIndex,yTileIndex)...
            resetTileQuad(obj,tilequad,xTileIndex,yTileIndex),...
            @()newQuad(obj),...
            @(tilequad)setToUnusedState(obj,tilequad));

            obj.QuadManager=qm;
        end


        function removeTileQuadManager(obj)



            obj.QuadManager=[];
            delete(obj.QuadObjects)
            obj.QuadObjects=matlab.graphics.internal.TileQuad.empty;
            obj.XTileLimits=[0,0];
            obj.YTileLimits=[0,0];
        end


        function resetTileQuadManager(obj)



            obj.XTileLimits=[0,0];
            obj.YTileLimits=[0,0];
            qm=obj.QuadManager;
            if~isempty(qm)
                quadObjects=obj.QuadObjects;
                setToUnusedState(obj,quadObjects)
                numQuads=numel(quadObjects);
                qm=reset(qm,numQuads);
                obj.QuadManager=qm;
                updateTileLimits(obj)
            end
        end


        function updateTileLimits(obj)





            if isvalid(obj)&&~isempty(obj.QuadManager)
                [xTileLimits,yTileLimits]=discreteTileLimits(obj);
                if any(xTileLimits~=obj.XTileLimits)||any(yTileLimits~=obj.YTileLimits)
                    numTileQuads=diff(xTileLimits)*diff(yTileLimits);
                    if numTileQuads>obj.MaxNumTileQuads
                        obj.ZoomLevelReduction=obj.ZoomLevelReduction+1;
                        reducedMaxTileZoomLevel=max(0,obj.MaxTileZoomLevel-obj.ZoomLevelReduction);





                        updateTileZoomLevel(obj,reducedMaxTileZoomLevel)
                    else
                        obj.XTileLimits=xTileLimits;
                        obj.YTileLimits=yTileLimits;
                        [obj.QuadManager,obj.QuadObjects]=update(...
                        obj.QuadManager,xTileLimits,yTileLimits,obj.QuadObjects);
                    end
                end
            end
        end


        function[xTileLimits,yTileLimits]=discreteTileLimits(obj)




            [xLimitsInTileUnits,yLimitsInTileUnits]=limitsInTileUnits(obj);


            xTileLimits(1)=floor(xLimitsInTileUnits(1));
            xTileLimits(2)=ceil(xLimitsInTileUnits(2));


            n=2^(obj.TileZoomLevel);
            yTileLimits(1)=max(0,min(n,floor(yLimitsInTileUnits(1))));
            yTileLimits(2)=max(0,min(n,ceil(yLimitsInTileUnits(2))));
        end


        function[xLimitsInTileUnits,yLimitsInTileUnits]=limitsInTileUnits(obj)


            s=2^(obj.TileZoomLevel);
            xLimitsInTileUnits=s*(obj.XLimits-obj.XTileSpaceOrigin)/obj.XTileSpaceExtent;
            yLimitsInTileUnits=s*(flip(obj.YLimits)-obj.YTileSpaceOrigin)/obj.YTileSpaceExtent;
        end
    end


    methods



        function resetTileQuad(obj,tilequad,uTileIndex,yTileIndex)


            if obj.UsingBasemap
                tilequad.UTileIndex=uTileIndex;
                tilequad.YTileIndex=yTileIndex;
                tilequad.ZoomLevel=obj.TileZoomLevel;
                tilequad.Loading=true;
                tilequad.Visible='on';
            end
        end


        function tilequad=newQuad(obj)
            tilequad=matlab.graphics.internal.TileQuad(...
            obj.XTileSpaceOrigin,...
            obj.YTileSpaceOrigin,...
            obj.XTileSpaceExtent,...
            obj.YTileSpaceExtent);
            tilequad.Visible='off';
            addNode(obj,tilequad)
        end


        function setToUnusedState(~,tilequad)
            reset(tilequad)
        end
    end
end
