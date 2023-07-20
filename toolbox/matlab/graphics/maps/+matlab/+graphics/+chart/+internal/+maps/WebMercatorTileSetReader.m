



























classdef(ConstructOnLoad)WebMercatorTileSetReader<matlab.graphics.chart.internal.maps.TileSetMemoryCacheReader
    properties(Access='protected')
TileSetReference
    end

    methods
        function reader=WebMercatorTileSetReader(varargin)




















            reader=reader@matlab.graphics.chart.internal.maps.TileSetMemoryCacheReader(varargin{:});
            reader.TileSetReference=matlab.graphics.chart.internal.maps.WebMercatorTileSetReference;
        end
    end
end

