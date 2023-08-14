








classdef(ConstructOnLoad)TileSetFileReader<matlab.graphics.chart.internal.maps.WebMercatorTileSetReader

    properties(Access=public)
        TileScheme(1,1)string="tms"
    end

    properties(Access=protected)
Filename
MissingMapTileBlobData
    end

    properties(Access=private,Constant)
        TileSQL='select tile_data from tiles where zoom_level = %d and tile_column = %d and tile_row = %d'
    end

    methods
        function reader=TileSetFileReader(varargin)





















            reader=reader@matlab.graphics.chart.internal.maps.WebMercatorTileSetReader(varargin{:});
            reader.Filename=reader.TileSetMetadata.MapTileLocation.ParameterizedLocation;
            reader.EnableMapTileFileCache=false;
            reader.MissingMapTileBlobData=...
            readMissingMapTileBlobData(reader.MissingMapTileFilename);
        end

        function mapTile=readMapTile(reader,tileRow,tileCol,zoomLevel)











            reader.TileRowIndex=tileRow;
            reader.TileColumnIndex=tileCol;
            reader.ZoomLevel=zoomLevel;

            try


                imgdata=readSqlBlob(reader,tileRow,tileCol,zoomLevel);
                mapTile=matlab.internal.imdecode(imgdata);
            catch e
                reader.Exception=e;
                mapTile=reader.MissingMapTileValue;
                reader.MapTileAcquired=false;
            end
        end

        function imgdata=readSqlBlob(reader,tileRow,tileCol,zoomLevel)









            filename=reader.Filename;
            if reader.TileScheme=="tms"
                tileRow=2^zoomLevel-1-tileRow;
            end
            query=sprintf(reader.TileSQL,zoomLevel,tileCol,tileRow);
            data=matlab.internal.maps.sqlBlobReader(filename,query);
            if isempty(data)
                imgdata=reader.MissingMapTileBlobData;
                reader.MapTileAcquired=false;
            else
                imgdata=data;
                reader.MapTileAcquired=true;
            end
        end
    end
end

function blobdata=readMissingMapTileBlobData(filename)

    fid=fopen(filename,"r");
    blobdata=fread(fid,"uint8=>uint8");
    fclose(fid);
end
