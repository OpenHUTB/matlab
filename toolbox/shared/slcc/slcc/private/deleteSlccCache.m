function[deleted]=deleteSlccCache(settingsChecksum)


    try
        if nargin<1
            ex=MException('SlccCache:InputError','No settings checksum specified');
            throw(ex);
        end

        cachePath=getSlccCachePath(settingsChecksum);

        deleted=false;
        if isfile(cachePath)
            delete(cachePath);
            deleted=true;
        end
    catch ex

        warning(['An exception occured while deleting the parser cache.\n'...
        ,ex.getReport()]...
        );
    end