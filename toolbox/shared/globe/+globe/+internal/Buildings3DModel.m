classdef(Sealed,Hidden)Buildings3DModel<globe.internal.Geographic3DModel




    properties
BuildingsArray
BuildingsTerrainTriangulation
        BuildingsLimits(1,4)double
        BuildingsCenter(1,3)double
    end

    methods
        function bldgsModel=Buildings3DModel(bldgsFileName,terrainSource)


            bldgsFilePath=validateBuildingsFile(bldgsFileName);
            bldgs=readBuildings(bldgsFilePath,bldgsFileName);
            [bldgsTri,bldgsTerrainTri,bldgsLimits,bldgsCenter]=...
            georeferenceBuildingsInTerrain(bldgs,bldgsFileName,terrainSource);


            bldgsModel=bldgsModel@globe.internal.Geographic3DModel(bldgsTri);


            bldgsModel.BuildingsArray=bldgs;
            bldgsModel.BuildingsTerrainTriangulation=bldgsTerrainTri;
            bldgsModel.BuildingsLimits=bldgsLimits;
            bldgsModel.BuildingsCenter=bldgsCenter;
        end
    end
end

function bldgsFilePath=validateBuildingsFile(bldgsFileName)


    bldgsFilePath=which(bldgsFileName);
    if isempty(bldgsFilePath)


        bldgsFilePath=bldgsFileName;
        if exist(bldgsFilePath,'file')~=2
            error(message('shared_globe:viewer:UnableToLoadBuildingsFile',bldgsFileName));
        end
    end
end

function bldgs=readBuildings(bldgsFilePath,bldgsFileName)



    try
        reader=matlabshared.maps.internal.OpenStreetMapReader(bldgsFilePath);
    catch e
        error(message('shared_globe:viewer:UnableToReadBuildingsFile',bldgsFileName));
    end


    builder=matlabshared.maps.internal.OSMBuilder(reader);
    bldgs=builder.build;


    if isempty(bldgs)
        error(message('shared_globe:viewer:NoBuildingsData',bldgsFileName));
    end
end

function[bldgsTri,bldgsTerrainTri,bldgsLimits,bldgsCenter]=georeferenceBuildingsInTerrain(allBldgs,bldgsFileName,terrainSource)



    if strcmp(terrainSource,'none')||isGlobalTerrain(terrainSource)

        bldgs=allBldgs;
    else
        bldgs=[];
        for k=1:numel(allBldgs)
            testBldg=allBldgs(k);
            footprint=testBldg.FootprintLatitudeLongitude;
            if~any(terrainSource.isOutOfRange(footprint(:,1),footprint(:,2)))
                bldgs=[bldgs;testBldg];
            end
        end


        if isempty(bldgs)
            error(message('shared_globe:viewer:NoBuildingsDataInTerrainRegion',...
            bldgsFileName,terrainSource.Name));
        end
    end


    if isempty(bldgs)
        return
    end


    footprints=[];
    for k=1:numel(bldgs)
        footprints=[footprints;bldgs(k).FootprintLatitudeLongitude];%#ok<*AGROW>
    end
    [S,L]=bounds(footprints);
    latlim=[S(1),L(1)];
    lonlim=[S(2),L(2)];
    lat0=mean(latlim);
    lon0=mean(lonlim);
    bldgsLimits=[latlim,lonlim];


    if strcmp(terrainSource,'none')||strcmpi(terrainSource.HeightReference,'ellipsoid')
        reference='ellipsoid';
    else
        reference='geoid';
    end
    z0=terrain.internal.TerrainSource.queryTerrain(terrainSource,[lat0,lon0],reference);


    tris={};
    for k=1:numel(bldgs)
        bldg=bldgs(k);


        if~strcmp(terrainSource,'none')

            bldgCenter=bldg.Centroid;
            bldgFootprint=bldg.FootprintLatitudeLongitude;
            qlats=[bldgCenter(1);bldgFootprint(:,1)];
            qlons=[bldgCenter(2);bldgFootprint(:,2)];
            bldgElevation=terrain.internal.TerrainSource.queryTerrain(...
            terrainSource,[qlats,qlons],reference);
            bldgCenterElevation=bldgElevation(1);





            offset=1;
            [minElevation,maxElevation]=bounds(bldgElevation(2:end));
            bldgTerrainGap=maxElevation-minElevation+offset;
        else

            bldgCenterElevation=0;
            bldgTerrainGap=0;
        end


        bldgTri=triangulation(bldg);



        bldgEnuTri=enuTriangulation(lat0,lon0,z0,bldgTri,bldgCenterElevation,bldgTerrainGap);
        tris=[tris;bldgEnuTri];
    end


    bldgsTri=terrain.internal.TerrainSource.combineTriangulations(tris);
    bldgsTri=terrain.internal.TerrainSource.cleanUpTriangulation(bldgsTri);





    terrainres=terrain.internal.TerrainSource.MaxBuildingsTerrainTriangulationResolution;
    terrainTri=terrain.internal.TerrainSource.terrainGridTriangulation(...
    terrainSource,lat0,lon0,z0,latlim,lonlim,terrainres);

    bldgsTerrainTri=terrain.internal.TerrainSource.combineTriangulations({bldgsTri,terrainTri});



    bldgsCenter=[lat0,lon0,z0];
end

function enuTris=enuTriangulation(lat0,lon0,h0,tris,hcenter,hgap)


    enuTris={};



    if~iscell(tris)
        tris={tris};
    end

    for triInd=1:numel(tris)
        tri=tris{triInd};
        if iscell(tri)
            bldgEnuTri=enuTriangulation(lat0,lon0,h0,tri,hcenter,hgap);
        else


            P=tri.Points;
            Pbottomrows=(P(:,3)==0);
            P(Pbottomrows,:)=P(Pbottomrows,:)+[0,0,-hgap];



            P(:,3)=P(:,3)+hcenter;



            [x,y,z]=rfprop.internal.MapUtils.geodetic2enu(...
            lat0,lon0,h0,P(:,2),P(:,1),P(:,3));


            bldgEnuTri={triangulation(tri.ConnectivityList,[x,y,z])};
        end
        enuTris=[enuTris;bldgEnuTri];
    end
end
