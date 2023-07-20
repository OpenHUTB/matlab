function doPostSetup(hObj,version)



    hObj.version=version;
    if strcmp(version,'on')
        hObj.AutoUpdate='off';
    end

end
