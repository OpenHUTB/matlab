function hisl_0062

    rec=getNewCheckObject('mathworks.hism.hisl_0062',false,@hCheckAlgo,'None');
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function Violations=hCheckAlgo(system)
    Violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    allCharts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    allCharts=mdladvObj.filterResultWithExclusion(allCharts);

    for i=1:length(allCharts)
        chartObj=allCharts{i};
        chartFcns=chartObj.find('-isa','Stateflow.Function');

        fcnGlobalUsageStruct=[];

        if isempty(chartFcns)
            continue;
        end

        for j=1:length(chartFcns)

            fcnData=chartFcns(j).find('-isa','Stateflow.Data');
            fcnDataNames=arrayfun(@(x)x.Name,fcnData,'UniformOutput',false);


            assignedData=getAllDataBeingAssigned(chartFcns(j));


            globalData=setdiff(assignedData,fcnDataNames);
            if~isempty(chartFcns(j).Name)
                fcnGlobalUsageStruct.(chartFcns(j).Name)=globalData;
            end
        end


        chartTxnStates=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        for j=1:length(chartTxnStates)
            tsObj=chartTxnStates(j);
            if~isempty(fcnGlobalUsageStruct)
                FailingExpressions=getFcnAndDataUsedInSameExpression(tsObj,fcnGlobalUsageStruct);
                Violations=[Violations;FailingExpressions];%#ok<AGROW>
            end
        end
    end
end

function dNames=getAllDataBeingAssigned(fcnObj)
    dNames={};

    tns=fcnObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
    for i=1:length(tns)
        allText=tns(i).LabelString;
        if isempty(allText)
            continue;
        end


        varTokens=regexp(tns(i).LabelString,'([_a-zA-Z0-9]+)\s*:?(=|++|--)','tokens');
        dNames=[dNames,cellfun(@(x)x{1},varTokens,'UniformOutput',false)];%#ok<AGROW>
    end
    dNames=unique(dNames);
end

function violations=getFcnAndDataUsedInSameExpression(tsObj,fcnGlobalUsageStruct)
    violations=[];
    asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(tsObj);
    if isempty(asts)
        return;
    end
    fcns=fieldnames(fcnGlobalUsageStruct);
    sections=asts.sections;
    for i=1:numel(sections)
        roots=sections{i}.roots;
        for j=1:numel(roots)
            stmts=strtrim(strsplit(roots{j}.sourceSnippet,';'));
            for c=1:length(stmts)
                expression=stmts{c};
                if~isempty(expression)
                    for k=1:length(fcns)
                        if expressionHasIdentifier(expression,fcns{k})&&isfield(fcnGlobalUsageStruct,fcns{k})
                            [bValid,expression]=checkAndFormatExpression(expression,fcnGlobalUsageStruct.(fcns{k}));
                            if~bValid
                                tempObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(tempObj,'SID',tsObj,'Expression',expression);
                                if~expressionExists(violations,tempObj)
                                    violations=[violations;tempObj];%#ok<AGROW>
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function[bResult,stPos,endPos]=expressionHasIdentifier(expression,identifier)
    [stPos,endPos]=regexp(expression,['(\W|\s)',identifier,'(\W|\s)?'],'once');
    bResult=~isempty(stPos);
end




function[bValid,expression]=checkAndFormatExpression(expression,idCell)
    bValid=true;
    for i=1:length(idCell)
        [bResult,stPos,endPos]=expressionHasIdentifier(expression,idCell{i});
        if bResult
            expression=Advisor.Utils.Naming.formatFlaggedName(expression,0,[stPos+1,endPos-1],'');
            bValid=bValid&&false;
        else
            bValid=bValid&&true;
        end
    end
end

function bResult=expressionExists(violations,obj)
    bResult=any(arrayfun(@(x)isequal(x,obj),violations));
end


