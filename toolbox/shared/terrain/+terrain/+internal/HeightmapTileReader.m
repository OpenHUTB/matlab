classdef(Sealed,Hidden)HeightmapTileReader<terrain.internal.TerrainTileReader




    properties
ZoomLevel
    end

    properties(SetAccess=private)
TileLatitudeExtents
TileLongitudeExtents
    end

    properties(SetAccess=immutable)
Location
IsURLLocation
    end

    properties(Hidden)
DownloadFileWriter
    end

    properties(Constant,Hidden)
        TileSize=65
        TerrainTileExtension=".terrain"
        MinNumFilesPerRetry=1
        MaxNumThreads=12
    end

    properties(Hidden,SetAccess=private)
UsingConnector
    end

    methods
        function reader=HeightmapTileReader(loc,varargin)
            loc=string(loc);


            p=inputParser;
            p.addParameter('IsURLLocation',true);
            p.addParameter('ZoomLevel',10);
            p.parse(varargin{:});
            zoomLevel=p.Results.ZoomLevel;
            isURLLocation=p.Results.IsURLLocation;


            if isURLLocation
                usingConnector=loc.startsWith("/");
                if usingConnector
                    loc=""+connector.getBaseUrl+loc.extractAfter(1);
                end
            else
                usingConnector=false;
            end


            reader.Location=loc;
            reader.IsURLLocation=isURLLocation;
            reader.UsingConnector=usingConnector;
            reader.ZoomLevel=zoomLevel;
        end

        function set.ZoomLevel(reader,v)
            reader.ZoomLevel=v;
            updateTileExtents(reader);
        end

        function updateTileExtents(reader)
            zoomLevel=reader.ZoomLevel;
            [w,h]=reader.tileExtents(zoomLevel);
            reader.TileLongitudeExtents=w;
            reader.TileLatitudeExtents=h;
        end

        function[tileCoordinates,ind]=findTiles(reader,latsq,lonsq)


            latsq=latsq(:);
            lonsq=lonsq(:);







            ny=int32(180/reader.TileLatitudeExtents);
            nx=int32(360/reader.TileLongitudeExtents);




            w=reader.TileLongitudeExtents;
            tileX=int32(floor((lonsq+180)/w));
            tileX=min(tileX,nx-1);

            h=reader.TileLatitudeExtents;
            tileY=int32(floor((latsq+90)/h));
            tileY=min(tileY,ny-1);



            [tileCoordinates,~,ind]=unique([tileX,tileY],'rows');
        end

        function[terrainData,latvs,lonvs]=readTiles(reader,tileCoordinates)



            zoomLevel=reader.ZoomLevel;
            tileX=tileCoordinates(:,1);
            tileY=tileCoordinates(:,2);
            tileTokens="z"+zoomLevel+"x"+tileX+"y"+tileY;


            ext=reader.TerrainTileExtension;
            tdir=tempname;
            mkdir(tdir);
            cleanupTempDir=onCleanup(@()deleteFolder(tdir));
            unzippedFileNames=fullfile(tdir,tileTokens);
            fullFileNames=unzippedFileNames+ext;






            timeout=30;

            if reader.IsURLLocation

                baseurls=reader.Location+"/"+zoomLevel+"/"+...
                tileX+"/"+tileY+ext;


                if isempty(reader.DownloadFileWriter)
                    reader.DownloadFileWriter=matlab.internal.asynchttpsave.AsyncHTTPContentFileWriter;
                end
                writer=reader.DownloadFileWriter;

                writerCleanup=onCleanup(@()cancelAndCloseChannel(writer));
                usingconnector=reader.UsingConnector;
                if usingconnector



                    urls=arrayfun(@(x)string(connector.getUrl(x)),baseurls);
                    writer.Options.CertificateFilename=connector.getCertificateLocation;
                else
                    urls=baseurls;
                end
                writer.Options.Timeout=timeout;
                writer.Options.ContentType='binary';
                writer.URL=urls;
                writer.Filename=fullFileNames;
                writer.NumThreads=min([writer.MaxNumThreads,numel(fullFileNames),reader.MaxNumThreads]);



                numURLsNeededLastRun=numel(urls);
                finishedDownloadAttempts=false;
                while~finishedDownloadAttempts
                    try
                        writeContentToFilesAndBlock(writer,timeout)
                        finishedDownloadAttempts=true;
                    catch e

                        [urlsNeeded,filesNeeded]=...
                        getMissingFileNames(tdir,fullFileNames,...
                        baseurls,usingconnector);
                        numFilesObtainedLastRun=numURLsNeededLastRun-numel(urlsNeeded);
                        if(isempty(urlsNeeded))



                            finishedDownloadAttempts=true;
                        elseif(numFilesObtainedLastRun<reader.MinNumFilesPerRetry)


                            throw(e);
                        else
                            numURLsNeededLastRun=numel(urlsNeeded);
                            writer.URL=urlsNeeded;
                            writer.Filename=filesNeeded;
                        end
                    end
                end
                waitForFilesExist(tdir,fullFileNames,timeout);
            else

                fullFilePaths=fullfile(reader.Location,...
                string(zoomLevel),string(tileX),string(tileY)+ext);


                arrayfun(@copyfile,fullFilePaths,fullFileNames);
                waitForFilesExist(tdir,fullFileNames,timeout);
            end



            gunzip(tdir);
            waitForFilesExist(tdir,unzippedFileNames,timeout);


            numTiles=size(unzippedFileNames,1);
            terrainData=cell(numTiles,1);
            latvs=cell(numTiles,1);
            lonvs=cell(numTiles,1);


            for tileInd=1:numTiles
                tileTerrainData=reader.readHeightmapTile(unzippedFileNames(tileInd));


                terrainData{tileInd}=flipud(tileTerrainData);

                tileXY=[tileX(tileInd),tileY(tileInd)];
                [latvs{tileInd},lonvs{tileInd}]=reader.tileDataGridVectors(tileXY);
            end
        end

        function keys=tileKeys(~,tileCoordinates)


            keys="x"+tileCoordinates(:,1)+"y"+tileCoordinates(:,2);
        end

        function[latv,lonv]=tileDataGridVectors(reader,tileCoordinates)


            tileSize=reader.TileSize;
            tileX=double(tileCoordinates(:,1));
            tileY=double(tileCoordinates(:,2));



            w=reader.TileLongitudeExtents;
            h=reader.TileLatitudeExtents;
            tileSouth=-90+tileY*h;
            tileNorth=tileSouth+h;
            tileWest=-180+tileX*w;
            tileEast=tileWest+w;



            latv=linspace(tileSouth,tileNorth,tileSize);
            lonv=linspace(tileWest,tileEast,tileSize);
        end
    end

    methods(Static)
        function[heightData,childrenByte]=readHeightmapTile(file)




            fid=fopen(file);
            cesiumTerrainData=fread(fid,inf,'uint16',0,'l');
            fclose(fid);


            childrenByte=cesiumTerrainData(end);
            cesiumTerrainData(end)=[];


            heightData=-1000+.2*cesiumTerrainData;
            tileSize=terrain.internal.HeightmapTileReader.TileSize;
            heightData=reshape(heightData,tileSize,tileSize).';
        end

        function writeHeightmapTile(file,terrainData,childrenByte)




            fileData=(terrainData+1000)/.2;
            fileData=fileData';
            fileData=uint16(fileData(:));


            fileData=[fileData;childrenByte];


            fid=fopen(file,'w');
            fwrite(fid,fileData,'uint16',0,'l');
            fclose(fid);
        end

        function[nx,ny]=numXYTiles(zoomLevel)




            nx=2^(zoomLevel+1);
            ny=2^zoomLevel;
        end

        function[w,h]=tileExtents(zoomLevel)



            [nx,ny]=terrain.internal.HeightmapTileReader.numXYTiles(zoomLevel);
            w=360/nx;
            h=180/ny;
        end
    end
end

function waitForFilesExist(tdir,fileNames,timeout)

    timeStep=0.01;
    timeoutNumSteps=timeout/timeStep;
    numSteps=0;
    while~all(arrayfun(@exist,fileNames))&&(numSteps<timeoutNumSteps)
        fschange(tdir);
        pause(0.01);
        numSteps=numSteps+1;
    end
end

function[URLs,fileNames]=getMissingFileNames(downloadDir,desiredfiles,...
    baseurls,usingconnector)

    filesDownloaded=dir(downloadDir);
    fileIndsNeeded=~ismember(desiredfiles,fullfile(downloadDir,string({filesDownloaded.name})));




    if(usingconnector)
        urlsNeeded=arrayfun(@(x)string(connector.getUrl(x)),baseurls);
    else
        urlsNeeded=baseurls;
    end
    URLs=urlsNeeded(fileIndsNeeded);
    fileNames=desiredfiles(fileIndsNeeded);
end

function deleteFolder(folder)


    try

        if exist(folder,'dir')
            rmdir(folder,'s')
        end
    catch
    end
end
