classdef(Hidden)Tiler<handle




    properties(SetAccess=immutable)
TerrainSource
WriteLocation
MaxZoomLevel
ShowWaitbar
CompressFiles
OutputHeightReference
    end

    properties(Access=private)
Waitbar
        CancelTile=false
    end

    properties(Constant,Hidden)
        TileSize=65
        TerrainTileExtension=".terrain"
        WaitbarUpdateSkipFactor=10
        AddCustomTerrainInputParser=createAddCustomTerrainInputParser
    end

    methods
        function tiler=Tiler(terrainSource,writeLocation,varargin)


            p=inputParser;
            p.addParameter('MaxZoomLevel',terrainSource.MaxZoomLevel);
            p.addParameter('ShowWaitbar',true);
            p.addParameter('CompressFiles',true);
            p.addParameter('OutputHeightReference','ellipsoid');
            p.parse(varargin{:});


            tiler.TerrainSource=terrainSource;
            tiler.WriteLocation=writeLocation;
            tiler.MaxZoomLevel=p.Results.MaxZoomLevel;
            tiler.ShowWaitbar=p.Results.ShowWaitbar;
            tiler.CompressFiles=p.Results.CompressFiles;
            tiler.OutputHeightReference=p.Results.OutputHeightReference;
        end
    end

    methods
        function success=tile(tiler)



            deleteWaitbar(tiler)
            if tiler.ShowWaitbar
                tiler.Waitbar=waitbar(0,message('shared_terrain:terrain:AddCustomTerrainWait').getString,...
                'CreateCancelBtn',@(~,~)setCancelFlag(tiler));
                cleanupWaitbar=onCleanup(@()deleteWaitbar(tiler));
            end



            tiler.CancelTile=false;
            success=false;
            compressFiles=tiler.CompressFiles;
            try



                maxZoomLevel=tiler.MaxZoomLevel;
                mkdir(tiler.WriteLocation,string(maxZoomLevel));
                lastLevelFolders=tiler.generateMaxZoomLevelTerrainTiles;

                for zoomLevel=(maxZoomLevel-1):-1:0
                    mkdir(tiler.WriteLocation,string(zoomLevel));
                    thisLevelFolders=tiler.generateDerivedZoomLevelTerrainTiles(zoomLevel);
                    if compressFiles
                        gzipFolders(tiler,lastLevelFolders);
                        lastLevelFolders=thisLevelFolders;
                    end
                end
                if compressFiles
                    gzipFolders(tiler,lastLevelFolders);
                end

                tiler.generateTerrainMetaFiles;
                success=true;
            catch e

                if~strcmp(e.identifier,'shared_terrain:terrain:AddCustomTerrainCancel')
                    rethrow(e)
                end
            end
        end
    end

    methods(Hidden)
        function deleteWaitbar(tiler)
            if isvalidwaitbar(tiler.Waitbar)
                delete(tiler.Waitbar);
            end
            tiler.Waitbar=[];
        end

        function updateWaitbar(tiler,zoomLevel,r)


            if~tiler.ShowWaitbar||~isvalidwaitbar(tiler.Waitbar)
                return
            end

            [startPos,endPos]=waitbarPosition(tiler,zoomLevel);
            pctDiff=endPos-startPos;
            waitbar(startPos+r*pctDiff,tiler.Waitbar);
        end

        function[startPos,endPos]=waitbarPosition(tiler,zoomLevel)


            z=tiler.MaxZoomLevel;
            tot=2^(z+1);


            num=0;
            while(z>zoomLevel)
                num=num+2^z;
                z=z-1;
            end


            startPos=num/tot;
            endPos=(num+2^zoomLevel)/tot;
        end

        function setCancelFlag(tiler)
            tiler.CancelTile=true;


            if tiler.ShowWaitbar&&isvalidwaitbar(tiler.Waitbar)
                waitbar(0,tiler.Waitbar,message('shared_terrain:terrain:AddCustomTerrainCancel').getString);
            end
        end

        function cancel(tiler)


            for zoomLevel=tiler.MaxZoomLevel:-1:0
                zoomFolder=fullfile(tiler.WriteLocation,int2str(zoomLevel));
                if exist(zoomFolder,'dir')
                    rmdir(zoomFolder,'s');
                end
                tiler.updateWaitbar(zoomLevel,1)
            end


            error(message('shared_terrain:terrain:AddCustomTerrainCancel'));
        end

        function xFolders=generateMaxZoomLevelTerrainTiles(tiler)


            maxZoomLevel=tiler.MaxZoomLevel;
            tileXYs=tiler.tilesToWrite(maxZoomLevel);


            uniqueTileXs=unique(tileXYs(:,1));
            xFolders=fullfile(tiler.WriteLocation,string(maxZoomLevel),...
            string(uniqueTileXs));
            arrayfun(@mkdir,xFolders);


            numtiles=size(tileXYs,1);
            for tileInd=1:numtiles
                if tiler.CancelTile
                    tiler.cancel;
                end

                tileX=tileXYs(tileInd,1);
                tileY=tileXYs(tileInd,2);
                tiler.writeTile(tileX,tileY,maxZoomLevel)
                if mod(tileInd,tiler.WaitbarUpdateSkipFactor)==0
                    tiler.updateWaitbar(maxZoomLevel,tileInd/numtiles)
                end
            end
        end

        function xFolders=generateDerivedZoomLevelTerrainTiles(tiler,zoomLevel)


            tileXYs=tiler.tilesToWrite(zoomLevel);


            uniqueTileXs=unique(tileXYs(:,1));
            xFolders=fullfile(tiler.WriteLocation,string(zoomLevel),...
            string(uniqueTileXs));
            arrayfun(@mkdir,xFolders);


            numtiles=size(tileXYs,1);
            for tileInd=1:numtiles
                if tiler.CancelTile
                    tiler.cancel;
                end

                tileX=tileXYs(tileInd,1);
                tileY=tileXYs(tileInd,2);
                [terrainData,childrenByte]=tiler.generateDerivedTerrainTileData(zoomLevel,tileX,tileY);
                tiler.writeTile(tileX,tileY,zoomLevel,terrainData,childrenByte);
                if mod(tileInd,tiler.WaitbarUpdateSkipFactor)==0
                    tiler.updateWaitbar(zoomLevel,.5*(tileInd/numtiles))
                end
            end





            tileXYs=sortrows(tileXYs);
            nx=terrain.internal.HeightmapTileReader.numXYTiles(zoomLevel);
            for tileInd=1:numtiles
                if tiler.CancelTile
                    tiler.cancel;
                end

                tileX=tileXYs(tileInd,1);
                tileY=tileXYs(tileInd,2);


                [thisTileData,~,childrenByte]=tiler.tileData(zoomLevel,tileX,tileY);


                if tileY>0
                    sTileY=tileY-1;
                    [southData,southExists]=tiler.tileData(zoomLevel,tileX,sTileY);
                    if southExists
                        thisTileData(end,:)=southData(1,:);
                    end
                end


                if tileX<(nx-1)
                    eTileX=tileX+1;
                else
                    eTileX=0;
                end
                [eastData,eastExists]=tiler.tileData(zoomLevel,eTileX,tileY);
                if eastExists
                    thisTileData(:,end)=eastData(:,1);
                end


                tiler.writeTile(tileX,tileY,zoomLevel,thisTileData,childrenByte);
                if mod(tileInd,tiler.WaitbarUpdateSkipFactor)==0
                    tiler.updateWaitbar(zoomLevel,.5+.5*(tileInd/numtiles))
                end
            end
        end

        function gzipFolders(tiler,folders)

            gzFiles=gzip(folders);
            for k=1:numel(gzFiles)
                if tiler.CancelTile
                    tiler.cancel;
                end

                gzFile=gzFiles{k};
                [gzFileFolder,gzFileName]=fileparts(gzFile);
                movefile(gzFile,fullfile(gzFileFolder,gzFileName),'f');
            end
        end

        function generateTerrainMetaFiles(tiler)

            layerJSONFile=fullfile(tiler.WriteLocation,'layer.json');
            fid=fopen(layerJSONFile,'wt');
            fprintf(fid,'%s',...
            ['{',newline...
            ,'  "tilejson": "2.1.0",',newline...
            ,'  "format": "heightmap-1.0",',newline...
            ,'  "version": "1.0.0",',newline...
            ,'  "scheme": "tms",',newline...
            ,'  "tiles": ["{z}/{x}/{y}.terrain"]',newline...
            ,'}']);
            fclose(fid);
        end

        function tileCoordinates=tilesToWrite(tiler,zoomLevel)


            if zoomLevel<1
                tileCoordinates=[0,0;1,0];
                return
            end


            sourceLatLims=tiler.TerrainSource.LatitudeLimits;
            sourceLonLims=tiler.TerrainSource.LongitudeLimits;


            tileXs=[];
            tileYs=[];
            numSourceTiles=size(sourceLatLims,1);
            for sourceTileInd=1:numSourceTiles



                sourceLatLim=sourceLatLims(sourceTileInd,:)';
                sourceLonLim=sourceLonLims(sourceTileInd,:)';
                tileXYLimits=tileCoordinatesForLocation(zoomLevel,sourceLatLim,sourceLonLim);
                tileXLimits=tileXYLimits(:,1);
                tileYLimits=tileXYLimits(:,2);
                tileXv=tileXLimits(1):tileXLimits(2);
                tileYv=tileYLimits(1):tileYLimits(2);

                if zoomLevel==tiler.MaxZoomLevel







                    [wX,wY]=meshgrid(tileXv(1),tileYv);
                    tileXs=[tileXs;wX(:)];%#ok<*AGROW>
                    tileYs=[tileYs;wY(:)];


                    [nX,nY]=meshgrid(tileXv,tileYv(end));
                    tileXs=[tileXs;nX(:)];
                    tileYs=[tileYs;nY(:)];


                    [eX,eY]=meshgrid(tileXv(end),tileYv);
                    tileXs=[tileXs;eX(:)];
                    tileYs=[tileYs;eY(:)];


                    [sX,sY]=meshgrid(tileXv,tileYv(1));
                    tileXs=[tileXs;sX(:)];
                    tileYs=[tileYs;sY(:)];


                    [Xinterior,Yinterior]=meshgrid(tileXv(2:end-1),tileYv(2:end-1));
                    tileXs=[tileXs;Xinterior(:)];
                    tileYs=[tileYs;Yinterior(:)];
                else


                    [X,Y]=meshgrid(tileXv,tileYv);
                    tileXs=[tileXs;X(:)];
                    tileYs=[tileYs;Y(:)];
                end
            end




            tileCoordinates=[tileXs,tileYs];
            tileCoordinates=unique(tileCoordinates,'rows','stable');
        end

        function writeTile(tiler,tileX,tileY,zoomLevel,terrainData,childrenByte)


            isMaxZoomLevel=(zoomLevel==tiler.MaxZoomLevel);
            if isMaxZoomLevel

                [lonX,latY]=tiler.tileMeshGrid(zoomLevel,tileX,tileY);
                terrainData=tiler.TerrainSource.query(latY(:),lonX(:),...
                'OutputHeightReference',tiler.OutputHeightReference);
                terrainData(~isfinite(terrainData))=0;
                tileSize=terrain.internal.Tiler.TileSize;
                terrainData=reshape(terrainData,[tileSize,tileSize]);
                childrenByte=uint16(0);
            end


            tileFile=fullfile(tiler.WriteLocation,string(zoomLevel),...
            string(tileX),string(tileY)+tiler.TerrainTileExtension);
            terrain.internal.HeightmapTileReader.writeHeightmapTile(tileFile,terrainData,childrenByte);
        end

        function[terrainData,childrenByte]=generateDerivedTerrainTileData(tiler,zoomLevel,tileX,tileY)





            nextZoomLevel=zoomLevel+1;
            [xExtent,yExtent]=terrain.internal.HeightmapTileReader.tileExtents(zoomLevel);
            [xExtentNext,yExtentNext]=terrain.internal.HeightmapTileReader.tileExtents(nextZoomLevel);


            swTileXNext=(tileX*xExtent)/xExtentNext;
            swTileYNext=(tileY*yExtent)/yExtentNext;



            [swData,swExists]=tiler.tileData(nextZoomLevel,swTileXNext,swTileYNext);
            [nwData,nwExists]=tiler.tileData(nextZoomLevel,swTileXNext,swTileYNext+1);
            [seData,seExists]=tiler.tileData(nextZoomLevel,swTileXNext+1,swTileYNext);
            [neData,neExists]=tiler.tileData(nextZoomLevel,swTileXNext+1,swTileYNext+1);


            tileData=[nwData,neData(:,2:end);swData(2:end,:),seData(2:end,2:end)];


            terrainData=imreduce(tileData);







            childrenByte=uint16(swExists*1+seExists*2+nwExists*4+neExists*8);
        end

        function[heightData,tileExists,childrenByte]=tileData(tiler,zoomLevel,tileX,tileY)



            tilePath=fullfile(tiler.WriteLocation,string(zoomLevel),...
            string(tileX),string(tileY)+tiler.TerrainTileExtension);

            tileExists=1;
            childrenByte=0;
            if~exist(tilePath,'file')
                heightData=zeros(terrain.internal.Tiler.TileSize);
                tileExists=0;
                return
            end

            [heightData,childrenByte]=terrain.internal.HeightmapTileReader.readHeightmapTile(tilePath);
        end
    end

    methods(Static,Hidden)
        function[terrainData,p]=parseAddCustomTerrainInputs(varargin)


            isRasterInput=ismatrix(varargin{1})&&(numel(varargin)>1)&&isscalar(varargin{2})&&...
            (isa(varargin{2},'map.rasterref.GeographicRasterReference')||isa(varargin{2},'map.rasterref.MapRasterReference'));
            if isRasterInput
                Z=varargin{1};
                R=varargin{2};
                terrainData=struct(...
                "IsFileSource",false,...
                "Source",{{Z,R}});
                varargin=varargin(3:end);
            else
                files=varargin{1};
                terrainData=struct(...
                "IsFileSource",true,...
                "Source",{files});
                varargin=varargin(2:end);
            end


            p=terrain.internal.Tiler.AddCustomTerrainInputParser;
            p.parse(varargin{:});


            if isRasterInput&&~p.Results.AllowAllGeographicRasterFormats
                error(message('MATLAB:InputParser:ParamMustBeChar'))
            end
        end

        function[lonX,latY]=tileMeshGrid(zoomLevel,tileX,tileY)


            [xExtent,yExtent]=terrain.internal.HeightmapTileReader.tileExtents(zoomLevel);


            minLon=-180+tileX*xExtent;
            maxLon=min(180,minLon+xExtent);


            minLat=-90+tileY*yExtent;
            maxLat=min(90,minLat+yExtent);


            tileSize=terrain.internal.Tiler.TileSize;
            latsv=linspace(maxLat,minLat,tileSize);
            lonsv=linspace(minLon,maxLon,tileSize);


            [lonX,latY]=meshgrid(lonsv,latsv);
        end
    end
end

function p=createAddCustomTerrainInputParser
    p=inputParser;
    p.addParameter('Attribution','');
    p.addParameter('WriteLocation',[]);
    p.addParameter('FillMissing',false);
    p.addParameter('MaxZoomLevel',[]);
    p.addParameter('ShowWaitbar',true);
    p.addParameter('AllowAllGeographicRasterFormats',false,@(x)isscalar(x)&&islogical(x));
    p.addParameter('HeightReference','geoid');
    p.addParameter('OutputHeightReference','ellipsoid');
end

function isval=isvalidwaitbar(hWaitbar)
    isval=~isempty(hWaitbar)&&isvalid(hWaitbar);
end

function tileCoordinates=tileCoordinatesForLocation(zoomLevel,lat,lon)


    lat=min(lat,89.999999);
    lon=min(lon,179.999999);




    [xExtent,yExtent]=terrain.internal.HeightmapTileReader.tileExtents(zoomLevel);
    tileX=floor((lon+180)/xExtent);
    tileY=floor((lat+90)/yExtent);
    tileCoordinates=[tileX,tileY];
end

function reducedData=imreduce(data)


    M=size(data,1);
    N=size(data,2);

    scaleFactor=0.5;
    outputSize=ceil([M,N]/2);
    kernel=makePiecewiseConstantFunction(...
    [3.5,2.5,1.5,0.5,-0.5,-1.5,-Inf],...
    [0.0,0.0625,0.25,0.375,0.25,0.0625,0.0]);
    kernelWidth=5;

    reducedData=imresize(data,scaleFactor,{kernel,kernelWidth},...
    'OutputSize',outputSize,'Antialiasing',false);
end

function fun=makePiecewiseConstantFunction(breakPoints,values)

    fun=@piecewiseConstantFunction;

    function y=piecewiseConstantFunction(x)
        y=zeros(size(x));
        for k=1:numel(x)
            yy=0;
            xx=x(k);
            for p=1:numel(breakPoints)
                if xx>=breakPoints(p)
                    yy=values(p);
                    break;
                end
            end
            y(k)=yy;
        end
    end
end
