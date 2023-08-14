function estimateCost(cbinfo)




    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');

    diagStage=sldiagviewer.createStage(getString(message('dataflow:Spreadsheet:EstimatingStageName')),'ModelName',model);


    [allMdls,~]=multicoredesigner.internal.MappingData.updateDataModelHierarchy(modelH);


    for i=length(allMdls):-1:1
        modelToAnalyze=allMdls{i};
        tempSettings={{'MulticoreDesignerAction','EstimateCost'}};
        if slfeature('SLMulticore')==2


            tempSettings{end+1}={'EnableMultiTasking','on'};
        end
        orig=setParamTemp(modelToAnalyze,tempSettings);
        restoreSettings=onCleanup(@()recoverParam(modelToAnalyze,orig));


        multicoredesigner.internal.toolstrip.updateModelForAnalysis(modelToAnalyze,false);
    end
end


function org=setParamTemp(system,params)
    org=[];
    for i=1:length(params)
        p=params{i};
        org{end+1}={p{1},get_param(system,p{1})};
        set_param(system,p{1},p{2});
    end
end

function recoverParam(system,params)
    for i=1:length(params)
        p=params{i};
        set_param(system,p{1},p{2});
    end
end


