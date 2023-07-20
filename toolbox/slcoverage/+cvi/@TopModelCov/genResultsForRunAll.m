
function genResultsForRunAll(modelH,designStudyLabel)


    try

        simMan=getSimMan(modelH);

        if isempty(simMan)||~isCoverageON(modelH,simMan.SimulationInputs)
            return;
        end

        [covdata,tags]=getCovdata(modelH,designStudyLabel);
        if isempty(covdata)
            return;
        end
        tags.totalLabel=designStudyLabel;
        cvi.TopModelCov.genResultsForMultiSim(modelH,covdata,tags);

    catch MEx
        rethrow(MEx);
    end
end
function[covdata,tags]=getCovdata(modelH,designStudyLabel)
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelH,dataId);
    simMan=bdData.SimulationJob.SimulationManager;
    simOutData=simMan.SimulationData;
    simInps=simMan.SimulationInputs;
    covdata={};
    tags={};
    for idx=1:numel(simOutData)
        csd=simOutData(idx);
        for didx=1:numel(csd)
            fn=fieldnames(csd{didx});
            for fidx=1:numel(fn)
                cd=csd{didx}.(fn{fidx});
                if isa(cd,'cvdata')||isa(cd,'cv.cvdatagroup')
                    covdata=[covdata,{cd}];
                    [label,descr]=getLabels(simInps(idx),idx,designStudyLabel);
                    tags.labels{idx}=label;
                    tags.descrs{idx}=descr;
                end
            end
        end
    end
end
function simMan=getSimMan(modelH)
    simMan=[];
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelH,dataId);
    if isempty(bdData)
        return;
    end
    simMan=bdData.SimulationJob.SimulationManager;

end

function res=isCoverageON(modelH,simInps)
    res=false;
    if~cvi.TopModelCov.checkLicense(modelH)
        return;
    end
    if strcmpi(get_param(modelH,'CovEnable'),'off')

        for idx=1:numel(simInps)
            res=res||SlCov.CoverageAPI.isSimInputCoverageOn(simInps(idx));
            if res
                break;
            end
        end
    else
        res=true;
    end
end
function[label,descr]=getLabels(simInp,idx,designStudyLabel)

    bps=simInp.BlockParameters;
    paramValues=cell(numel(bps),1);
    paramNameAndValues=cell(numel(bps),1);
    blockPaths=cell(numel(bps),1);
    activeScenarios='';
    for bIdx=1:numel(bps)
        bp=bps(bIdx);
        paramValues{bIdx}=char(bp.Value);
        if strcmpi(bp.Name,'ActiveScenario')
            activeScenarios=[activeScenarios,' ',char(bp.Value)];%#ok<AGROW> 
        end
        blockName=split(bp.BlockPath,'/');
        blockPath=blockName{2:end};
        paramNameAndValues{bIdx}=strjoin({char(blockPath),char(bp.Name),char(bp.Value)},':');
        blockPaths{bIdx}=blockPath;
    end
    runTag=getString(message('Slvnv:simcoverage:cvresultsexplorer:Run'));
    label=sprintf([runTag,' %d'],idx);
    if~isempty(activeScenarios)
        label=[label,':',activeScenarios];
    end
    descr=[designStudyLabel,':',newline,strjoin(paramNameAndValues,',')];

end