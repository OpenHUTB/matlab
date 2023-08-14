function Z=readterrain(R,dataSource,heightReference)
















    if matches(R.CoordinateSystemType,"geographic")
        [lat,lon]=geographicGrid(R);
    else
        [x,y]=worldGrid(R);
        proj=R.ProjectedCRS;
        [lat,lon]=projinv(proj,x,y);
    end




    terrainSource=terrain.internal.TerrainSource.createFromSettings(...
    dataSource,true);


    maxNumTiles=1024;
    lon=wrapTo180(lon);
    zoomLevel=terrain.internal.TerrainSource.terrainZoomLevel(...
    terrainSource,lat,lon,maxNumTiles);


    Z=query(terrainSource,lat,lon,"ZoomLevel",zoomLevel,...
    "OutputHeightReference",heightReference);

    if strcmp(heightReference,'geoid')


        Z=terrainSource.snapMeanSeaLevel(Z);
    end

end
