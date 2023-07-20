function setPersistentVariables(this,vars)






















    if~(isempty(vars)||isstruct(vars))
        this.throwErrorAsCaller('slrealtime:persistentVar:inputArgErr');
    end

    if~this.isConnected()
        this.connect;
    end

    if this.isLoaded()
        this.throwErrorAsCaller('slrealtime:persistentVar:setErrAppLoaded');
    end

    try
        tmpDir=tempname;
        mkdir(tmpDir);
        dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));
        hostFile=fullfile(tmpDir,'PersistentVar.json');


        persistDir=strcat(this.HomeDir,'/persistent');
        cmd=strcat("if [ ! -d ",persistDir," ]; then mkdir -p ",persistDir,"; fi");
        this.executeCommand(cmd);
        targetFile=strcat(persistDir,'/PersistentVar.json');

        if isempty(vars)
            varsEncoded=[];
        else

            if~this.isfile(targetFile)

                oldRawVars=[];
            else
                this.receiveFile(targetFile,hostFile);
                text=fileread(hostFile);
                try
                    oldRawVars=jsondecode(text);
                catch ME
                    slrealtime.internal.throw.ErrorWithCause('slrealtime:persistentVar:jsondecodeErr',ME);
                end
            end
            varsEncoded=encodePerVars(vars,oldRawVars);
        end

        str=jsonencode(varsEncoded);
        if exist(hostFile,'file')
            delete(hostFile);
        end
        f=fopen(hostFile,'w');
        fwrite(f,str);
        fclose(f);


        this.sendFile(hostFile,targetFile);
    catch ME
        if isempty(ME.cause)
            this.throwError('slrealtime:persistentVar:setPersistentVariablesErr',this.TargetSettings.name,ME.message);
        else
            this.throwErrorWithCause('slrealtime:persistentVar:setPersistentVariablesErr',ME.cause{1},this.TargetSettings.name,ME.message);
        end
    end
end
