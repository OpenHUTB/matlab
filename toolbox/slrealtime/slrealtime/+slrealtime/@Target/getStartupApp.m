function appName=getStartupApp(this)











    appName=[];%#ok

    try
        fileOnTarget=strcat(this.StartupDirOnTarget,'/',this.StartupFileName);
        if~this.isfile(fileOnTarget)
            appName=[];
            return;
        end

        dirOnHost=tempname;
        mkdir(dirOnHost);
        fileOnHost=fullfile(dirOnHost,this.StartupFileName);
        this.receiveFile(fileOnTarget,fileOnHost);

        fid=fopen(fileOnHost);
        c=onCleanup(@()fclose(fid));

        str=textscan(fid,'%s %s %s %s');
        str=str{4};
        while iscell(str)
            str=str{1};
        end
        appName=str;
    catch ME
        appName=[];
        this.throwError('slrealtime:target:getStartupAppError',this.TargetSettings.name,ME.message);
    end

end
