function genCovResults(this,res,varargin)




    isCallFromMultisim=false;
    if~isempty(varargin)
        isCallFromMultisim=varargin{1};
    end
    topModelH=this.topModelH;
    resultSettings=this.resultSettings;
    refModelCovObjs=this.getModelCovIdsForReporting;



    if get_param(topModelH,'ModelSlicerActive')
        this.isMenuSimulation=false;
    end




    if this.isMenuSimulation
        this.resultSettings.modelDisplay=true;
        this.resultSettings.makeReport=false;
        this.resultSettings.covShowResultsExplorer=false;
    end

    if resultSettings.saveSingleToWorkspaceVar&&~isempty(resultSettings.varName)
        actVarName=resultSettings.varName;
        if resultSettings.incVarName
            actVarName=incrementVarName(actVarName);
        end
        assignin('base',actVarName,res);
        cvreportdata(topModelH,res);
    end
    cumRes=[];

    if resultSettings.enableCumulative
        cumRes=cvi.TopModelCov.getRunningTotal(refModelCovObjs,false);
        if~isempty(resultSettings.cumulativeVarName)&&...
            resultSettings.saveCumulativeToWorkspaceVar
            assignin('base',resultSettings.cumulativeVarName,cumRes);
            cvreportdata(topModelH,cumRes);
        end
    end

    resultsExplorer=tagData(this,res,topModelH,isCallFromMultisim);
    fileName=[];
    outputDir='';
    if resultSettings.covSaveOutputData||...
        resultSettings.makeReport||...
        resultSettings.modelDisplay
        errorReporting=1;
        if this.isMenuSimulation
            errorReporting=2;
        end
        outputDir=cvi.TopModelCov.checkOutputDir(resultSettings.covOutputDir,errorReporting);
    end
    if resultSettings.covSaveOutputData&&~isempty(outputDir)
        fileName=cvi.TopModelCov.saveData({res,cumRes},outputDir,resultSettings.covDataFileName,resultSettings.incFileName);

        if~isempty(resultSettings.ownerCovOutputDir)
            ownerCovOutputDir=cvi.TopModelCov.checkOutputDir(resultSettings.ownerCovOutputDir);
            fileName=cvi.TopModelCov.saveData({res,cumRes},ownerCovOutputDir,resultSettings.covDataFileName,resultSettings.incFileName);
        end

        cvi.TopModelCov.cvResults(topModelH,'set',{res,cumRes});
    end

    if hasSimulationOutput(this,isCallFromMultisim)
        setupSimOutput(this,res,fileName);
    end




    modelName=get_param(topModelH,'name');
    if~isempty(this.ownerModel)
        modelName=this.ownerModel;
    end

    cvi.ResultsExplorer.ResultsExplorer.setChecksum(modelName,res);

    data=[];
    if~isempty(resultsExplorer)&&...
        resultSettings.covSaveOutputData&&~isempty(outputDir)
        data=resultsExplorer.addData(res,fileName,~isCallFromMultisim);
        resultsExplorer.addToActiveRoot(data);
    end



    if this.isMenuSimulation&&~isempty(data)
        resultsExplorer.highlightCurrentData();



        this.resultSettings.modelDisplay=false;
    end


    if~isempty(outputDir)&&this.isMenuSimulation
        this.makeReport(res,cumRes,outputDir);
    end

    if~this.isMenuSimulation
        simWarningNoBacktrace(this);
    end

end


function res=hasSimulationOutput(this,isCallFromMultisim)

    res=this.resultSettings.saveSingleToWorkspaceVar&&...
    ~isCallFromMultisim&&~this.isCvCmdCall;
end

function setupSimOutput(this,cvd,fileName)



    topModelH=this.topModelH;
    if~isempty(find(strcmpi(get_param(topModelH,'SimulationMode'),{SlCov.Utils.SIM_SIL_MODE_STR,SlCov.Utils.SIM_PIL_MODE_STR}),1))
        topModelH=coder.connectivity.TopModelSILPIL.getWrapperModel(get_param(topModelH,'Name'));
    end

    obj=get_param(topModelH,'Object');


    if isempty(fileName)
        obj.addVarToSimulationOutput(this.resultSettings.varName,'coverage',cvd);
    elseif isa(cvd,'cvdata')
        obj.addVarToSimulationOutput(this.resultSettings.varName,'coverage',cvdata(fileName,cvd));
    else
        obj.addVarToSimulationOutput(this.resultSettings.varName,'coverage',cv.cvdatagroup(fileName,cvd));
    end
end

function resultsExplorer=tagData(this,res,topModelH,isCallFromMultisim)
    resultsExplorer=[];
    try




        if this.isMenuSimulation
            explorerOwner=topModelH;
            if~isempty(this.ownerModel)&&this.keepHarnessCvData
                explorerOwner=this.ownerModel;
            end
            resultsExplorer=cvi.ResultsExplorer.ResultsExplorer.getInstance(get_param(explorerOwner,'name'),get_param(topModelH,'name'));
            if isCallFromMultisim
                resultsExplorer.setRunTag(getString(message('Slvnv:simcoverage:cvresultsexplorer:RunAll')));
            else
                resultsExplorer.setRunTag(getString(message('Slvnv:simcoverage:cvresultsexplorer:Run')));
            end
            if~isempty(res.tag)
                newTag=[resultsExplorer.getNextRunTag,' - ',res.tag];
            else
                newTag=resultsExplorer.getNextRunTag;
            end
            res.tag=newTag;
        end
    catch


        resultsExplorer=[];
    end
end

function varName=incrementVarName(varName)

    l=length(varName)+1;
    nums=[];
    nameCell=evalin('base',['who(''',varName,'*'')']);

    if isempty(nameCell)
        return;
    end

    for name=nameCell'
        if(length(name{1})>=l)
            x=str2double(name{1}(l:end));
            if~isnan(x)
                nums=[nums,x];%#ok<AGROW>
            end
        end
    end
    idx=1;
    if~isempty(nums)
        idx=max(nums)+1;
    end
    varName=[varName,num2str(idx)];
end


function simWarningNoBacktrace(this)


    backtraceState=warning('off','backtrace');
    restoreBacktrace=onCleanup(@()warning(backtraceState));
    if this.resultSettings.makeReport
        warning(message('Slvnv:simcoverage:genCovResults:CovHtmlReportingSimWarning'));
    end
    if this.resultSettings.modelDisplay
        warning(message('Slvnv:simcoverage:genCovResults:CovHighlightResultsSimWarning'));
    end
    if this.resultSettings.covShowResultsExplorer
        warning(message('Slvnv:simcoverage:genCovResults:CovShowResultsExplorerSimWarning'));
    end
end