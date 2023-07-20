function saveSlccCache(settingsChecksum,data)

    saveStatus='not saved';
    try
        isWritable=CGXE.Utils.isFolderWritable(cgxeprivate("get_cgxe_proj_root"));
        if isWritable

            cacheFilePath=getSlccCachePath(settingsChecksum);
            [cacheFolder,~,~]=fileparts(cacheFilePath);
            if~isfolder(cacheFolder)
                mkdir(cacheFolder);
            end


            save(cacheFilePath,'data');
            saveStatus='saved';
        end
    catch ex

        warning(['An exception occured while saving the parser cache. '...
        ,' Note: The parser cache was ',saveStatus,'.\n'...
        ,ex.getReport()...
        ]);
    end
end