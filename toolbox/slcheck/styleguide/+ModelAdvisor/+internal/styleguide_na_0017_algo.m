function conflictDetails=styleguide_na_0017_algo(fcnBlocks,fcnCallLevelLimit)













    emlCallables=[];

    emFcns=cellfun(@(x)isequal(class(x),'Stateflow.EMFunction'),fcnBlocks);
    emFcns=fcnBlocks(emFcns);

    if numel(emFcns)>0
        emlCallables(numel(emFcns)).result=[];
        for idx=1:numel(emFcns)
            emlCallables(idx).name=emFcns{idx}.Name;
            emlCallables(idx).object=emFcns{idx};
        end
    end

    conflictDetails={};
    for i=1:length(fcnBlocks)
        [details,emlCallables]=AnalyzeScript(fcnBlocks{i},fcnCallLevelLimit,emlCallables);
        conflictDetails=[conflictDetails;details];%#ok<AGROW>
    end
end


function[conflictDetails,emlCallables]=AnalyzeScript(fcnBlock,fcnCallLevelLimit,emlCallables)
    conflictDetails={};fcnCallCount=0;


    T=mtree(fcnBlock.Script);
    [bValid,error]=Advisor.Utils.isValidMtree(T);
    if~bValid
        conflictDetails=ModelAdvisor.Text([fcnBlock.Path,':',error.message]);
        conflictDetails.setHyperlink(['matlab:hilite_system(''',fcnBlock.Path,''')']);
        return;
    end

    if isnull(T.root.Body)
        return;
    end

    if isnull(T.root.Body.Next)
        fcnCallCount=-1;
    end

    bProcessed=false;


    if isequal(class(fcnBlock),'Stateflow.EMFunction')
        [bStatus,index]=ismember(fcnBlock.Name,{emlCallables.name});
        if bStatus&&~isempty(emlCallables(index).result)
            result=emlCallables(index).result;
            bProcessed=true;
        end
    end

    if~bProcessed
        visitedFiles={};
        scriptAnalyzer=ModelAdvisor.internal.mScriptAnalyzer(fcnBlock);
        scriptAnalyzer.setEMLCallables(emlCallables);
        result=scriptAnalyzer.getFunctionDetails(visitedFiles);
        if isequal(class(fcnBlock),'Stateflow.EMFunction')
            emlCallables=scriptAnalyzer.emlCallables;
            [bStatus,index]=ismember(fcnBlock.Name,{emlCallables.name});
            if bStatus
                emlCallables(index).result=result;
            end
        end
    end

    result.location=ModelAdvisor.Text(fcnBlock.getFullName);
    result.location.setHyperlink(['matlab:hilite_system(''',fcnBlock.Path,''')']);

    [report,fcnCallCount]=result.getMATreeReport(fcnCallCount,fcnCallLevelLimit);

    if fcnCallCount>fcnCallLevelLimit
        conflictDetails={report};
    end

end

