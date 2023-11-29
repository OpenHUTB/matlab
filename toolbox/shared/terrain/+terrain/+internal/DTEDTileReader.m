classdef(Sealed,Hidden)DTEDTileReader<terrain.internal.ScatteredTileReader

    methods(Access=protected)
        function[Z,R,resampled]=readTerrain(~,terrainData)

            [Z,latlim,lonlim]=terrain.internal.dtedread(terrainData.Source);
            R.LatitudeLimits=latlim;
            R.LongitudeLimits=lonlim;
            R.RasterSize=size(Z);
            R.RasterExtentInLatitude=diff(latlim);
            R.RasterExtentInLongitude=diff(lonlim);


            resampled=false;
        end

        function[latv,lonv]=tileDataGridVectors(~,R)


            latLim=R.LatitudeLimits;
            lonLim=R.LongitudeLimits;
            rasterSize=R.RasterSize;
            latv=linspace(double(latLim(1)),double(latLim(2)),rasterSize(1));
            lonv=linspace(double(lonLim(1)),double(lonLim(2)),rasterSize(2));
        end
    end
end
