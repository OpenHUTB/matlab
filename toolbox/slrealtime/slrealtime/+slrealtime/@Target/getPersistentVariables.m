function vars=getPersistentVariables(this)













    if~this.isConnected()
        this.connect();
    end

    try
        tmpDir=tempname;
        mkdir(tmpDir);
        dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));


        srcFile=strcat(this.HomeDir,'/persistent/PersistentVar.json');
        destFile=fullfile(tmpDir,'PersistentVar.json');
        if~this.isfile(srcFile)

            vars=[];
            return;
        end
        this.receiveFile(srcFile,destFile);

        text=fileread(destFile);
        try
            vars=jsondecode(text);
        catch ME
            slrealtime.internal.throw.ErrorWithCause('slrealtime:persistentVar:jsondecodeErr',ME);
        end
        vars=decodePerVars(vars);
    catch ME
        if isempty(ME.cause)
            this.throwError('slrealtime:persistentVar:getPersistentVariablesErr',this.TargetSettings.name,ME.message);
        else
            this.throwErrorWithCause('slrealtime:persistentVar:getPersistentVariablesErr',ME.cause{1},this.TargetSettings.name,ME.message);
        end
    end
end
