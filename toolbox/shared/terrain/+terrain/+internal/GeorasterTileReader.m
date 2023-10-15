classdef ( Sealed, Hidden )GeorasterTileReader < terrain.internal.ScatteredTileReader




    methods ( Access = protected )
        function [ Z, R, resampled ] = readTerrain( reader, terrainData )


            if terrainData.IsFileSource

                warnState = warning( 'off', 'map:io:UnableToDetermineCoordinateSystemType' );
                restoreWarn = onCleanup( @(  )warning( warnState ) );


                file = terrainData.Source;
                [ Zin, Rin ] = readgeoraster( file, "OutputType", "double" );
                info = georasterinfo( file );
                missingDataIndicator = info.MissingDataIndicator;


                if ~isempty( missingDataIndicator ) && ( missingDataIndicator ~= reader.MissingDataReplaceValue )
                    mask = ( Zin == missingDataIndicator );
                    Zin( mask ) = reader.MissingDataReplaceValue;
                end
            else
                Zin = double( terrainData.Source{ 1 } );
                Rin = terrainData.Source{ 2 };
            end


            [ Z, R, resampled ] = terrain.internal.GeorasterTileReader.convertRasterToWGS84( Zin, Rin );



            if R.ColumnsStartFrom == "north"
                R.ColumnsStartFrom = "south";
                Z = flipud( Z );
            end
        end

        function [ latv, lonv ] = tileDataGridVectors( ~, R )


            [ latv, lonv ] = geographicGrid( R, 'gridvectors' );
        end
    end


    methods ( Static )
        function [ B, BR, resampled ] = convertRasterToWGS84( A, AR )

            arguments
                A( :, : )double
                AR( 1, 1 )
            end

            wgs84CRS = geocrs( 4326 );

            if AR.CoordinateSystemType == "geographic"
                srcGeoCRS = AR.GeographicCRS;
                hasNoCRS = isempty( srcGeoCRS );

                if hasNoCRS || isequal( srcGeoCRS, wgs84CRS )


                    B = A;
                    BR = AR;
                    if hasNoCRS
                        BR.GeographicCRS = wgs84CRS;
                    end
                    resampled = false;
                    return
                else

                    [ srcLat, srcLon ] = geographicGrid( AR );
                    [ wgs84Lon, wgs84Lat ] = map.internal.crs.crs2crs(  ...
                        wktstring( srcGeoCRS ), wktstring( wgs84CRS ), srcLon, srcLat );






                    if isequaln( wgs84Lat, srcLat ) && isequaln( wgs84Lon, srcLon )
                        B = A;
                        BR = AR;
                        BR.GeographicCRS = wgs84CRS;
                        resampled = false;
                        return
                    end
                end
            else
                if isempty( AR.ProjectedCRS ) || isempty( AR.ProjectedCRS.GeographicCRS )
                    error( message( "shared_terrain:terrain:EmptyRasterReferenceProjectedCRS" ) )
                end
                srcGeoCRS = AR.ProjectedCRS.GeographicCRS;
                [ x, y ] = worldGrid( AR );
                [ srcLat, srcLon ] = projinv( AR.ProjectedCRS, x, y );
                if isequal( srcGeoCRS, wgs84CRS )
                    wgs84Lat = srcLat;
                    wgs84Lon = srcLon;
                else
                    [ wgs84Lon, wgs84Lat ] = map.internal.crs.crs2crs(  ...
                        wktstring( srcGeoCRS ), wktstring( wgs84CRS ), srcLon, srcLat );
                end
            end




            [ B, BR ] = resampleGeoraster( A, AR, wgs84Lat, wgs84Lon );
            BR.GeographicCRS = wgs84CRS;
            resampled = true;
        end
    end
end

function [ B, BR ] = resampleGeoraster( A, AR, wgs84Lat, wgs84Lon )


wgs84Lat = wgs84Lat( : );
wgs84Lon = wgs84Lon( : );
A = A( : );





[ latlim, lonlim ] = filledGeoquadrangle( wgs84Lat, wgs84Lon, AR );


if strcmp( AR.RasterInterpretation, 'cells' )
    BR = georefcells( latlim, lonlim, AR.RasterSize );
else
    BR = georefpostings( latlim, lonlim, AR.RasterSize );
end


F = scatteredInterpolant( wgs84Lon, wgs84Lat, A );
[ latq, lonq ] = geographicGrid( BR );
B = F( lonq, latq );
end

function [ latlim, lonlim ] = filledGeoquadrangle( lat, lon, AR )




latMat = reshape( lat, AR.RasterSize );
lonMat = reshape( lon, AR.RasterSize );


if AR.ColumnsStartFrom == "north"
    maxlat = min( latMat( 1, : ) );
    minlat = max( latMat( end , : ) );
else
    maxlat = min( latMat( end , : ) );
    minlat = max( latMat( 1, : ) );
end
latlim = [ minlat, maxlat ];


if AR.RowsStartFrom == "west"
    minlon = max( lonMat( :, 1 ) );
    maxlon = min( lonMat( :, end  ) );
else
    minlon = max( lonMat( :, end  ) );
    maxlon = min( lonMat( :, 1 ) );
end
lonlim = [ minlon, maxlon ];
end


