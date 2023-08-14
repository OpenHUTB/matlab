function runTable=targetLogData(tg)











    runs=[];
    runTable=table;


    dl=locGetAppsDirListing(tg);

    if isempty(dl(cellfun(@(x)contains(x,tg.appsDirOnTarget),dl)))

        return;
    end

    installedApps=locGetAppsName(tg.appsDirOnTarget,dl);


    for i=1:length(installedApps)
        appName=installedApps{i};
        logDir=strcat(tg.appsDirOnTarget,"/",appName,"/logdata");
        if isempty(dl(cellfun(@(x)contains(x,logDir),dl)))
            continue;
        else
            runList=locGetRunList(dl,logDir);
            for n=1:length(runList)
                [folder,timestamp]=locDecomposeRunString(runList{n});
                runDir=strcat(logDir,"/",folder);
                dataSize=locDataSize(tg,dl,runDir);
                if dataSize>=0
                    len=length(runs);
                    runs(len+1).Application=convertCharsToStrings(appName);%#ok<*AGROW>
                    runs(len+1).StartDate=timestamp;
                    runs(len+1).Size=dataSize;
                    runs(len+1).TargetDir=runDir;
                end
            end
        end
    end

    if~isempty(runs)
        runTable=struct2table(runs);
        runTable=slrealtime.internal.logging.Manager.formatTable(runTable);
    end

end


function al=locGetAppsName(appDirs,dl)

    dl=extractAfter(dl,appDirs);
    dl=extractAfter(dl,"/");
    dl=dl(~cellfun(@(x)contains(x,"/"),dl));
    dl=extractBefore(dl," ");
    al=dl(~cellfun('isempty',dl));
end

function rl=locGetRunList(dl,logDir)


    rd=dl(cellfun(@(x)startsWith(x,logDir),dl));
    rd=extractAfter(rd,logDir);
    rd=extractAfter(rd,"/");
    rd=rd(~cellfun(@(x)contains(x,"/"),rd));
    rd=rd(~cellfun(@(x)contains(x,".dat"),rd));
    rl=rd(~cellfun('isempty',rd));
end


function dl=locGetAppsDirListing(tg)



    dl={};
    appsDir=tg.appsDirOnTarget;
    if tg.isfolder(appsDir)
        sshCmd=strcat("find ",tg.appsDirOnTarget," -follow -printf ""%p ts:%Am-%Ad-%AY,%AT sz:%s\n""");
        res=tg.executeCommand(sshCmd);
        res=split(res.Output,newline);
        dl=res(~cellfun('isempty',res));
    end
end

function[folder,timestamp]=locDecomposeRunString(runstr)
    runstr=convertCharsToStrings(runstr);
    folder=extractBefore(runstr," ts:");

    timestampStr=extractBefore(extractAfter(runstr,"ts:")," sz:");

    timestampStr=extractBefore(timestampStr,20);
    timestamp=datetime(timestampStr,'InputFormat','MM-dd-yyyy,HH:mm:ss');
end

function sz=locDataSize(tg,dl,runDir)



    rd=dl(cellfun(@(x)startsWith(x,runDir),dl));
    dataFiles=rd(cellfun(@(x)contains(x,".dat"),rd));
    sz=-1;

    if~isempty(dataFiles)
        sz=sum(cellfun(@(x)locFileSize(x),dataFiles));
    elseif slrealtime.internal.logging.hasLogDataOnRAM(tg,runDir)
        sshCmd=strcat("find ","//dev/shmem/BufferedLogging_*"," -printf ""%p sz:%s\n""");
        res=tg.executeCommand(sshCmd);
        res=split(res.Output,newline);
        ramFiles=res(~cellfun('isempty',res));
        sz=sum(cellfun(@(x)locFileSize(x),ramFiles));
    end
end

function sz=locFileSize(filestr)
    sz=str2double(extractAfter(filestr,"sz:"));
end
