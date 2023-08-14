classdef BasemapManager<handle





    properties(Dependent)

Basemap
    end

    properties(SetAccess=private)
        TileReader=[]
        AttributionString string=""
        PixelsPerTileDimension=256
    end

    properties(Access=private)
        BaseLayerSelector=[]
    end

    properties(Hidden,Access=private)
        pBasemap=''


        TileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata...
        =matlab.graphics.chart.internal.maps.TileSetMetadata.empty
    end

    properties(Access=private,Dependent,Hidden)




BaseLayerConfigFolder
    end

    properties(Constant,Access=private)
        pBaseLayerConfigFolder=matlab.graphics.chart.internal.maps.mapdatadir
    end


    methods
        function obj=BasemapManager

            folder=obj.BaseLayerConfigFolder;
            obj.BaseLayerSelector=matlab.graphics.chart.internal.maps.BaseLayerSelector(...
            'ConfigFolder',folder);
        end

        function attributionString=generateAttributionString(...
            obj,latlim,lonlim,zoomLevel)


            reader=obj.TileReader;
            if~isempty(reader)
                attributionString=readDynamicAttribution(...
                reader,latlim,lonlim,zoomLevel);
            else
                attributionString="";
            end
        end
    end


    methods
        function set.Basemap(obj,basemap)


            if isa(basemap,'matlab.graphics.chart.internal.maps.TileSetMetadata')...
                &&~isempty(basemap)
                meta=basemap;
                basemap=meta.TileSetName;
            else
                basemap=char(validateBasemap(basemap));
                meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
            end

            obj.TileSetMetadata=meta;
            setBasemapAndRelatedProperties(obj,basemap)
        end
    end


    methods
        function basemap=get.Basemap(obj)
            basemap=obj.pBasemap;
        end
    end


    methods(Access=private)
        function setBasemapAndRelatedProperties(obj,basemap)
            checkerboardBasemaps={'cbgrayland','cbdarkwater','cbbluegreen','cbloading'};
            if any(strcmpi(basemap,checkerboardBasemaps))

                basemap=char(lower(basemap));
                attribution="";
                reader=matlab.graphics.chart.internal.maps.CheckerboardTileReader(basemap);
                pixelsPerTileDimension=256;
            else




                selector=obj.BaseLayerSelector;
                if~isempty(obj.TileSetMetadata)
                    reader=selectReader(selector,obj.TileSetMetadata);
                else
                    reader=selectReader(selector,basemap);
                end

                if~isempty(reader)
                    basemap=char(reader.TileSetMetadata.TileSetName);
                    attribution=reader.TileSetMetadata.Attribution;
                    if isempty(attribution)||ismissing(attribution)
                        attribution="";
                    end
                    pixelsPerTileDimension=size(reader.MissingMapTileValue,1);
                else
                    basemap='none';
                    attribution="";
                    pixelsPerTileDimension=256;
                end
            end
            obj.pBasemap=basemap;
            obj.TileReader=reader;
            obj.AttributionString=attribution;
            obj.PixelsPerTileDimension=pixelsPerTileDimension;
        end
    end


    methods
        function folder=get.BaseLayerConfigFolder(obj)
            name='BaseLayerConfigFolder';
            if isappdata(groot,name)
                folder=getappdata(groot,name);
            else
                folder=obj.pBaseLayerConfigFolder;
            end
        end
    end
end


function basemap=validateBasemap(basemap)




    isEmptyCharOrString=isempty(basemap)&&(ischar(basemap)||isstring(basemap));
    isNullString=isequal(basemap,"");
    if isEmptyCharOrString||isNullString


        basemap='none';
    else
        if ischar(basemap)
            attributes={'vector'};
            if iscolumn(basemap)
                basemap=basemap(:)';
            end
        else
            attributes={'scalar'};
        end
        validateattributes(basemap,{'string','char'},attributes,'','Basemap')
    end
end
