classdef(Abstract,Hidden)ScatteredTileReader<terrain.internal.TerrainTileReader









    properties(SetAccess=immutable)
        LatitudeLimits(1,2)double
        LongitudeLimits(1,2)double
        IntrinsicResolution(1,1)double
        FillMissing(1,1)logical=false
        MissingDataReplaceValue double=NaN
        SingleTileData double
SingleTileReference
    end

    properties(Access=private)
        FileNames string
        FileLatitudeLimits(:,2)double
        FileLongitudeLimits(:,2)double
    end


    methods(Abstract,Access=protected)
        [Z,R,resampled]=readTerrain(reader,varargin)
        [latv,lonv]=tileDataGridVectors(reader,R)
    end

    methods
        function reader=ScatteredTileReader(terrainData,fillMissing,missingDataReplaceValue)



            if nargin>1
                reader.FillMissing=fillMissing;
            end
            if nargin>2
                reader.MissingDataReplaceValue=missingDataReplaceValue;
            end



            if terrainData.IsFileSource
                files=string(terrainData.Source);
            else

                files="";
            end
            numfiles=numel(files);


            tileMinResolutions=zeros(numfiles,1);
            latlims=zeros(numfiles,2);
            lonlims=zeros(numfiles,2);
            anyPreviousResampled=false;
            for fileInd=1:numfiles
                if terrainData.IsFileSource
                    fileTerrainData=struct(...
                    "IsFileSource",true,...
                    "Source",files(fileInd));
                else
                    fileTerrainData=terrainData;
                end
                [Z,R,resampled]=reader.readTerrain(fileTerrainData);


                if anyPreviousResampled&&resampled
                    error(message("shared_terrain:terrain:MultipleFileReferenceUnsupported"))
                end
                anyPreviousResampled=anyPreviousResampled||resampled;


                if numfiles==1
                    reader.SingleTileData=Z;
                    reader.SingleTileReference=R;
                end


                latlims(fileInd,:)=R.LatitudeLimits;
                lonlims(fileInd,:)=R.LongitudeLimits;


                tileSize=R.RasterSize;
                tileLatRes=R.RasterExtentInLatitude/(tileSize(1)-1);
                tileLonRes=R.RasterExtentInLongitude/(tileSize(2)-1);
                tileMinResolutions(fileInd)=min([tileLatRes,tileLonRes]);
            end


            if numfiles>1
                terrain.internal.ScatteredTileReader.validateTileRegions(latlims,lonlims,reader.FillMissing)
            end


            reader.FileLatitudeLimits=latlims;
            reader.FileLongitudeLimits=lonlims;
            reader.FileNames=files;
            reader.LatitudeLimits=[min(latlims(:,1)),max(latlims(:,2))];
            reader.LongitudeLimits=[min(lonlims(:,1)),max(lonlims(:,2))];
            reader.IntrinsicResolution=min(tileMinResolutions)*3600;
        end

        function[tileCoordinates,ind]=findTiles(reader,latsq,lonsq)



            tileLatLim=reader.FileLatitudeLimits;
            tileLonLim=reader.FileLongitudeLimits;
            tileLatMins=tileLatLim(:,1);
            tileLatMaxs=tileLatLim(:,2);
            tileLonMins=tileLonLim(:,1);
            tileLonMaxs=tileLonLim(:,2);




            numLocations=numel(latsq);
            tileInds=zeros(numLocations,1);
            for qind=1:numLocations
                latq=latsq(qind);
                lonq=lonsq(qind);
                isOnTile=latq>=tileLatMins&latq<=tileLatMaxs&...
                lonq>=tileLonMins&lonq<=tileLonMaxs;
                tileInd=find(isOnTile,1);

                if isempty(tileInd)

                    tileInds(qind)=0;
                else
                    tileInds(qind)=tileInd;
                end
            end



            [tileCoordinates,~,ind]=unique(tileInds);
        end

        function[terrainData,latvs,lonvs]=readTiles(reader,tileCoordinates)



            numTiles=numel(tileCoordinates);
            terrainData=cell(numTiles,1);
            latvs=cell(numTiles,1);
            lonvs=cell(numTiles,1);



            if reader.FillMissing
                outOfBoundsValue=0;
            else
                outOfBoundsValue=NaN;
            end


            fileNames=reader.FileNames;
            for tileInd=1:numTiles
                coords=tileCoordinates(tileInd);
                if coords==0
                    file="";
                else
                    file=fileNames(coords);
                end


                if coords==0
                    Z=outOfBoundsValue;
                    latv=NaN;
                    lonv=NaN;
                else

                    if numel(fileNames)==1
                        Z=reader.SingleTileData;
                        R=reader.SingleTileReference;
                    else
                        fileTerrainData=struct(...
                        "IsFileSource",true,...
                        "Source",file);
                        [Z,R]=reader.readTerrain(fileTerrainData);
                    end


                    [latv,lonv]=tileDataGridVectors(reader,R);
                end


                terrainData{tileInd}=Z;
                latvs{tileInd}=latv;
                lonvs{tileInd}=lonv;
            end
        end

        function keys=tileKeys(~,tileCoordinates)


            keys="file"+tileCoordinates(:);
        end
    end

    methods(Static,Hidden)
        function validateTileRegions(latlims,lonlims,fillMissing)



            fileShapes=polyshape.empty;
            fileShapesForOverlaps=polyshape.empty;
            for k=1:size(latlims,1)
                latlim=latlims(k,:);
                lonlim=lonlims(k,:);
                polyx=[lonlim(1),lonlim(1),lonlim(2),lonlim(2)];
                polyy=[latlim(1),latlim(2),latlim(2),latlim(1)];
                fileShapes=[fileShapes,polyshape(polyx,polyy)];%#ok<AGROW>



                overlapTol=0.01;
                latlim=latlim+[1,-1]*(overlapTol*diff(latlim));
                lonlim=lonlim+[1,-1]*(overlapTol*diff(lonlim));
                polyx=lonlim(1,[1,1,2,2]);
                polyy=latlim(1,[1,2,2,1]);
                fileShapesForOverlaps=[fileShapesForOverlaps,polyshape(polyx,polyy)];%#ok<AGROW>
            end




            fileOverlaps=overlaps(fileShapesForOverlaps)&~eye(numel(fileShapesForOverlaps));
            assert(~any(fileOverlaps,'all'),...
            message('shared_terrain:terrain:NonuniqueFileRegion'))


            if~fillMissing
                filesCombinedShape=rmslivers(union(fileShapes),0.01);
                if(length(filesCombinedShape.Vertices)>4)
                    error(message('shared_terrain:terrain:IncompleteFileRegion'));
                end
            end
        end
    end
end