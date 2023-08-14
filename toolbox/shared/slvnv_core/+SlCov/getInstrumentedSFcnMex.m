

function mexPath=getInstrumentedSFcnMex(sfcnPath,isLoaded)

    persistent isSlCovInstalled
    if isempty(isSlCovInstalled)
        isSlCovInstalled=~isempty(ver('slcoverage'))&&license('test',SlCov.CoverageAPI.getLicenseName());
    end

    if~isSlCovInstalled
        mexPath=[];
        return
    end

    try
        sfcnName=SlCov.Utils.fixSFunctionName(get_param(sfcnPath,'FunctionName'));
    catch


        mexPath=[];
        return
    end


    modelsList=find_system('type','block_diagram');
    if~any(strcmpi(get_param(modelsList,'SimulationStatus'),'initializing')&...
        (strcmpi(get_param(modelsList,'RecordCoverage'),'on')|...
        ~strcmpi(get_param(modelsList,'CovModelRefEnable'),'off'))&...
        strcmpi(get_param(modelsList,'CovSFcnEnable'),'on'))

        mexPath=[];
        return
    end


    fGenObj=Simulink.fileGenControl('getConfig');
    fDir=fullfile(fGenObj.CacheFolder,'slprj','sim','_slcov');
    mexPath=fullfile(fDir,[sfcnName,'.',mexext]);

    if isLoaded&&SlCov.Utils.isfile(mexPath)


        mexPath='';
    else


        try
            buf=feval(sfcnName,'getInstrumentedMex');
            if~exist(fDir,'dir')
                mkdir(fDir);
            end
        catch

            mexPath=[];
            return
        end
        fid=fopen(mexPath,'wb');
        if fid<0
            mexPath=[];
            return
        end
        fwrite(fid,buf,'*uint8');
        fclose(fid);
    end
