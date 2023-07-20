function hisl_0020




    rec=getNewCheckObject('mathworks.hism.hisl_0020',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
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
    violations={};

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    filterStruct=readConfiguration();



    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'Type','Block');
    allBlocks=Advisor.Utils.Simulink.standardFilter(system,allBlocks);
    allBlocks=mdlAdvObj.filterResultWithExclusion(allBlocks);

    for i=1:numel(allBlocks)
        capabilitySet=getCapabilitySet(allBlocks{i});
        if isempty(capabilitySet)
            continue;
        end

        supportsCodegen=capabilitySet.supports('codegen');
        supportsProduction=capabilitySet.supports('production');
        footnotesCodegen=capabilitySet.footnotes('codegen');
        footnotesProduction=capabilitySet.footnotes('production');


        if~(strcmp(supportsCodegen,'No')||strcmp(supportsProduction,'No')||~isempty(footnotesCodegen)||~isempty(footnotesProduction))
            continue;
        end

        if isempty(footnotesCodegen)
            footnotesCodegen={};
        else
            footnotesCodegen=regexp(footnotesCodegen,',','split');
        end

        if isempty(footnotesProduction)
            footnotesProduction={};
        else
            footnotesProduction=regexp(footnotesProduction,',','split');
        end


        supportsCodegen=strcmp(supportsCodegen,'Yes');
        supportsProduction=strcmp(supportsProduction,'Yes');

        ignoreProduction=filterStruct.ignoreProduction;
        filterCodegen=filterStruct.filterCodegen;
        filterProduction=filterStruct.filterProduction;

        if ignoreProduction
            if isempty(footnotesCodegen)
                if~supportsCodegen
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0020_rec_action1');
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0020_warn1');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            else
                footnotesCodegen(ismember(footnotesCodegen,filterCodegen))=[];%#ok<AGROW>
                if~isempty(footnotesCodegen)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
                    vObj.RecAction=makeRecActionFromFootNotes(footnotesCodegen);
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0020_warn2');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end
        else
            if isempty(footnotesCodegen)&&isempty(footnotesProduction)
                if~(supportsCodegen&&supportsProduction)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0020_rec_action2');
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0020_warn2');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            else
                footnotesCodegen(ismember(footnotesCodegen,filterCodegen))=[];%#ok<AGROW>
                footnotesProduction(ismember(footnotesProduction,filterProduction))=[];%#ok<AGROW>
                footnotes=[footnotesCodegen,footnotesProduction];
                if~(isempty(footnotesCodegen)&&isempty(footnotesProduction))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
                    vObj.RecAction=makeRecActionFromFootNotes(footnotes);
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0020_warn2');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end
        end

    end
end

function capabilitySet=getCapabilitySet(block)

    blockObject=get_param(block,'Object');
    try
        if blockObject.isprop('Capabilities')
            capabilities=blockObject.Capabilities;
        else
            capabilities=[];
        end

        if isempty(capabilities)
            capabilitySet=[];
        else
            capabilitySet=capabilities.getSet(capabilities.CurrentMode);
        end
    catch
        capabilitySet=[];
    end

end

function text=getRecActionFromToken(footnote)

    temp=regexp(footnote,'(\S*)_(\S*)','tokens');
    if isempty(temp)
        messageString=sprintf('Simulink:bcst:%s',footnote);
    else
        tokens=temp{1};
        messageString=sprintf('%s:bcst:%s',tokens{1},tokens{2});
    end
    try
        text=DAStudio.message(messageString);
    catch
        text=footnote;
    end
end

function recAct=makeRecActionFromFootNotes(footnotes)
    recAct=DAStudio.message('ModelAdvisor:hism:hisl_0020_rec_action2');

    for idx=1:length(footnotes)

        textToAdd=getRecActionFromToken(footnotes{idx});

        textToAdd=regexprep(textToAdd,'<[^<]*>','');

        recAct=[recAct,'<br/>',num2str(idx),'. ',textToAdd];%#ok<AGROW>

    end

end

function filterStruct=readConfiguration()

    list=supportNotes_productionCodeDeploymentDefault;

    if isempty(list)
        listCodegen={};
        listProduction={};
    else
        listCodegen=list(strcmp('codegen',list(:,1)),2);
        listProduction=list(strcmp('production',list(:,1)),2);
    end

    emptyProduction=strcmp('',listProduction);

    filterStruct.filterCodegen=listCodegen;
    filterStruct.filterProduction=listProduction(~emptyProduction);

    if any(emptyProduction)
        filterStruct.ignoreProduction=true;
    else
        filterStruct.ignoreProduction=false;
    end
end
