function hisl_0102




    rec=getNewCheckObject('mathworks.hism.hisl_0102',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

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

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)
    violations=checkIteratorBlocks(system);

    if(Advisor.Utils.license('test','stateflow'))
        violations=[violations;checkEML(system)];
    end
end

function violations=checkIteratorBlocks(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    iteratorBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','ForIterator');
    iteratorBlocks=mdladvObj.filterResultWithExclusion(iteratorBlocks);

    flags=false(1,length(iteratorBlocks));
    for i=1:length(iteratorBlocks)
        iteratorDataType=get_param(iteratorBlocks(i),'IterationVariableDataType');
        if~(startsWith(iteratorDataType,'int')||startsWith(iteratorDataType,'uint'))
            flags(i)=true;
        end
    end

    violations=Advisor.Utils.createResultDetailObjs(iteratorBlocks(flags),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0102_rec_action'));
    if~iscolumn(violations)
        violations=violations';
    end
end

function sfIssueTable=checkSF(system)
    sfIssueTable={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    chartObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    chartObjs=mdladvObj.filterResultWithExclusion(chartObjs);
    rt=sfroot;
    for i=1:length(chartObjs)

        AllLoops=Advisor.Utils.Stateflow.getLoopsInChart(chartObjs{i});
        for j=1:length(AllLoops)

            if length(AllLoops{j})<2||length(AllLoops{j})>3
                continue;
            end


            condTxn=chartObjs{i}.find('-isa','Stateflow.Transition','Source',idToHandle(rt,AllLoops{j}(1)),'Destination',idToHandle(rt,AllLoops{j}(2)));
            if numel(condTxn)>1||~startsWith(condTxn.LabelString,'[')
                continue;
            end
            varsInCond=getVariablesFromLabel(condTxn);



            varsInTxn2=[];
            if length(AllLoops{j})==3
                Txn2=chartObjs{i}.find('-isa','Stateflow.Transition','Source',idToHandle(rt,AllLoops{j}(2)),'Destination',idToHandle(rt,AllLoops{j}(3)));
                varsInTxn2=getVariablesFromLabel(Txn2);
            end

            countTxn=chartObjs{i}.find('-isa','Stateflow.Transition','Source',idToHandle(rt,AllLoops{j}(end)),'Destination',idToHandle(rt,AllLoops{j}(1)));


            varsInCount=getVariablesFromLabel(countTxn);

            varsInCount=unique([varsInTxn2,varsInCount]);

            if isempty(varsInCount)
                continue;
            end



            vars=intersect(varsInCond,varsInCount);


            flag=false(1,length(vars));
            for k=1:length(vars)
                varData=chartObjs{i}.find('-isa','Stateflow.Data','Name',vars{k});

                if isempty(varData)
                    continue;
                end



                if length(varData)>1


                    matches=regexp(condTxn.path,get(varData(:),'Path'),'match');
                    [~,idx]=max(cellfun(@(x)length(cell2mat(x)),matches));
                    varData=varData(idx);
                end

                if~any(strcmp(varData.CompiledType,{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}))
                    flag(k)=true;
                end
            end
            if any(flag)
                sfIssueTable{end+1,1}=condTxn;%#ok<AGROW>
                sfIssueTable{end,2}=strjoin(vars(flag),', ');
            end
        end
    end
end

function violations=checkEML(system)
    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{1}.Value,inputParams{2}.Value);
    fcnObjs=mdladvObj.filterResultWithExclusion(fcnObjs);

    for i=1:length(fcnObjs)

        rp=Advisor.Utils.Eml.getEmlReport(fcnObjs{i});
        if isempty(rp)
            return;
        end

        rpi=rp.inference;

        mt=mtree(fcnObjs{i}.Script,'-com','-cell','-comments');

        opNodes=mt.mtfind('Kind','FOR');

        indices=opNodes.indices;
        for j=1:length(indices)
            node=opNodes.select(indices(j));
            if isempty(node.Index)
                continue;
            end

            idxDataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Index,rpi);

            if~any(strcmp(idxDataType,{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}))
                violations=[violations;getViolationInfoFromNode(fcnObjs{i},node,DAStudio.message('ModelAdvisor:hism:hisl_0102_rec_action'))];%#ok<AGROW>
            end
        end
    end

end

function vars=getVariablesFromLabel(txn)
    tokens=regexp(txn.LabelString,'([_a-zA-Z]\w*)','tokens');
    vars=unique([tokens{:}]);
end

