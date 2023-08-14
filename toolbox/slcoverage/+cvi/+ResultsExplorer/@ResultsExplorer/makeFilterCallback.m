function makeFilterCallback(obj,topModelName,filterEditor)




    msg=cvi.ResultsExplorer.ResultsExplorer.checkLicense;
    if~isempty(msg)
        errordlg(getString(msg),getString(message('Slvnv:simcoverage:cvresultsexplorer:WindowTitle')),'modal');
        return;
    end

    obj.ed.broadcastEvent('MESleepEvent');
    try
        data=[];
        dataFile='';
        status=0;
        if~strcmpi(get_param(topModelName,'Dirty'),'on')
            try
                dataFile=['./sldv_output/',topModelName,'/',topModelName,'_sldvdata_deadlogic_coverage_filter.mat'];
                data=Sldv.ReportUtils.loadAndCheckSldvData(dataFile);
            catch MEx %#ok<NASGU>
            end
        end
        filterEditor.modelName=topModelName;
        if isempty(data)||...
            ~strcmpi(get_param(topModelName,'ModelVersion'),data.ModelInformation.Version)||...
            isfield(data.ModelInformation,'ReplacementModel')||...
            chekVariantSubsystem(topModelName)
            dataFile=runSldvDeadLogic(topModelName);
            if~isempty(dataFile)
                status=cvi.ResultsExplorer.ResultsExplorer.makeFilter(filterEditor,dataFile);
            else

            end
        else
            status=cvi.ResultsExplorer.ResultsExplorer.makeFilter(filterEditor,data);
        end

        if status~=0
            warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:NotCompatibleSldvData',dataFile)),...
            getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadSldvData')),'modal');
        else
            obj.showFilter;
        end
    catch MEx %#ok<NASGU>
    end

    obj.ed.broadcastEvent('MEWakeEvent');

end

function res=chekVariantSubsystem(topModelName)
    res=false;
    try


        vs=find_system(topModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem','variant','on');
        res=~isempty(vs);
    catch

    end
end

function dataFile=runSldvDeadLogic(topModelName)
    to=sldvoptions(topModelName);
    opts=to.deepCopy;
    opts.SaveHarnessModel='off';
    opts.SaveReport='off';
    opts.Mode='DesignErrorDetection';
    opts=Sldv.utils.disableDedChecks(opts);
    opts.DetectDeadLogic='on';
    opts.DeadLogicObjectives='MCDC';
    opts.CovFilter='off';
    opts.CovFilterFileName='';
    opts.MakeOutputFilesUnique='off';
    opts.DataFileName='$ModelName$_sldvdata_deadlogic_coverage_filter';
    opts.RebuildModelRepresentation='Always';
    dataFile='';

    showUI=true;
    startCov=[];
    preExtract=[];
    customEnhancedMCDCOpts=[];
    client=Sldv.SessionClient.SimulinkCoverage;
    [status,files]=sldvprivate('sldvRunAnalysis',topModelName,opts,...
    showUI,startCov,preExtract,customEnhancedMCDCOpts,client);
    if~status
        return;
    end
    dataFile=files.DataFile;
end

