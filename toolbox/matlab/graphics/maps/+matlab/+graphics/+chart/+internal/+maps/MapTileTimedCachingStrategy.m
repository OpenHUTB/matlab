
































classdef MapTileTimedCachingStrategy<matlab.graphics.chart.internal.maps.MapTileCachingStrategy
    properties











        MaxNumDaysInCache double=30










        MaxNumFilesInCache double=4000
    end

    properties(Dependent)







TopLevelFolder
    end

    properties(Access=private,Dependent)

        Username string


UserIsUnknown
    end


    properties(Access=private)

        pTopLevelFolder string


        pUsername string=string.empty
    end


    methods
        function cache=MapTileTimedCachingStrategy(varargin)









            cache=cache@matlab.graphics.chart.internal.maps.MapTileCachingStrategy(varargin{:});
        end


        function delete(cache)





            if cache.UserIsUnknown


                deleteFolder(cache,cache.TopLevelFolder)
            else
                deleteExpiredCache(cache)
            end
        end


        function deleteExpiredCache(cache)






            folder=char(cache.CacheFolder);
            if~isempty(folder)
                maxNumDaysInCache=cache.MaxNumDaysInCache;
                files=dir([folder,'/**']);
                diagnosticsIsEnabled=cache.EnableDiagnostics;



                if~isempty(files)
                    dirIndex=[files.isdir];
                    files(dirIndex)=[];


                    filesDatenum=datenum([files.datenum]);
                    [filesDatenum,index]=sort(filesDatenum);
                    files=files(index);
                    timeDiff=now-filesDatenum;
                    filesToDeleteIndex=timeDiff>=maxNumDaysInCache;
                    filesToDelete=files(filesToDeleteIndex);
                    deleteFiles(filesToDelete,diagnosticsIsEnabled)



                    maxNumFilesInCache=cache.MaxNumFilesInCache;
                    filesToKeep=files(~filesToDeleteIndex);
                    if length(filesToKeep)>maxNumFilesInCache
                        numFilesToDelete=length(filesToKeep)-maxNumFilesInCache;
                        filesToDelete=filesToKeep(1:numFilesToDelete);
                        deleteFiles(filesToDelete,diagnosticsIsEnabled)
                    end
                end
            end
        end


        function folder=get.TopLevelFolder(cache)
            if isempty(cache.pTopLevelFolder)
                folder=getDefaultTopLevelFolder(cache.Username);
            else
                folder=cache.pTopLevelFolder;
            end
        end


        function set.TopLevelFolder(cache,folder)
            cache.CacheFolder=replace(cache.CacheFolder,cache.TopLevelFolder,folder);
            if~isempty(cache.TileSetMetadata)&&~isempty(cache.TileSetMetadata.MapTileCacheLocation)
                ploc=cache.TileSetMetadata.MapTileCacheLocation.ParameterizedLocation;
                ploc=replace(ploc,cache.TopLevelFolder,folder);
                cache.TileSetMetadata.MapTileCacheLocation.ParameterizedLocation=ploc;
            end
            cache.pTopLevelFolder=folder;
        end

        function username=get.Username(cache)
            if isempty(cache.pUsername)
                if ispc
                    username=getenv('USERNAME');
                else
                    username=getenv('USER');
                end
                cache.pUsername=username;
            else
                username=cache.pUsername;
            end
        end


        function userIsUnknown=get.UserIsUnknown(cache)
            userIsUnknown=strlength(cache.Username)==0;
        end
    end


    methods(Access=protected)
        function mapTileCacheLocation=computeMapTileURLCacheLocation(cache)








            if isempty(cache.CacheFolder)
                cache.CacheFolder=cache.TopLevelFolder;
            end

            mapTileCacheLocation=...
            matlab.graphics.chart.internal.maps.MapTileLocation(cache.CacheFolder);
        end


        function preprocessAndSetTileSetMetadata(cache,meta)








            cacheLocation=meta.MapTileCacheLocation;
            if~isempty(cacheLocation)&&startsWith(cacheLocation.ParameterizedLocation,"file://")


                plocation=cacheLocation.ParameterizedLocation;
                topLevelFolder=cache.TopLevelFolder+filesep;
                plocation=replace(plocation,"file://",topLevelFolder);
                if contains(plocation,"$")

                    cacheLocation.ParameterizedLocation=plocation;
                    meta.MapTileCacheLocation=cacheLocation;
                    cache.CacheFolder=extractBefore(plocation,'$');
                else


                    meta.MapTileCacheLocation=...
                    matlab.graphics.chart.internal.maps.MapTileLocation(plocation);
                    cache.CacheFolder=plocation;
                end
            end
            preprocessAndSetTileSetMetadata@matlab.graphics.chart.internal.maps.MapTileCachingStrategy(cache,meta);
        end
    end
end


function deleteFiles(filesToDelete,diagnosticsIsEnabled)






    if~isempty(filesToDelete)
        folders=string({filesToDelete.folder});
        names=string({filesToDelete.name});
        filenames=folders'+filesep+names';

        for k=1:length(filenames)
            filename=filenames{k};
            if diagnosticsIsEnabled
                fprintf('Deleting %s\n',filename)
            end
            try
                delete(filename)
            catch
            end
        end
    end
end


function folder=getDefaultTopLevelFolder(username)







    if isempty(username)
        username=replace(tempname,tempdir,'');
    end

    release="R"+version('-release');
    username="matlab"+"_"+username;
    folder=fullfile(tempdir,username,release);
end
