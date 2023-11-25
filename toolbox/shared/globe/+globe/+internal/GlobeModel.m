classdef ( Sealed, Hidden )GlobeModel < matlab.mixin.SetGet

    properties
        Name char{ validateName } = ''
    end


    properties ( Dependent )
        Basemap
        TerrainName
    end


    properties ( SetAccess = private, Dependent )
        UseTerrain
    end


    properties ( Hidden )
        TerrainSource
        CustomBasemapIconDir
        BasemapStructs
        ReaderMap
    end


    properties ( Constant, Hidden )
        MapTileCacheSize = 1000
    end


    properties ( Access = private )
        pBasemap char = globe.internal.GlobeModel.defaultBasemap
        pTerrainName char = globe.internal.GlobeModel.defaultTerrainName
    end

    properties
        GlobeOptions( 1, 1 )globe.internal.GlobeOptions = globe.internal.GlobeOptions
    end

    methods
        function model = GlobeModel( varargin )










            model.Basemap = globe.internal.GlobeModel.defaultBasemap;
            model.pTerrainName = globe.internal.GlobeModel.defaultTerrainName;
            globe.internal.setObjectNameValuePairs( model, varargin )
            model.TerrainSource = model.createTerrainSource( model.TerrainName );
            model.ReaderMap = containers.Map;
        end


        function config = mapConfiguration( model )


            basemap = model.Basemap;
            if logical( model.GlobeOptions.EnableBaseLayerPicker )

                [ bmaps, selectedIndex ] = globe.internal.GlobeModel.mapConfigurationFromSettings( model, basemap );
            else

                [ bmaps, selectedIndex ] = mapConfigurationFromSelector( model, basemap );
            end


            config = struct(  ...
                'BasemapSources', { bmaps },  ...
                'BasemapSelectedIndex', selectedIndex,  ...
                'TileCacheSize', model.MapTileCacheSize );


            terrainConfig = getTerrainConfiguration( model );


            names = fieldnames( terrainConfig );
            for k = 1:length( names )
                config.( names{ k } ) = terrainConfig.( names{ k } );
            end


            names = fieldnames( model.GlobeOptions );
            for k = 1:length( names )
                globeOptionName = names{ k };
                globeOptionValue = model.GlobeOptions.( globeOptionName );
                config.( globeOptionName ) = logical( globeOptionValue );
            end
        end


        function isAvailable = isTerrainURLAvailable( model )


            if strcmp( model.TerrainSource, 'none' )
                isAvailable = false;
            else
                isAvailable = model.TerrainSource.isLocationAvailable;
            end
        end


        function set.Basemap( model, basemap )
            if logical( model.GlobeOptions.EnableBaseLayerPicker )


                basemap = strrep( basemap, '-', '_' );
                choices = globe.internal.GlobeModel.basemapchoices( model.GlobeOptions.EnableOSM );
            else


                choices = matlab.graphics.chart.internal.maps.basemapNames;
                if ~isempty( which( basemap + "_configuration.xml" ) )
                    choices = [ choices;basemap ];
                end
            end
            basemap = validatestring( basemap, choices, '', 'Basemap' );
            model.pBasemap = char( basemap );
        end


        function basemap = get.Basemap( model )
            basemap = model.pBasemap;
        end


        function set.TerrainName( model, terrainName )
            model.pTerrainName = validatestring( terrainName,  ...
                terrain.internal.TerrainSource.terrainchoices, '', 'TerrainName' );
            model.TerrainSource = model.createTerrainSource( model.TerrainName );
        end


        function terrainName = get.TerrainName( model )
            terrainName = model.pTerrainName;
        end


        function useTerrain = get.UseTerrain( model )
            useTerrain = model.TerrainName ~= "none";
        end

        function delete( model )

            if ( model.GlobeOptions.EnableBaseLayerPicker &&  ...
                    ~isempty( model.CustomBasemapIconDir ) )
                try
                    rmdir( model.CustomBasemapIconDir, 's' );
                catch e %#ok<NASGU>



                end
            end
        end

        function Z = queryTerrainHeightReferencedToEllipsoid( model, lats, lons )






            if model.UseTerrain

                terrainSource = model.TerrainSource;
                Z = terrainSource.query( lats, lons, 'OutputHeightReference', 'ellipsoid' );
            else

                Z = zeros( numel( lats ), 1 );
            end
        end
    end


    methods ( Static )

        function [ bmaps, selectedIndex ] = mapConfigurationFromSettings( model, currentBasemap )

            bmaps = {  };
            mwBasemapsSelector = matlab.graphics.chart.internal.maps.BaseLayerSelector;
            readerMap = model.ReaderMap;

            [ basemaps, basemapNames, basemapPlacements ] = basemapsInfo;
            [ ~, sortInd ] = sort( basemapPlacements );
            selectedIndex = 0;


            if ( isempty( model.CustomBasemapIconDir ) )
                model.CustomBasemapIconDir = tempname;
                mkdir( model.CustomBasemapIconDir );
            end



            if ( ~isempty( model.BasemapStructs ) )
                bmaps = model.BasemapStructs;
                [ selectedIndex, foundBasemap ] = findInBasemapStruct( bmaps, currentBasemap );




                if ~foundBasemap
                    model.Basemap = bmaps{ selectedIndex + 1 }.Name;
                end
                return ;
            end

            choseBasemap = false;

            for k = sortInd
                basemap = basemaps{ k };
                basemapName = basemapNames{ k };
                basemapType = basemap.Type.ActiveValue;
                if strcmp( basemapName, currentBasemap )
                    selectedIndex = numel( bmaps );
                    choseBasemap = true;
                end



                try
                    basemapTitle = message( basemap.Title.ActiveValue ).getString;
                catch e %#ok<NASGU>
                    basemapTitle = basemap.Title.ActiveValue;
                end
                try
                    basemapTooltip = message( basemap.Tooltip.ActiveValue ).getString;
                catch e %#ok<NASGU>
                    basemapTooltip = basemap.Tooltip.ActiveValue;
                end


                icon = basemap.Icon.ActiveValue;
                iconPath = which( icon );
                if isempty( iconPath ) && ( exist( icon, 'file' ) == 2 )
                    iconPath = icon;
                end
                if ~isempty( iconPath )


                    iconURL = controller.ConnectorServiceProvider.getResourceURL(  ...
                        iconPath, [ 'globemapicons', basemapName ] );
                else

                    iconURL = icon;
                end

                basemapStruct = struct(  ...
                    'Title', basemapTitle,  ...
                    'Name', basemapName,  ...
                    'Type', basemapType,  ...
                    'Icon', iconURL,  ...
                    'Tooltip', basemapTooltip,  ...
                    'IsInternetURL', true );

                if strcmp( basemapType, 'MathWorks' )


                    tileSetName = basemap.TileSetName.ActiveValue;
                    basemapStruct = getBasemapInfoFromSelector( mwBasemapsSelector, basemapStruct, tileSetName );
                elseif strcmp( basemapType, 'ArcGIS' )
                    basemapStruct.URL = basemap.URL.ActiveValue;
                end
                bmaps{ end  + 1 } = basemapStruct;
            end

            if ( ~model.GlobeOptions.EnableOSM )
                for k = 1:numel( bmaps )
                    bmapStruct = bmaps{ k };
                    if ( strcmp( bmapStruct.Name, 'openstreetmap' ) )
                        bmaps( k ) = [  ];
                        break ;
                    end
                end
            end

            if ~( customBasemapsAvailable )
                model.BasemapStructs = bmaps;
                return ;
            end
            [ customBasemaps, customBasemapNames ] = customBasemapsInfo(  );
            numCustBasemaps = numel( customBasemaps );
            for k = 1:numCustBasemaps


                basemap = customBasemaps{ k };
                basemapName = customBasemapNames{ k };
                basemapTitle = basemap.DisplayName.ActiveValue;
                if ( isempty( basemapTitle ) )
                    basemapTitle = basemapName;
                end
                basemapTooltip = basemapName;
                mapURL = basemap.URL.ActiveValue;



                cbasemapName = strrep( basemapName, '_', '' );
                iconName = [ cbasemapName, '_icon.png' ];
                iconFileName = fullfile( model.CustomBasemapIconDir, iconName );

                if endsWith( mapURL, ".mbtiles" )
                    basemapType = 'MBTiles';
                    reader = selectReader( mwBasemapsSelector, basemapName );
                    readerMap( basemapName ) = reader;
                    icon = readMapTile( reader, 0, 0, 0 );
                    imwrite( icon, iconFileName );
                    iconDownloadFailed = false;
                    isInternetURL = false;
                else
                    basemapType = "Custom";
                    [ iconDownloadFailed, mapURL ] = downloadIconFilename( mapURL, iconFileName );
                    isInternetURL = true;
                end

                if iconDownloadFailed

                    wstate = warning( 'off', 'backtrace' );
                    C = onCleanup( @(  )warning( wstate ) );
                    warning( message( 'shared_globe:viewer:UnableToReadMapTiles', mapURL, basemapName ) );
                    continue ;
                end

                basemapStruct = struct(  ...
                    'Title', basemapTitle,  ...
                    'Name', basemapName,  ...
                    'Type', basemapType,  ...
                    'Tooltip', basemapTooltip,  ...
                    'IsInternetURL', isInternetURL,  ...
                    'Icon', globe.internal.ConnectorServiceProvider.getResourceURL( iconFileName, [ 'rfpropmapicons', cbasemapName ] ),  ...
                    'URL', mapURL,  ...
                    'MaxZoomLevel', basemap.MaxZoomLevel.ActiveValue,  ...
                    'Credit', basemap.Attribution.ActiveValue );

                if strcmp( basemapName, currentBasemap ) && ~choseBasemap




                    selectedIndex = numel( bmaps );
                    choseBasemap = true;
                end
                bmaps{ end  + 1 } = basemapStruct;
            end
            if ( ~choseBasemap )



                defaultBasemap = globe.internal.GlobeModel.defaultBasemap;


                model.Basemap = defaultBasemap;
                [ ~, basemapNames, basemapPlacements ] = basemapsInfo;
                selectedIndex = basemapPlacements( strcmp( basemapNames, defaultBasemap ) ) - 1;
            end
            model.BasemapStructs = bmaps;
        end

        function choices = basemapchoices( enableOSM )
            arguments


                enableOSM = true
            end
            s = settings;
            basemapSettings = s.shared.globe.basemaps;
            choices = properties( basemapSettings );
            if ~enableOSM
                choices( strcmp( choices, 'openstreetmap' ) ) = [  ];
            end
            customBasemaps = matlab.internal.maps.BasemapSettingsGroup;
            choices = [ choices;cellstr( customBasemaps.BasemapNames ) ];
        end


        function basemap = defaultBasemap
            s = settings;
            basemap = s.shared.globe.DefaultBasemap.ActiveValue;



            [ ~, basemapNames ] = basemapsInfo;
            if ( numel( basemapNames ) > 0 ) && ~ismember( basemap, basemapNames )
                basemap = basemapNames{ 1 };
            end
        end

        function terrain = defaultTerrainName
            s = settings;
            terrain = s.shared.globe.DefaultTerrain.ActiveValue;
        end


        function terrainSource = createTerrainSource( terrainName )
            if strcmpi( terrainName, 'none' )
                terrainSource = 'none';
            else





                terrainSource = terrain.internal.TerrainSource.createFromSettings( terrainName, true );
            end
        end

        function [ Zgeoid, Zreference ] = queryTerrainHeight( lats, lons )





            globeViewer = globe.internal.GlobeViewer.current;
            globeModel = globeViewer.Controller.GlobeModel;

            if globeModel.UseTerrain
                terrainSource = globeModel.TerrainSource;
                Zgeoid = terrainSource.query( lats, lons, 'OutputHeightReference', 'geoid' );
                if strcmp( terrainSource.HeightReference, 'ellipsoid' )
                    Zreference = terrainSource.query( lats, lons, 'OutputHeightReference', 'ellipsoid' );
                else
                    Zreference = Zgeoid;
                end
            else

                Zgeoid = zeros( numel( lats ), 1 );
                Zreference = Zgeoid;
            end
        end

        function tf = verifyConnection( url )







            usingHTTPS = startsWith( url, 'https:' );
            opt = matlab.net.http.HTTPOptions;
            if usingHTTPS
                opt.MaxRedirects = 0;
            end


            usingConnector = startsWith( url, connector.getBaseUrl );
            if ( usingConnector )
                opt.CertificateFilename = connector.getCertificateLocation;
                url = connector.applyNonce( url, true );
            end

            request = matlab.net.http.RequestMessage;
            try

                response = send( request, url, opt );
                tf = strcmpi( response.StatusCode, "OK" );
            catch
                tf = false;
            end
        end
    end
end


function [ basemaps, basemapNames, basemapPlacements ] = basemapsInfo
s = settings;
allBasemaps = s.shared.globe.basemaps;
allBasemapNames = properties( allBasemaps );


basemaps = {  };
basemapNames = {  };
basemapPlacements = [  ];
for k = 1:numel( allBasemapNames )
    basemapName = allBasemapNames{ k };
    basemap = allBasemaps.( basemapName );
    try %#ok<TRYNC> Protect against empty setting group (g1575207)
        placement = basemap.Placement.ActiveValue;
        basemaps{ end  + 1 } = basemap;%#ok<*AGROW>
        basemapNames{ end  + 1 } = basemapName;
        basemapPlacements( end  + 1 ) = placement;
    end
end
end


function [ basemaps, basemapNames ] = customBasemapsInfo
s = settings;
basemapSettingsGroup = matlab.internal.maps.BasemapSettingsGroup;
allCustomBasemaps = s.( basemapSettingsGroup.TopLevelGroupName ).( basemapSettingsGroup.BasemapGroupName );
allCustomBasemapNames = properties( allCustomBasemaps );


basemaps = {  };
basemapNames = {  };

for k = 1:numel( allCustomBasemapNames )
    basemapName = allCustomBasemapNames{ k };
    basemap = allCustomBasemaps.( basemapName );
    basemaps{ end  + 1 } = basemap;
    basemapNames{ end  + 1 } = basemapName;
end


[ basemapNames, sortInds ] = sort( basemapNames );
basemaps = basemaps( sortInds );
end


function validateName( name )
validateattributes( name, { 'char', 'string' }, { 'scalartext' }, '', 'Name' );
end


function [ basemapInfo, reader ] = getBasemapInfoFromSelector( mwBasemapsSelector, basemapInfo, tileSetName )
reader = selectReader( mwBasemapsSelector, tileSetName );
meta = reader.TileSetMetadata;
locationTemplate = meta.MapTileLocation.ParameterizedLocation;
basemapInfo.IsInternetURL = meta.MapTileLocation.IsMapTileURL;

if basemapInfo.IsInternetURL


    locationTemplate = replaceTemplateWithCesiumConvention( locationTemplate );
    basemapInfo.URL = locationTemplate;
elseif endsWith( locationTemplate, ".mbtiles" )
    basemapInfo.URL = char( locationTemplate );
elseif ~matlab.internal.lang.capability.Capability.isSupported( 'LocalClient' )


    basemapURL = getBasemapURL( tileSetName );
    basemapInfo.URL = basemapURL;
    basemapInfo.IsInternetURL = true;
else


    locationTemplate = replaceTemplateWithCesiumConvention( locationTemplate );


    location = extractBefore( locationTemplate, "{z}" );
    template = "{z}" + extractAfter( locationTemplate, "{z}" );
    template = replace( template, "\", "/" );
    basemapInfo.URL = globe.internal.ConnectorServiceProvider.addBasemapFolderToServer(  ...
        char( location ), char( tileSetName ), char( template ) );
end
basemapInfo.MaxZoomLevel = meta.MaxZoomLevel;







basemapInfo.Credit = char( meta.Attribution );

url = basemapInfo.URL;
usingConnector = startsWith( url, connector.getBaseUrl );
usingFileCaching = ~isempty( meta.MapTileCacheLocation );

if contains( url, 'ssd.mathworks.com' ) || usingConnector
    basemapInfo.Type = 'MathWorks';
elseif contains( url, 'ArcGIS' ) && usingFileCaching
    basemapInfo.Type = 'ArcGIS';
    basemapInfo.URL = char( extractBefore( url, '/tile' ) );
elseif endsWith( locationTemplate, ".mbtiles" )
    basemapInfo.Type = 'MBTiles';
else
    basemapInfo.Type = 'Custom';
    basemapInfo.URL = strrep( char( url ), '$', '' );
end
end


function [ bmaps, selectedIndex ] = mapConfigurationFromSelector( model, currentBasemap )
bmaps = {  };
selector = matlab.graphics.chart.internal.maps.BaseLayerSelector;
basemapNames = matlab.graphics.chart.internal.maps.basemapNames;
if ~any( matches( basemapNames, currentBasemap ) )
    basemapNames( end  + 1 ) = currentBasemap;
end
selectedIndex = find( strcmpi( currentBasemap, basemapNames ), 1 ) - 1;

for k = 1:length( basemapNames )
    basemapStruct = struct(  ...
        'Title', '',  ...
        'Name', char( basemapNames( k ) ),  ...
        'Type', '',  ...
        'Icon', '',  ...
        'Tooltip', '',  ...
        'IsInternetURL', true,  ...
        'Credit', '' );
    [ basemapStruct, thisReader ] = getBasemapInfoFromSelector( selector, basemapStruct, basemapNames( k ) );
    bmaps{ end  + 1 } = basemapStruct;
    if k == selectedIndex + 1
        reader = thisReader;
        model.ReaderMap( basemapNames( k ) ) = reader;
    end
end
end


function config = getTerrainConfiguration( model )

useTerrain = model.UseTerrain;
if useTerrain
    terrain = model.TerrainSource;
    if terrain.IsURLLocation
        terrainURL = terrain.Location;
    else
        terrainURL = globe.internal.ConnectorServiceProvider.getResourceURL(  ...
            terrain.Location, 'terraintiles' );
    end
    terrainMaxZoomLevel = terrain.MaxZoomLevel;
    terrainAttribution = terrain.Attribution;
    terrainLatLim = terrain.LatitudeLimits;
    terrainLonLim = terrain.LongitudeLimits;
else

    terrainURL = '';
    terrainMaxZoomLevel = 0;
    terrainAttribution = '';
    terrainLatLim = [  ];
    terrainLonLim = [  ];
end


s = settings;
clipping = s.shared.globe.Clipping.ActiveValue;


config = struct(  ...
    'UseTerrain', useTerrain,  ...
    'TerrainURL', terrainURL,  ...
    'TerrainMaxZoomLevel', terrainMaxZoomLevel,  ...
    'TerrainAttribution', terrainAttribution,  ...
    'TerrainLatitudeLimits', terrainLatLim,  ...
    'TerrainLongitudeLimits', terrainLonLim,  ...
    'ClipAgainstTerrain', clipping );
end


function available = customBasemapsAvailable
basemapSettingsGroup = matlab.internal.maps.BasemapSettingsGroup;
available = ~isempty( basemapSettingsGroup.BasemapNames );
end


function [ iconURL, mapURL ] = checkHTTPS( iconURL, mapURL )



if startsWith( iconURL, 'http:' )

    httpsURL = strrep( iconURL, 'http:', 'https:' );
    tf = globe.internal.GlobeModel.verifyConnection( httpsURL );



    if tf
        iconURL = httpsURL;
        mapURL = strrep( mapURL, 'http:', 'https:' );
    end
end
end


function [ selectedIndex, foundBasemap ] = findInBasemapStruct( bmaps, currentBasemap )
selectedIndex = 0;
numBasemaps = numel( bmaps );
foundBasemap = false;
for i = 1:numBasemaps
    if strcmp( bmaps{ i }.Name, currentBasemap )
        selectedIndex = i - 1;
        foundBasemap = true;
        break ;
    end
end
if ~foundBasemap

    defaultBasemap = globe.internal.GlobeModel.defaultBasemap;
    [ ~, basemapNames, basemapPlacements ] = basemapsInfo;
    selectedIndex = basemapPlacements( strcmp( basemapNames, defaultBasemap ) ) - 1;
    wstate = warning( 'off', 'backtrace' );
    C = onCleanup( @(  )warning( wstate ) );
    warning( message( 'shared_globe:viewer:UnableToReadMapTilesDuringSet', currentBasemap, bmaps{ selectedIndex + 1 }.Name ) )
end
end


function url = getBasemapURL( tileSetName )




basemap = "colorterrain";
meta = matlab.graphics.chart.internal.maps.TileSetMetadata;
meta.TileSetName = basemap;
datafolder = matlab.graphics.chart.internal.maps.mapdatadir;
meta = readMetadata( meta, datafolder );
url = meta.MapTileLocation.ParameterizedLocation;
url = replace( url, basemap, tileSetName );


url = replaceTemplateWithCesiumConvention( url );
end

function url = replaceTemplateWithCesiumConvention( url )

url = replace( url,  ...
    [ "${zoomLevel}", "${tileRow}", "${tileCol}" ],  ...
    [ "{z}", "{y}", "{x}" ] );
url = replace( url, '$', '' );
end

function [ iconDownloadFailed, mapURL ] = downloadIconFilename( mapURL, iconFileName )



mapURL = strrep( mapURL, '$', '' );

if exist( iconFileName, "file" )
    iconDownloadFailed = false;
else





    iconURL = strrep( mapURL, '{z}', '1' );
    iconURL = strrep( iconURL, '{x}', '0' );
    iconURL = strrep( iconURL, '{y}', '0' );




    [ iconURL, mapURL ] = checkHTTPS( iconURL, mapURL );

    iconDownloadFailed = false;


    usingconnector = strfind( iconURL, connector.getBaseUrl );



    maxNumRetries = 5;
    for i = 0:maxNumRetries
        opt = weboptions;


        opt.Timeout = 30;
        try
            if usingconnector
                opt.CertificateFilename = connector.getCertificateLocation;
                websave( iconFileName, connector.applyNonce( iconURL, true ), opt );
            else
                websave( iconFileName, iconURL, opt );
            end
            break ;
        catch
            if i >= maxNumRetries
                iconDownloadFailed = true;
            end
        end
    end
end
end

