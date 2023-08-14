function[cachePath]=getSlccCachePath(settingsChecksum)


    if nargin<1
        ex=MException('SlccCache:InputError','No settings checksum specified');
        throw(ex);
    end

    projRootDir=cgxeprivate('get_cgxe_proj_root');
    cachePath=fullfile(projRootDir,'slprj','_slcc',settingsChecksum,'parser_cache.mat');
