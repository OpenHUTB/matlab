function simrfV2_cachefit_imt(block,filename)






    if isempty(which(filename))
        fileInfo=dir(filename);
    else
        fileInfo=dir(which(filename));
    end
    if isempty(fileInfo)
        error(message('simrf:simrfV2errors:CannotOpenFile',filename))
    end

    cacheData=get_param(block,'UserData');
    cacheFilename=[];
    cacheTimestamp=[];
    if~isempty(cacheData)
        if isfield(cacheData,'filename')
            cacheFilename=cacheData.filename;
        end
        if isfield(cacheData,'timestamp')
            cacheTimestamp=cacheData.timestamp;
        end
    end

    if~strcmpi(cacheFilename,filename)||...
        (abs(fileInfo.datenum-cacheTimestamp)>datenum(0,0,0,0,0,4))||...
        (isfield(cacheData,'IMT')&&isfield(cacheData.IMT,'PowerRF'))
        simrfV2_readimtfile(filename,block);
    end

end