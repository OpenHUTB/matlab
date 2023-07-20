
function covTotal=genResultsForMultiSim(modelH,covdata,tags)



    try

        coveng=cvi.TopModelCov.getInstance(modelH);
        if isempty(coveng)
            coveng=cvi.TopModelCov(modelH);
            coveng.topModelH=modelH;
            coveng.ownerModel='';
            coveng.getResultSettings;
        end
        coveng.isMenuSimulation=true;
        resultSettings=coveng.resultSettings;

        topModelH=coveng.topModelH;


        outputDir=cvi.TopModelCov.checkOutputDir(resultSettings.covOutputDir);
        covTotal={};

        modelName=get_param(topModelH,'name');
        if~isempty(coveng.ownerModel)
            modelName=coveng.ownerModel;
        end
        resultsExplorer=cvi.ResultsExplorer.ResultsExplorer.getInstance(modelName,resultSettings);
        for testIdx=1:numel(covdata)
            cvd=covdata{testIdx};
            cvd.tag=tags.labels{testIdx};
            if isfield(tags,'descrs')
                cvd.description=tags.descrs{testIdx};
            end
            if numel(covdata)>1
                if~isempty(outputDir)&&resultSettings.covSaveOutputData
                    fileName=cvi.TopModelCov.saveData({cvd,[]},outputDir,resultSettings.covDataFileName);
                    if~isempty(resultsExplorer)
                        resultsExplorer.addData(cvd,fileName);
                    end
                end
            end

            if isempty(covTotal)
                covTotal=cvd;
            else
                covTotal=covTotal+cvd;
            end
        end
        covTotal.tag=tags.totalLabel;

        if isa(covTotal,'cvdata')
            all={covTotal};
        else
            all=covTotal.getAll('Mixed');
        end
        refModelCovObjs=[];
        for idx=1:length(all)
            cto=all{idx};
            rootId=cto.rootID;
            currModelcovId=cv('get',rootId,'.modelcov');
            updateResults(coveng,cto);
            refModelCovObjs(end+1)=currModelcovId;%#ok<*AGROW>
        end
        genCovResults(coveng,covTotal,true)

    catch MEx
        rethrow(MEx);
    end
end

