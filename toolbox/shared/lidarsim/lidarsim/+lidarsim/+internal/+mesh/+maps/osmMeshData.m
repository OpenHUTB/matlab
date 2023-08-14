function[v,f]=osmMeshData(osmFile,coords)

    [filepath,name]=fileparts(osmFile);

    fileName=strcat(name,'.osm');

    if isempty(filepath)
        file=which(fileName);
    else
        file=fullfile(filepath,fileName);
    end
    reader=matlabshared.maps.internal.OpenStreetMapReader(file);


    builder=matlabshared.maps.internal.OSMBuilder(reader);


    buildings=builder.build();


    footprints=zeros(0,2);

    numBuildings=numel(buildings);


    if numBuildings==0
        v=zeros(0,3);
        f=zeros(0,3);
        return;
    end


    mesh=extendedObjectMesh(zeros(0,3),zeros(0,3));

    for i=1:numBuildings
        thisBuilding=buildings(i);
        footprints=[footprints;thisBuilding.FootprintLatitudeLongitude];%#ok<AGROW>
        thisMesh=convertBuildingToMesh(buildings(i));
        mesh=join(mesh,thisMesh);
    end


    [minLatLong,maxLatLong]=bounds(footprints);
    lat0=(minLatLong(1)+maxLatLong(1))/2;
    long0=(minLatLong(2)+maxLatLong(2))/2;
    h0=0;


    mesh=convertToEnuCoordinates(mesh,lat0,long0,h0);


    v=mesh.Vertices;
    f=mesh.Faces;


    [v,f]=lidarsim.internal.mesh.utilities.removeDegenerateFaces(v,f);


    if nargin==2&&strcmpi(coords,'ned')
        vEnu=v;
        v(:,1)=vEnu(:,2);
        v(:,2)=vEnu(:,1);
        v(:,3)=-vEnu(:,3);
    end
end