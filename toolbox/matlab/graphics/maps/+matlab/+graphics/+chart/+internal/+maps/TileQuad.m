classdef TileQuad<matlab.mixin.SetGet













































































    properties(Dependent,SetAccess=private)
XTileIndex
    end

    properties(SetAccess=private)
        YTileIndex=0
        ZoomLevel=0
    end

    properties(Dependent)
CData
Visible
    end

    properties
        Loading=false
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

        UTileIndex=0


        CData_I=[]
    end

    properties(Transient,Access=private)

        TexturedQuad matlab.graphics.chart.internal.maps.TexturedQuad
    end

    properties(Constant,Access=private)
        LightGrayLoadingRGB=loadingTileRGB('lightgray_loading_tile.png')
        DarkGrayLoadingRGB=loadingTileRGB('darkgray_loading_tile.png')
    end


    methods
        function obj=TileQuad(parent)
            tq=matlab.graphics.chart.internal.maps.TexturedQuad;
            tq.Visible='off';
            tq.Parent=parent;
            obj.TexturedQuad=tq;
        end


        function delete(obj)

            removeCrossReference(obj)


            if isvalid(obj.TexturedQuad)
                delete(obj.TexturedQuad)
            end
        end


        function setIndicesAndZoom(obj,uTileIndex,yTileIndex,zoomLevel)
            removeCrossReference(obj)

            obj.UTileIndex=uTileIndex;
            obj.YTileIndex=yTileIndex;
            obj.ZoomLevel=zoomLevel;

            tq=obj.TexturedQuad;
            tq.XLimits=uTileIndex+[0,1];
            tq.YLimits=yTileIndex+[0,1];

            if mod(uTileIndex+yTileIndex,2)==0
                tq.CData=obj.LightGrayLoadingRGB;
            else
                tq.CData=obj.DarkGrayLoadingRGB;
            end

            obj.Visible='on';
            obj.Loading=true;
        end


        function reset(obj)

            if~isempty(obj)
                removeCrossReference(obj)
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


        function set.Visible(obj,vis)
            tq=obj.TexturedQuad;
            tq.Visible=vis;
        end


        function vis=get.Visible(obj)
            tq=obj.TexturedQuad;
            vis=tq.Visible;
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
                if~isempty(tilequadref)
                    set(tilequadref,'TileQuad',matlab.graphics.chart.internal.maps.TileQuad.empty)
                end
                set(obj,'Reference',matlab.graphics.chart.internal.maps.TileQuadReference.empty)
            end
        end
    end
end


function RGB=loadingTileRGB(name)


    path=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,'maptiles',name);
    RGB=imread(path);
end
