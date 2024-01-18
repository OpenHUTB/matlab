function url=filepathToUrl(filePath)

    if exist(filePath,'file')==0
        rmiut.warnNoBacktrace('Slvnv:reqmgt:StorageMapper:FileNotExist',filePath);
        url=encodeSomeChars(['file://',strrep(filePath,'\','/')]);

        return;
    elseif~rmiut.isCompletePath(filePath)
        filePath=which(filePath);
    end

    if rmipref('ReportUseRelativePath')
        reqDocBase=rmipref('ReqDocPathBase');
        if~isempty(reqDocBase)
            url=relativePathUrl(filePath,reqDocBase);
        else
            url=relativePathUrl(filePath,pwd);
        end
    else
        url=absolutePathUrl(filePath);
    end

    url=encodeSomeChars(url);
end


function url=encodeSomeChars(url)
    url=strrep(url,'%','%25');
    url=strrep(url,'#','%23');
    url=strrep(url,' ','%20');
end


function url=relativePathUrl(filePath,refPath)
    [relPath,isRelative]=rmiut.relative_path(filePath,refPath);
    if isRelative
        url=relPath;
        if ispc
            url=strrep(url,filesep,'/');
        end
    else

        url=absolutePathUrl(filePath);
    end
end


function url=absolutePathUrl(filePath)
    if strncmp(filePath,'/',1)
        filePath=strrep(filePath,'\','/');
        url=['file://',filePath];
    elseif strncmp(filePath,'\\',2)
        filePath=strrep(filePath,'\','/');
        url=['file:///',filePath];
    elseif~isempty(regexpi(filePath,'^[a-z]:'))
        filePath=strrep(filePath,'\','/');
        url=['file://',filePath];
    else

        error('Cannot construct absolute path URL for %s',filePath);
    end
end

