function results=multiReleaseTestRunOneTest(resuletSetRoot,infoFileRoot,inforMatFile)




    persistent cachedFolder
    results={};
    currDir=pwd();
    IMTHarnessRoot=fileparts(mfilename('fullpath'));
    workerfolder=fullfile(resuletSetRoot,'Workers');

    addpath(IMTHarnessRoot);
    addpath(infoFileRoot);
    if isempty(cachedFolder)
        cachedFolder=tempname;
        mkdir(cachedFolder);
        try
            set_param(0,'CacheFolder',cachedFolder);
            set_param(0,'CodeGenFolder',cachedFolder);
        catch
        end
    end

    workerIdx=1;
    try
        stopSignFile=fullfile(workerfolder,'STOP');
        workerStartFile=fullfile(workerfolder,sprintf('worker_%d.START',workerIdx));
        fid=fopen(workerStartFile,'w');
        fclose(fid);

        load(inforMatFile);
        for itrK=1:numel(testInfoArray)
            if(exist(stopSignFile,'file'))
                break;
            end

            oneResult=MRTHarness('MultiReleaseTesting',...
            itrK,testInfoArray{itrK},currDir,workerIdx);
            results{end+1}=oneResult;
        end
        writeWorkerEndFile(workerfolder,workerIdx);

    catch err
        IMTDisplayMessage(lasterr);%#ok<*LERR>
        writeWorkerEndFile(workerfolder,workerIdx);
    end
    IMT_PostHarnessAutoTestCleanup();
    rmpath(infoFileRoot);
end

function writeWorkerEndFile(workerfolder,workerIdx)
    workerEndFile=fullfile(workerfolder,sprintf('worker_%d.END',workerIdx));
    fid=fopen(workerEndFile,'w');
    fclose(fid);
end


