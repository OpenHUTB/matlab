function runTable=localLogData(localDir)










    validateattributes(localDir,{'string','char'},{'nonempty','scalartext'});
    localDir=string(localDir);

    runs=[];
    runTable=table;

    if locIsAppFolder(localDir)

        appDirs=localDir;
    else

        d=dir(localDir);
        d(strcmp({d.name},'.')|strcmp({d.name},'..'))=[];
        d(~[d.isdir])=[];
        appDirs=cellfun(@fullfile,{d.folder}',{d.name}','UniformOutput',false);
        appDirs=appDirs(cellfun(@locIsAppFolder,appDirs));
    end

    appDirs=string(appDirs);
    if(isempty(appDirs))
        error(message('slrealtime:logging:InvalidLocalDir',localDir));
    end

    for i=1:length(appDirs)
        pathParts=strsplit(appDirs(i),filesep);
        appName=pathParts(end);
        logFiles=dir(fullfile(appDirs(i),"logdata/run_*/*.dat"));
        runFolders=string(unique({logFiles.folder}));
        for j=1:length(runFolders)
            d=dir(runFolders(j));
            dataSize=sum([d.bytes]);
            timestampFile=dir(fullfile(appDirs(i),"logdata/run_*/*.timestamp"));
            timestamp=strsplit(timestampFile(j).name,'.');
            len=length(runs);
            runs(len+1).Application=appName;%#ok<*AGROW>
            runs(len+1).StartDate=datetime(timestamp(1),'InputFormat','yyyy-MM-dd_HH-mm-ss');
            runs(len+1).Size=dataSize;
            runs(len+1).HostDir=string(runFolders(j));
        end
    end


    if~isempty(runs)
        runTable=struct2table(runs);
        runTable=slrealtime.internal.logging.Manager.formatTable(runTable);
    end

end

function b=locIsAppFolder(path)
    b=isfile(fullfile(path,'host','dmr','RTWDirStruct.mat'))...
    &&isfile(fullfile(path,'misc','modelDescription.json'));
end
