function filename=addCustomBasemapIcon(basemap)









    folder=fullfile(prefdir,"basemaps");
    filename=fullfile(folder,basemap+".png");

    if~exist(filename,"file")
        if~exist(folder,"dir")
            mkdir(folder)
        end

        try

            wstate=warning('off',...
            "MATLAB:graphics:maps:ShowingMissingTiles");
            cleanObj=onCleanup(@()warning(wstate));
            selector=matlab.graphics.chart.internal.maps.BaseLayerSelector;
            reader=selectReader(selector,basemap);
            A=readMapTile(reader,0,0,1);
            imwrite(A,filename,"png")
        catch

        end
    end
end
