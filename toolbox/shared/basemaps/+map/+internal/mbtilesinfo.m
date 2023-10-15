function info = mbtilesinfo( filename )

arguments
    filename( 1, 1 )string
end


extension = ".mbtiles";
lookupOnMATLABPath = true;
[ filenames, extensions ] = matlab.io.internal.validators.validateFileName(  ...
    filename, extension, lookupOnMATLABPath );
filename = filenames{ 1 };
if ~matches( extensions{ 1 }, extension, "IgnoreCase", true )
    error( message( "shared_basemaps:fileio:UnexpectedFileExtension", filename, extension ) )
end


info.Filename = string( filename );
info.Attribution = "";
info.MaxZoomLevel = 18;
info.Scheme = "tms";
info.Format = "";



try
    conn = matlab.depfun.internal.database.SqlDbConnector;
    conn.connectReadOnly( filename );
    conn.doSql( 'select name, value from metadata;' )
    data = conn.fetchRows( 0 );


    for k = 1:length( data )
        namevalue = data{ k };
        switch ( namevalue{ 1 } )
            case 'attribution'
                attribution = string( namevalue{ 2 } );



                copyright = string( char( uint8( 169 ) ) );
                attribution = replace( attribution, "&copy;", copyright );
                attribution = replace( attribution, "&amp;copy", copyright );
                attribution = replaceBetween( attribution, "<a", ">", "" );
                attribution = replace( attribution, "<a>", "" );
                attribution = replace( attribution, "</a>", "" );
                info.Attribution = attribution;

            case 'maxzoom'
                maxZoomLevel = double( string( namevalue{ 2 } ) );
                if ~isempty( maxZoomLevel )
                    info.MaxZoomLevel = maxZoomLevel;
                end

            case 'scheme'
                info.Scheme = string( namevalue{ 2 } );

            case 'format'
                info.Format = string( namevalue{ 2 } );
        end
    end
catch e
    error( message( 'shared_basemaps:fileio:RasterMapTilesNotFound', filename ) )
end



if matches( info.Format, [ "pbf", "mvt" ] )
    error( message( 'shared_basemaps:fileio:FileContainsVectorMapTiles', filename ) )
end


delete( conn )

