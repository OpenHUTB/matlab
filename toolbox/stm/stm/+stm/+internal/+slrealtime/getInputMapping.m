function out=getInputMapping(applicationPath,inputPath,loadApplicationFrom,targetName)


    try



        assert(loadApplicationFrom>0);

        mappingString='';
        if(loadApplicationFrom==2)

            if stm.internal.slrealtime.isTargetDefined(targetName)
                try
                    defaultTarget=stm.internal.slrealtime.connectToTarget(targetName);
                    if~isempty(targetName)&&~strcmpi(defaultTarget,targetName)
                        restoreTgt=onCleanup(@()restoreDefaultTarget(defaultTarget));
                    end
                catch
                    if isempty(targetName)
                        targetName='Default';
                    end
                    error(message('stm:realtime:UnableToConnectToTarget',targetName));
                end
            else
                error(message('stm:realtime:TargetUndefined',targetName));
            end

            tg=slrealtime;

            if(isempty(tg.getLastApplication))
                error(message('stm:realtime:NoApplicationLoadedOnTarget'));
            end
            applicationPath=tg.getApplicationFile(tg.getLastApplication);
            if(isempty(applicationPath))
                error(message('stm:realtime:NoApplicationLoadedOnTarget'));
            end
        end



        [applicationDirPath,applicationName,~]=fileparts(applicationPath);
        if(isempty(applicationDirPath))
            applicationDirPath='./';
        end

        currentDir=pwd;

        cd(applicationDirPath);

        try
            app_object=slrealtime.Application(applicationName);
            mappingString=app_object.getRootLevelInportMapping;
        catch me

            cd(currentDir);
            rethrow(me);
        end

        cd(currentDir);


        out.inputstring=mappingString;
        load(inputPath);
        try
            eval(sprintf('%s;',mappingString));
        catch me
            dataString='';


            matObj=matfile(inputPath);
            details=whos(matObj);
            if~isempty(details)
                loadedVariables={details.name};
                dataString=sprintf(' %s',loadedVariables{:});
            end

            m=message('stm:InputsView:InputDataMismatchRealTimeApplication',dataString,me.message);
            out.error=m.getString();

            out.inputstring=mappingString;
            out.status=4;
            return;
        end

        out.status=2;
    catch me

        out.error=me.message;

        out.inputstring=mappingString;
        out.status=4;
    end

end
