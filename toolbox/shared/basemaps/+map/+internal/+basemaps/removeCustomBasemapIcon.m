function removeCustomBasemapIcon(basemap)









    folder=fullfile(prefdir,"basemaps");
    filename=fullfile(folder,basemap+".png");

    if exist(filename,"file")
        try
            delete(filename)


            if isempty(dir(fullfile(folder,'*.png')))
                rmdir(folder)
            end
        catch
        end
    end
end
