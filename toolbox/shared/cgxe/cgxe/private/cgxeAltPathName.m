function altPath=cgxeAltPathName(path)
    if ispc
        altPaths=true;
        ignoreErrors=true;
        altPath=getPathName(path,altPaths,ignoreErrors);
    else
        altPath=strrep(path,' ','\ ');
    end
end