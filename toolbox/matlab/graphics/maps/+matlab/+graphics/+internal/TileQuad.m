classdef(Sealed,ConstructOnLoad)TileQuad<matlab.graphics.primitive.world.Group







































    properties(Dependent,SetAccess=private)
XTileIndex
    end

    properties(AffectsObject)
        UTileIndex=0
        YTileIndex=0
        ZoomLevel=0
    end

    properties(Dependent)
CData

    end

    properties(AffectsObject)
        Loading=true
    end

    properties(Dependent,SetAccess=private)
GrayscaleRendering
    end

    properties(SetAccess=?matlab.graphics.chart.internal.maps.TileQuadReference)
        Reference matlab.graphics.chart.internal.maps.TileQuadReference...
        =matlab.graphics.chart.internal.maps.TileQuadReference.empty
    end

    properties(Dependent,SetAccess=private)
RenderedCData
    end

    properties(Access=private)

        CData_I=[]
    end

    properties(Transient,Access=private)

        TexturedQuad matlab.graphics.internal.TexturedQuad


        XTileSpaceOrigin=0
        YTileSpaceOrigin=0
        XTileSpaceExtent=1
        YTileSpaceExtent=1
    end

    properties(Constant,Access=private)
        LightGrayLoadingRGB=loadingTileRGB('lightgray_loading_tile.png')
        DarkGrayLoadingRGB=loadingTileRGB('darkgray_loading_tile.png')
    end


    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(~)

            props={
            'XTileIndex','UTileIndex','YTileIndex','ZoomLevel',...
            'CData','Loading','GrayscaleRendering','RenderedCData'
            };
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end


    methods
        function obj=TileQuad(xt0,yt0,xtExtent,ytExtent)
            addDependencyConsumed(obj,{'dataspace','view','ref_frame'});
            tq=matlab.graphics.internal.TexturedQuad;
            addNode(obj,tq)
            obj.TexturedQuad=tq;
            if nargin==4
                obj.XTileSpaceOrigin=xt0;
                obj.YTileSpaceOrigin=yt0;
                obj.XTileSpaceExtent=xtExtent;
                obj.YTileSpaceExtent=ytExtent;
            end
        end


        function delete(obj)

            removeCrossReference(obj)


            if isvalid(obj.TexturedQuad)
                delete(obj.TexturedQuad)
            end
        end


        function doUpdate(obj,updateState)


            tq=obj.TexturedQuad;
            ds=updateState.DataSpace;
            if isvalid(ds)&&isprop(ds,'XMapLimits')&&isvalid(tq)






                s=2^(obj.ZoomLevel);
                xLimitsInTileUnits=s*(ds.XMapLimits-obj.XTileSpaceOrigin)/obj.XTileSpaceExtent;
                yLimitsInTileUnits=s*(ds.YMapLimits-obj.YTileSpaceOrigin)/obj.YTileSpaceExtent;




                tq.XLimits=((obj.UTileIndex+[0,1])-xLimitsInTileUnits(1))/diff(xLimitsInTileUnits);
                tq.YLimits=((obj.YTileIndex+[0,1])-yLimitsInTileUnits(1))/diff(yLimitsInTileUnits);
            end


            if obj.Loading
                if mod(obj.UTileIndex+obj.YTileIndex,2)==0
                    tq.CData=obj.LightGrayLoadingRGB;
                else
                    tq.CData=obj.DarkGrayLoadingRGB;
                end
            end
        end


        function reset(obj)


            if~isempty(obj)
                removeCrossReference(obj)
                set(obj,'Reference',matlab.graphics.chart.internal.maps.TileQuadReference.empty)
                set(obj,'Visible','off')
                set(obj,'Loading',false)
            end
        end


        function xi=get.XTileIndex(obj)




            xi=mod(obj.UTileIndex,2^(obj.ZoomLevel));
        end


        function set.CData(obj,RGB)
            obj.CData_I=RGB;
            obj.Loading=false;
            tq=obj.TexturedQuad;
            tq.CData=RGB;
        end


        function RGB=get.CData(obj)
            RGB=obj.CData_I;
        end


        function cdata=get.RenderedCData(obj)
            tq=obj.TexturedQuad;
            ts=tq.TriangleStrip;
            tx=ts.Texture;
            cdata=tx.CData;
        end


        function tf=get.GrayscaleRendering(obj)
            tq=obj.TexturedQuad;
            tf=logical(tq.GrayscaleRendering);
        end


        function renderGrayscale(obj)

            if isscalar(obj)
                tq=obj.TexturedQuad;
                tq.GrayscaleRendering=true;
            else
                for instance=obj
                    renderGrayscale(instance)
                end
            end
        end


        function set.Reference(obj,tilequadref)


            removeCrossReference(obj)
            obj.Reference=tilequadref;
        end


        function restoreColor(obj)


            if isscalar(obj)
                tq=obj.TexturedQuad;
                tq.GrayscaleRendering=false;
            else
                for instance=obj
                    restoreColor(instance)
                end
            end
        end


        function quads=tileQuadsToLoad(obj)


            loading=arrayfun(@(tilequad)tilequad.Loading,obj);
            quads=obj(loading);
        end
    end


    methods(Access=private)
        function removeCrossReference(obj)


            if~isempty(obj)
                tilequadref=[obj.Reference];
                tilequadref=tilequadref(isvalid(tilequadref));
                if~isempty(tilequadref)
                    set(tilequadref,'TileQuad',matlab.graphics.internal.TileQuad.empty)
                end
            end
        end
    end
end


function RGB=loadingTileRGB(name)


    path=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,'maptiles',name);
    RGB=imread(path);
end
