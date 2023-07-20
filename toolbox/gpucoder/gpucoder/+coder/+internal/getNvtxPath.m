function nvtxPath=getNvtxPath

    nvtxPath='';

    if ispc
        nvtxPath=getenv('NVTOOLSEXT_PATH');
    else
        llp=getenv('LD_LIBRARY_PATH');
        lnxLib='nvToolsExt';
        libName=[lnxLib,'.so'];
        libPaths=strsplit(llp,':');
        found=false;
        for idx=1:numel(libPaths)
            if found
                break;
            end
            listing=dir(libPaths{idx});
            for jdx=1:numel(listing)
                if contains(listing(jdx).name,libName)
                    found=true;
                    nvtxPath=libPaths{idx};
                    break;
                end
            end
        end
    end