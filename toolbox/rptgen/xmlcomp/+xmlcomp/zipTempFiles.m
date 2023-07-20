function zipfile=zipTempFiles(dest)













    if~exist(dest,'dir')
        xmlcomp.internal.error('engine:FolderNotFound',dest);
    end


    t=xmlcomp.internal.tempdirManager;
    if isempty(t.getCurrentTempdir)
        xmlcomp.internal.error('engine:NoTempFiles')
    end

    [~,zipfilename]=fileparts(t.getCurrentTempdir);
    zipfile=fullfile(dest,[zipfilename,'.zip']);
    zip(zipfile,t.getCurrentTempdir);

    fprintf('%s\n',xmlcomp.internal.message('engine:CreatedZipfile',zipfile));
