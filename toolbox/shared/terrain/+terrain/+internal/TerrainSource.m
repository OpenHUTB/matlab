classdef(Sealed,Hidden)TerrainSource<handle

    properties(SetAccess=private)
Name
IsURLLocation
Location
MaxZoomLevel
Attribution
IntrinsicResolution
LatitudeLimits
LongitudeLimits
InterpolationMethod
HeightReference
    end

    properties(Dependent,SetAccess=private)
IntrinsicResolutionArcLength
    end

    properties(Hidden,SetAccess=private)
TerrainTileReader
IsURLLocationAvailable
TileCache
        TileCacheSize=100;
    end

    properties(Constant,Hidden)
        InstanceCache=containers.Map
        DTEDFileExtensions=[".dt0",".dt1",".dt2"]
        EarthRadius=6371000
        MaxBuildingsTerrainTriangulationResolution=30;
        TerrainRegionBuffer=500;
        MaxTerrainTriangulationNumFacets=15000;
    end

    methods(Static)
        function choices=terrainchoices(option)

            if nargin<1
                option='all';
            else
                option=validatestring(option,{'custom','factory'});
            end

            s=settings;
            terrainSettings=s.shared.terrain;

            switch option
            case 'custom'

                choices=setdiff(properties(terrainSettings),{'gmted2010'});

            case 'all'

                choices=['none';properties(terrainSettings)];

            case 'factory'

                choices={'none';'gmted2010'};
            end
        end

        function tf=isfullpath(file)

            file=char(file);
            fs=filesep;
            tf=(~isempty(file)&&...
            (file(1)==fs||file(1)=='/'||...
            (ispc&&numel(file)>=3&&file(2)==':'&&...
            (file(3)==fs||file(3)=='/'))));
        end

        function validateTerrainFileFormat(p,files)

            if~all(endsWith(files,terrain.internal.TerrainSource.DTEDFileExtensions))
                if p.Results.AllowAllGeographicRasterFormats



                    assert(~isempty(ver('map')),...
                    message('shared_terrain:terrain:FileRequiresMapping'))
                else
                    error(message('shared_terrain:terrain:FileNotSupported'))
                end



                [~,~,exts]=fileparts(files);
                assert(numel(unique(exts))==1,...
                message('shared_terrain:terrain:FileFormatInconsistent'))
            end
        end

        function terrainSource=createFromData(name,terrainData,varargin)



            p=inputParser;
            p.addParameter('FillMissing',false,@(x)isscalar(x)&&islogical(x));
            p.addParameter('MissingDataReplaceValue',NaN,@(x)isscalar(x)&&isa(x,'double'));
            p.addParameter('HeightReference','geoid');
            p.parse(varargin{:});
            inputs=p.Results;
            fillMissing=inputs.FillMissing;
            missingDataReplaceValue=inputs.MissingDataReplaceValue;
            heightReference=validateHeightReference(inputs.HeightReference);

            if terrainData.IsFileSource

                files=string(terrainData.Source);
                numfiles=numel(files);
                for fileInd=1:numfiles
                    file=files(fileInd);
                    filePath=which(file);
                    if isempty(filePath)
                        if exist(file,'file')==2
                            filePath=file;
                        else
                            error(message('shared_terrain:terrain:FileNotFound',file));
                        end
                    end
                    files(fileInd)=filePath;
                end


                if all(endsWith(files,terrain.internal.TerrainSource.DTEDFileExtensions))
                    tileReader=terrain.internal.DTEDTileReader(terrainData,fillMissing);
                else
                    tileReader=terrain.internal.GeorasterTileReader(...
                    terrainData,fillMissing,missingDataReplaceValue);
                end
            else

                tileReader=terrain.internal.GeorasterTileReader(...
                terrainData,fillMissing,missingDataReplaceValue);
            end


            terrainSource=terrain.internal.TerrainSource;
            terrainSource.Name=name;
            terrainSource.IsURLLocation=false;
            terrainSource.TerrainTileReader=tileReader;
            terrainSource.IntrinsicResolution=terrainSource.TerrainTileReader.IntrinsicResolution;
            terrainSource.LatitudeLimits=terrainSource.TerrainTileReader.LatitudeLimits;
            terrainSource.LongitudeLimits=terrainSource.TerrainTileReader.LongitudeLimits;
            terrainSource.InterpolationMethod='linear';
            terrainSource.HeightReference=heightReference;



            terrainSource.TileCacheSize=4;


            maxZoomLevel=1;
            arcsecres=terrain.internal.TerrainSource.zoomLevelResolution(maxZoomLevel);
            while arcsecres>terrainSource.IntrinsicResolution
                maxZoomLevel=maxZoomLevel+1;
                arcsecres=terrain.internal.TerrainSource.zoomLevelResolution(maxZoomLevel);
            end
            terrainSource.MaxZoomLevel=maxZoomLevel;
        end

        function terrainSource=createFromSettings(name,validateURL)


            cacheName=lower(name);
            instanceCache=terrain.internal.TerrainSource.InstanceCache;
            if isKey(instanceCache,cacheName)
                terrainSource=instanceCache(cacheName);


                if(nargin<2)
                    validateURL=false;
                end
            else

                s=settings;
                sg=s.shared.terrain.(name);


                loc=sg.Location.ActiveValue;
                isURLLocation=sg.IsURLLocation.ActiveValue;
                maxZoomLevel=sg.MaxZoomLevel.ActiveValue;
                tileReader=terrain.internal.HeightmapTileReader(loc,...
                'IsURLLocation',isURLLocation,...
                'ZoomLevel',maxZoomLevel);


                terrainSource=terrain.internal.TerrainSource;
                terrainSource.IsURLLocation=isURLLocation;
                terrainSource.Location=loc;
                terrainSource.TerrainTileReader=tileReader;


                terrainSource.Name=name;
                terrainSource.MaxZoomLevel=maxZoomLevel;
                attribution=sg.Attribution.ActiveValue;
                try

                    attribution=message(attribution).getString;
                catch e %#ok<NASGU>

                end
                terrainSource.Attribution=attribution;
                terrainSource.IntrinsicResolution=sg.IntrinsicResolution.ActiveValue;
                terrainSource.LatitudeLimits=sg.LatitudeLimits.ActiveValue;
                terrainSource.LongitudeLimits=sg.LongitudeLimits.ActiveValue;
                terrainSource.InterpolationMethod='triangular';
                if sg.hasSetting('HeightReference')
                    terrainSource.HeightReference=sg.HeightReference.ActiveValue;
                else

                    terrainSource.HeightReference='geoid';
                end


                instanceCache(cacheName)=terrainSource;%#ok<NASGU>



                validateURL=true;
            end

            if validateURL&&terrainSource.IsURLLocation
                terrainSource.IsURLLocationAvailable=isURLLocationAvailable(terrainSource);
            end
        end

        function Z=queryTerrain(terrainSource,latlon,outputHeightReference)


            if isempty(terrainSource)||strcmp(terrainSource,'none')
                Z=zeros(size(latlon,1),1);
            else
                Z=terrainSource.query(latlon(:,1),latlon(:,2),...
                'OutputHeightReference',outputHeightReference);

                if strcmp(outputHeightReference,'geoid')
                    Z=terrain.internal.TerrainSource.snapMeanSeaLevel(Z);
                end
            end
        end

        function Z=snapMeanSeaLevel(Z)




            tolerance=0.1;
            Z(abs(Z)<tolerance)=0;
        end
    end


    methods(Access=private)
        function terrain=TerrainSource
            terrain.TileCache=containers.Map;
        end
    end

    methods
        function resm=get.IntrinsicResolutionArcLength(terrainSource)
            arcsec=terrainSource.IntrinsicResolution;
            switch(round(arcsec,2))
            case 0.33
                resm=10;
            case 1
                resm=30;
            case 3
                resm=90;
            case 7.5
                resm=250;
            case 30
                resm=900;
            otherwise

                arcdeg=arcsec/3600;
                resm=terrain.internal.TerrainSource.EarthRadius*deg2rad(arcdeg);
            end
        end

        function Z=query(terrainSource,latq,lonq,varargin)



            p=inputParser;
            p.addParameter('ZoomLevel',terrainSource.MaxZoomLevel);
            p.addParameter('OutputHeightReference','geoid');
            p.parse(varargin{:});
            zoomLevel=p.Results.ZoomLevel;
            outputHeightReference=validateHeightReference(p.Results.OutputHeightReference);



            reader=terrainSource.TerrainTileReader;
            if isprop(reader,'ZoomLevel')&&zoomLevel~=reader.ZoomLevel
                terrainSource.resetTileCache;
                reader.ZoomLevel=zoomLevel;
            end


            Z=nan(size(latq));
            nn=~isnan(latq)&~isnan(lonq);
            nnlatq=latq(nn);
            nnlonq=lonq(nn);
            if~isempty(nnlatq)



                Z(nn)=terrainSource.tileInterpolation(nnlatq(:),nnlonq(:),...
                outputHeightReference);
            end
        end

        function oor=isOutOfRange(terrainSource,lats,lons)
            latLimits=terrainSource.LatitudeLimits;
            lonLimits=terrainSource.LongitudeLimits;
            oor=lats<latLimits(1)|lats>latLimits(2)|...
            lons<lonLimits(1)|lons>lonLimits(2);
        end

        function isGlobal=isGlobalTerrain(terrainSource)


            latLimits=terrainSource.LatitudeLimits;
            lonLimits=terrainSource.LongitudeLimits;
            isGlobal=(latLimits(2)-latLimits(1))==180&&(lonLimits(2)-lonLimits(1))==360;
        end

        function isAvailable=isLocationAvailable(terrainSource)

            if terrainSource.IsURLLocation
                isAvailable=terrainSource.IsURLLocationAvailable;
            else
                isAvailable=exist(terrainSource.Location,"dir")==7;
            end
        end

        function resetTileCache(terrainSource)
            cache=terrainSource.TileCache;
            cache.remove(cache.keys);
        end
    end

    methods(Static)
        function resetCache
            cache=terrain.internal.TerrainSource.InstanceCache;
            cache.remove(cache.keys);
        end

        function arcsec=zoomLevelResolution(zoomLevel)




            tileSize=terrain.internal.HeightmapTileReader.TileSize;



            ny=2^zoomLevel;
            yExtentDeg=180/ny;
            arcsec=(yExtentDeg/(tileSize-1))*3600;
        end

        function[zoomLevel,numTiles]=terrainZoomLevel(terrainSource,...
            lats,lons,maxNumTiles)




            minZoom=4;






            reader=terrainSource.TerrainTileReader;
            zoomLevel=terrainSource.MaxZoomLevel+1;
            numTiles=maxNumTiles+1;
            while numTiles>maxNumTiles&&zoomLevel>minZoom
                zoomLevel=zoomLevel-1;
                reader.ZoomLevel=zoomLevel;
                tileCoords=findTiles(reader,lats,lons);
                numTiles=length(tileCoords);
            end



            terrainSource.resetTileCache;
        end

        function[lats,lons,groundElevation,gridSize]=terrainGrid(terrainSource,latlim,lonlim,maxres)



            noTerrain=strcmp(terrainSource,'none');
            if noTerrain
                zoomLevel=10;
            else
                zoomLevel=terrainSource.MaxZoomLevel;
            end
            resarcsec=terrain.internal.TerrainSource.zoomLevelResolution(zoomLevel);
            resdeg=resarcsec/3600;



            numSamplesToMinLon=floor((lonlim(1)+180)/resdeg);
            numSamplesToMaxLon=ceil((lonlim(2)+180)/resdeg);
            minLon=-180+numSamplesToMinLon*resdeg;
            maxLon=-180+numSamplesToMaxLon*resdeg;



            numSamplesToMinLat=floor((latlim(1)+90)/resdeg);
            numSamplesToMaxLat=ceil((latlim(2)+90)/resdeg);
            minLat=-90+numSamplesToMinLat*resdeg;
            maxLat=-90+numSamplesToMaxLat*resdeg;


            resm=terrain.internal.TerrainSource.EarthRadius*deg2rad(resdeg);
            resdivisor=max(1,ceil(resm/maxres));
            gridresdeg=resdeg/resdivisor;




            numlats=1+round((maxLat-minLat)/gridresdeg);
            numlons=1+round((maxLon-minLon)/gridresdeg);
            latsv=linspace(minLat,maxLat,numlats);
            lonsv=linspace(minLon,maxLon,numlons);
            [lonX,latY]=meshgrid(lonsv,latsv);
            gridSize=size(lonX);


            lats=latY(:);
            lons=lonX(:);
            if noTerrain
                groundElevation=zeros(size(lats,1),1);
            else
                groundElevation=terrainSource.query(lats,lons,...
                'OutputHeightReference',terrainSource.HeightReference);
            end
        end

        function terrainTri=terrainGridTriangulation(terrainSource,lat0,lon0,z0,latlim,lonlim,res)




            useAutoResolution=nargin<7;
            if useAutoResolution
                if strcmp(terrainSource,'none')
                    res=250;
                else
                    res=terrainSource.IntrinsicResolutionArcLength;
                end
            end


            terrainGridDone=false;
            prevGridSize=[0,0];
            while~terrainGridDone

                [lats,lons,groundElevation,gridSize]=...
                terrain.internal.TerrainSource.terrainGrid(terrainSource,latlim,lonlim,res);



                numFacets=2*(gridSize(1)-1)*(gridSize(2)-1);
                terrainGridDone=~useAutoResolution||...
                isequal(prevGridSize,gridSize)||(numFacets<=terrain.internal.TerrainSource.MaxTerrainTriangulationNumFacets);
                if~terrainGridDone
                    prevGridSize=gridSize;
                    res=res*2;
                end
            end


            [x,y,z]=rfprop.internal.MapUtils.geodetic2enu(lat0,lon0,z0,lats,lons,groundElevation);


            x=reshape(x,gridSize);
            y=reshape(y,gridSize);
            z=reshape(z,gridSize);
            [F,V]=surf2patch(x,y,z,'triangles');
            terrainTri=triangulation(F,V);
        end

        function[tri,numBuildingsFacets]=regionTriangulation(terrainSourceOrViewer,txsCoords,lats,lons)


            if isa(terrainSourceOrViewer,'siteviewer')
                viewer=terrainSourceOrViewer;
                terrainSource=viewer.TerrainSource;
                buildingsModel=viewer.BuildingsModel;



                if all(txsCoords.withinBuildingsLimits(lats,lons))
                    numBuildingsFacets=size(buildingsModel.Model,1);
                    tri=viewer.BuildingsTerrainTriangulation;
                    return
                end
            else
                terrainSource=terrainSourceOrViewer;
                buildingsModel=[];
            end


            [latmin,latmax]=bounds(lats(:));
            [lonmin,lonmax]=bounds(lons(:));
            [latlim,lonlim]=bufferRegion([latmin,latmax],[lonmin,lonmax]);




            terrainOnlyTri=true;
            if~isempty(buildingsModel)

                bldgsLimits=viewer.BuildingsLimits;
                [bldgslatlim,bldgslonlim]=bufferRegion(bldgsLimits(1:2),bldgsLimits(3:4));




                terrainOnlyTri=(bldgslatlim(1)>latlim(2))||(latlim(1)>bldgslatlim(2))||...
                (bldgslonlim(1)>lonlim(2))||(lonlim(1)>bldgslonlim(2));
            end


            regionCenter=txsCoords.RegionCenter;
            lat0=regionCenter(1);
            lon0=regionCenter(2);
            z0=regionCenter(3);
            if terrainOnlyTri
                numBuildingsFacets=0;
                tri=terrain.internal.TerrainSource.terrainGridTriangulation(...
                terrainSource,lat0,lon0,z0,latlim,lonlim);
            else


                terrainres=terrain.internal.TerrainSource.MaxBuildingsTerrainTriangulationResolution;
                terrainTri=terrain.internal.TerrainSource.terrainGridTriangulation(...
                terrainSource,lat0,lon0,z0,latlim,lonlim,terrainres);
                bldgsTri=buildingsModel.Model;
                numBuildingsFacets=size(bldgsTri,1);
                tri=terrain.internal.TerrainSource.combineTriangulations({bldgsTri,terrainTri});
            end
        end

        function[triOut]=combineTriangulations(triIn)



            conn=[];
            vertices=[];

            for idx=1:numel(triIn)
                tri=triIn{idx};
                if iscell(tri)
                    tri=terrain.internal.TerrainSource.combineTriangulations(tri);
                end




                vertexOffset=size(vertices,1);
                conn=[conn;tri.ConnectivityList+vertexOffset];%#ok<AGROW>
                vertices=[vertices;tri.Points];%#ok<AGROW>
            end
            triOut=triangulation(conn,vertices);
        end

        function tri=cleanUpTriangulation(tri)



            fn=faceNormal(tri);
            tri=triangulation(tri.ConnectivityList(~all(fn==[0,0,0],2),:),tri.Points);
        end
    end

    methods(Access=private)
        function Z=tileInterpolation(terrainSource,latq,lonq,outputHeightReference)




            [tiles,locInd]=terrainSource.TerrainTileReader.findTiles(latq,lonq);



            try
                Fs=terrainSource.tileInterpolants(tiles);
            catch e

                latLimits=terrainSource.LatitudeLimits;
                lonLimits=terrainSource.LongitudeLimits;
                if any(isOutOfRange(terrainSource,latq,lonq))


                    error(message('shared_terrain:terrain:TerrainQueryOutOfRange',terrainSource.Name,...
                    string(latLimits(1)),string(latLimits(2)),string(lonLimits(1)),string(lonLimits(2))));
                else
                    throw(e);
                end
            end


            numLocations=numel(latq);
            numTiles=size(tiles,1);
            Z=zeros(numLocations,1);
            for tileInd=1:numTiles
                F=Fs{tileInd};
                isLocationOnTile=(locInd==tileInd);
                if isnumeric(F)
                    Z(isLocationOnTile)=F;
                else
                    Z(isLocationOnTile)=F(latq(isLocationOnTile),lonq(isLocationOnTile));
                end
            end



            heightReference=terrainSource.HeightReference;
            if~strcmpi(heightReference,outputHeightReference)
                if strcmpi(heightReference,'ellipsoid')&&strcmpi(outputHeightReference,'geoid')
                    Z=terrain.internal.HeightTransformation.ellipsoidalToOrthometric(Z,latq,lonq);
                else
                    Z=terrain.internal.HeightTransformation.orthometricToEllipsoidal(Z,latq,lonq);
                end
            end
        end

        function tileInterpolants=tileInterpolants(terrainSource,tiles)



            reader=terrainSource.TerrainTileReader;
            tileTokens=reader.tileKeys(tiles);


            numTiles=size(tiles,1);
            tileInterpolants=cell(1,numTiles);


            tileIndToRequest=[];
            tileCache=terrainSource.TileCache;
            for tileInd=1:numTiles
                tileToken=tileTokens(tileInd);
                if isKey(tileCache,tileToken)
                    tileInterpolants{tileInd}=tileCache(tileToken);
                else
                    tileIndToRequest(end+1)=tileInd;%#ok<AGROW>
                end
            end


            if isempty(tileIndToRequest)
                return
            end




            currentCacheSize=double(tileCache.Count);
            tileCacheSize=terrainSource.TileCacheSize;
            cacheSizeRemaining=tileCacheSize-currentCacheSize;
            numEntriesToRemove=numel(tileIndToRequest)-cacheSizeRemaining;
            if numEntriesToRemove>0
                tileKeysToRemove=tileCache.keys;
                if numEntriesToRemove<currentCacheSize
                    tileCache.remove(tileKeysToRemove(1:numEntriesToRemove));
                else
                    tileCache.remove(tileKeysToRemove);
                end
            end


            tilesToRequest=tiles(tileIndToRequest,:);
            try
                [tilesData,tilesLatvs,tilesLonvs]=reader.readTiles(tilesToRequest);
            catch e
                if~terrainSource.isLocationAvailable&&~terrainSource.IsURLLocation
                    error(message("shared_terrain:terrain:TerrainFolderNotFound",...
                    terrainSource.Name,terrainSource.Location))
                else
                    baseException=MException("shared_terrain:terrain:TerrainNoInternet",...
                    message("shared_terrain:terrain:TerrainNoInternet",terrainSource.Name).getString);
                    baseException=addCause(baseException,e);
                    throw(baseException)
                end
            end


            useLinearInterpolation=strcmpi(terrainSource.InterpolationMethod,'linear');
            for readTileInd=1:numel(tileIndToRequest)

                tileData=tilesData{readTileInd};
                if isscalar(tileData)


                    F=tileData;
                else



                    if any(isnan(tileData(:)))
                        tileData=fillmissing(tileData,...
                        'linear','EndValues','nearest');
                    end




                    latv=tilesLatvs{readTileInd};
                    lonv=tilesLonvs{readTileInd};
                    if useLinearInterpolation
                        F=griddedInterpolant({latv,lonv},tileData);
                    else
                        F=terrain.internal.triangulatedInterpolant({latv,lonv},tileData);
                    end
                end


                tileInd=tileIndToRequest(readTileInd);
                tileInterpolants{tileInd}=F;


                if double(tileCache.Count)<tileCacheSize
                    tileCache(tileTokens(tileInd))=F;
                end
            end
        end

        function isAvailable=isURLLocationAvailable(terrainSource)

            reader=terrainSource.TerrainTileReader;
            if~reader.IsURLLocation

                isAvailable=true;
            else

                layerJSONURL=[terrainSource.Location,'/layer.json'];
                try
                    filename=[tempname,'.json'];
                    if(isempty(reader.DownloadFileWriter))
                        reader.DownloadFileWriter=matlab.internal.asynchttpsave.AsyncHTTPContentFileWriter;
                    end
                    writer=reader.DownloadFileWriter;


                    if(reader.UsingConnector)
                        writer.URL=connector.getUrl(layerJSONURL);
                        writer.Options.CertificateFilename=connector.getCertificateLocation;
                    else
                        writer.URL=layerJSONURL;
                    end


                    writerCleanup=onCleanup(@()cleanup(writer));
                    writer.Filename=filename;
                    writeContentToFilesAndBlock(writer,10);
                    fileDownloaded=~isempty(dir(filename));
                    assert(fileDownloaded);
                    isAvailable=true;
                catch
                    isAvailable=false;
                end
            end
        end
    end
end

function v=validateHeightReference(v)
    v=validatestring(v,{'ellipsoid','geoid'});
end

function[latlim,lonlim]=bufferRegion(latlim,lonlim)


    lats=[latlim,latlim];
    lons=[lonlim(1),lonlim(1),lonlim(2),lonlim(2)];


    buffer=terrain.internal.TerrainSource.TerrainRegionBuffer;
    [latfwd,lonfwd]=rfprop.internal.MapUtils.greatCircleForward(...
    lats,lons,buffer,[0,90,180,270]);


    [latmin,latmax]=bounds(latfwd(:));
    [lonmin,lonmax]=bounds(lonfwd(:));
    latlim=[latmin,latmax];
    lonlim=[lonmin,lonmax];
end
