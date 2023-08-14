function setStartupApp(this,app,varargin)




















    p=inputParser;
    isScalarLogical=@(x)islogical(x)&&isscalar(x);
    addParameter(p,'SkipInstall',false,isScalarLogical);
    parse(p,varargin{:});
    skipInstall=p.Results.SkipInstall;

    if(nargin<2)||isempty(app)
        this.throwError('slrealtime:target:emptyAppName');
    end
    validateattributes(app,{'char','string'},{'scalartext'});
    app=convertStringsToChars(app);
    [appPath,appName,~]=fileparts(app);

    try



        cmd=strcat("ls -ld ",this.StartupDirOnTarget);
        try
            out=this.executeCommand(cmd);
            if contains(out.Output,'root')
                this.throwError('slrealtime:target:removeStartupFolder',this.StartupDirOnTarget);
            end
        catch

        end



        if~skipInstall
            try
                this.install(app);
            catch ME
                if isempty(appPath)&&~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:target:appDoesNotExist')






                    try
                        this.executeCommand(strcat("ls ",this.appsDirOnTarget,"/",appName));
                    catch
                        rethrow(ME);
                    end
                else
                    rethrow(ME);
                end
            end
        else



            try
                this.executeCommand(strcat("ls ",this.appsDirOnTarget,"/",appName));
            catch
                this.throwError('slrealtime:target:appDoesNotExist');
            end
        end



        dirOnHost=tempname;
        mkdir(dirOnHost);
        fileOnHost=fullfile(dirOnHost,this.StartupFileName);
        fid=fopen(fileOnHost,'w');
        fwrite(fid,strcat("slrealtime load --AppName ",appName));
        fwrite(fid,newline);
        fwrite(fid,"slrealtime start ");
        fwrite(fid,newline);
        fclose(fid);

        cmd=strcat("if [ ! -d ",this.StartupDirOnTarget," ]; then mkdir -p ",this.StartupDirOnTarget,"; fi");
        this.executeCommand(cmd);

        fileOnTarget=strcat(this.StartupDirOnTarget,'/',this.StartupFileName);
        this.sendFile(fileOnHost,fileOnTarget);
        this.executeCommand(strcat("chmod 755 ",fileOnTarget));

        notify(this,'StartupAppChanged');

    catch ME
        this.throwError('slrealtime:target:setStartupAppError',appName,this.TargetSettings.name,ME.message);
    end

end
