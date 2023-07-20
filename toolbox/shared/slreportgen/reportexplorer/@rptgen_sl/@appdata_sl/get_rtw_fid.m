function fid=get_rtw_fid(adSL,mdlName)






    fid=-1;
    if~strcmp(get_param(0,'RtwLicensed'),'on')
        return;
    end

    uName=getenv('USER');
    if isempty(uName)
        uName='rptgen_rtw';
    else
        uName=[uName,'_rptgen_rtw'];
    end

    rtwDir=fullfile(tempdir,uName);
    rtwDirFile=java.io.File(rtwDir);

    if~rtwDirFile.isDirectory
        try
            ok=rtwDirFile.mkdirs;
        catch ME %#ok
            ok=false;
        end

        if ok
            rtwDirFile.deleteOnExit;
        else
            rtwDir=tempdir;
        end
    end

    rtwFile=fullfile(rtwDir,[mdlName,'.rtw']);

    if~any(strcmp(adSL.RtwCompiledModels,mdlName))
        rtwFileFile=java.io.File(rtwFile);
        if(rtwFileFile.exists&&~rtwFileFile.canWrite)
            rptgen.displayMessage(sprintf(getString(message('RptgenSL:rsl_appdata_sl:cannotWriteRTWFile')),rtwFile),2);
            return;
        end
        prevDir=pwd;
        cd(rtwDir);
        try
            rptgen.displayMessage(sprintf(getString(message('RptgenSL:rsl_appdata_sl:generatingRTWLabel')),mdlName),4);
            rtwgen(mdlName);

            ok=1;
        catch ME
            ok=0;
            rptgen.displayMessage(sprintf(getString(message('RptgenSL:rsl_appdata_sl:failedToGetRTWMsg')),mdlName),2);
            rptgen.displayMessage(ME.message,5);



        end
        cd(prevDir);



        rcm=adSL.RtwCompiledModels;
        rcm{end+1}=mdlName;
        adSL.RtwCompiledModels=rcm;

        if~ok
            return;
        end
    end

    fid=fopen(rtwFile);
