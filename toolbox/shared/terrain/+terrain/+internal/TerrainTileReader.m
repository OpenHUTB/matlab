classdef(Abstract,Hidden)TerrainTileReader<handle





    methods(Abstract)
        [tileCoordinates,ind]=findTiles(reader,lat,lon)
        terrainData=readTiles(reader,tileCoordinates)
        keys=tileKeys(reader,tileCoordinates)
    end
end

