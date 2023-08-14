function version=getVersion(versionFile,pattern)




    versionFile=convertStringsToChars(versionFile);
    pattern=convertStringsToChars(pattern);

    version='';
    if exist(versionFile,'file')
        fid=fopen(versionFile);
        if(fid<0)
            warning(message('ERRORHANDLER:utils:FileOpenError',versionFile));
            return;
        end
        versionContent=fread(fid,32768,'*char').';
        fclose(fid);
        verInfo=regexp(versionContent,pattern,'tokens','once');
        if~isempty(verInfo)
            version=regexprep(verInfo{1},'_','.');

            version=regexprep(version,'\.+$','');
        end
    end

