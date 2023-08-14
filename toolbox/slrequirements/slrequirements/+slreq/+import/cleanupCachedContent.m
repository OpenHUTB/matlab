function cleanupCachedContent(cacheDir,docName)








    htmlFileAny=rmidotnet.getCacheFilePath(cacheDir,docName,'ANY');
    htmlFilePattern=regexprep(htmlFileAny,'_\w+\.\w+$','_*');
    entries=dir(htmlFilePattern);
    if~isempty(entries)
        try


            rmdir(htmlFilePattern,'s');
        catch ME %#ok<NASGU>

        end
        delete(htmlFilePattern);
    end
end
