classdef TileQuadReference<matlab.mixin.SetGet
















    properties(SetAccess=private)
        XTileIndex=-1
        YTileIndex=-1
        ZoomLevel=-1
    end

    properties(Dependent)
CData
    end

    properties(SetAccess={...
        ?matlab.graphics.internal.TileQuad,...
        ?matlab.graphics.chart.internal.maps.TileQuad})
TileQuad
    end


    methods
        function obj=TileQuadReference(tilequad)
            if nargin>0
                if isscalar(tilequad)
                    q=tilequad;
                    if isvalid(q)
                        obj.TileQuad=q;
                        obj.XTileIndex=q.XTileIndex;
                        obj.YTileIndex=q.YTileIndex;
                        obj.ZoomLevel=q.ZoomLevel;



                        q.Reference=obj;
                    end
                else
                    obj=matlab.graphics.chart.internal.maps.TileQuadReference.empty;
                    for k=1:numel(tilequad)
                        q=tilequad(k);
                        obj(k)=matlab.graphics.chart.internal.maps.TileQuadReference(q);
                    end
                end
            end
        end


        function delete(obj)

            tilequad=obj.TileQuad;
            if~isempty(tilequad)&&isvalid(tilequad)
                tilequad.Reference=matlab.graphics.chart.internal.maps.TileQuadReference.empty;
            end
        end


        function set.CData(obj,cdata)
            tilequad=obj.TileQuad;
            if~isempty(tilequad)&&isvalid(tilequad)&&tileIndicesMatch(obj,tilequad)
                tilequad.CData=cdata;
            end
        end


        function cdata=get.CData(obj)
            tilequad=obj.TileQuad;
            if~isempty(tilequad)&&isvalid(tilequad)
                cdata=tilequad.CData;
            else
                cdata=[];
            end
        end
    end


    methods(Access=private)
        function tf=tileIndicesMatch(obj,tilequad)

            tf=isequal(obj.XTileIndex,tilequad.XTileIndex)...
            &&isequal(obj.YTileIndex,tilequad.YTileIndex)...
            &&isequal(obj.ZoomLevel,tilequad.ZoomLevel);
        end
    end
end
