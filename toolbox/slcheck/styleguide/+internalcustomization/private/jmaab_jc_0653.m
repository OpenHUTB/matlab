









function jmaab_jc_0653
    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0653');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc_0653_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID=rec.ID;
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:styleguide:jc_0653',@hCheckAlgo),...
    'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc_0653_tip');
    rec.setLicense({styleguide_license});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end











function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    if isempty(system)
        return;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    followLinks=inputParams{1}.Value;
    lookUnderMasks=inputParams{2}.Value;



    allSubSystems=[system;find_system(system,'FollowLinks',followLinks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',lookUnderMasks,...
    'BlockType','SubSystem')];


    allSubSystems=mdladvObj.filterResultWithExclusion(allSubSystems);


    subsysHandles=cellfun(@(x)(get_param(x,'handle')),allSubSystems);


    subsysHandles=subsysHandles(arrayfun(@(x)...
    ~Stateflow.SLUtils.isStateflowBlock(x),subsysHandles));


    cacheLoops=containers.Map;

    for loopIdxSubsystems=1:numel(subsysHandles)
        currHandle=subsysHandles(loopIdxSubsystems);


        subsystemHandles=find_system(currHandle,'FollowLinks',followLinks,...
        'LookUnderMasks',lookUnderMasks,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'SearchDepth',1,...
        'BlockType','SubSystem');

        subsystemHandles=setdiff(subsystemHandles,currHandle,'stable');


        subsystemHandles=subsystemHandles(arrayfun(@(x)...
        ~Stateflow.SLUtils.isStateflowBlock(x),subsystemHandles));

        if size(subsystemHandles)<2
            continue;
        end

        [adjList,allHandles]=Advisor.Utils.Graph.getBlocksOnlyGraphFromSubsystem(currHandle);
        [~,loops]=Advisor.Utils.Graph.findCycles(adjList);

        if isempty(loops)
            continue;
        end

        delayHandles=find_system(currHandle,'FollowLinks',followLinks,...
        'LookUnderMasks',lookUnderMasks,...
        'MatchFilter',@Simulink.match.allVariants,...
        'SearchDepth',1,...
        'Regexp','on','BlockType','(.*?)Delay$');

        for idxHndlLoop=1:numel(loops)
            currLoop=unique(loops{idxHndlLoop});

            handlesInLoop=allHandles(currLoop);
            [~,relevantIndicesSubsystemHandles,~]=...
            intersect(handlesInLoop,subsystemHandles,'stable');



            if size(relevantIndicesSubsystemHandles,1)<2
                continue;
            end

            if any(ismember(handlesInLoop,delayHandles))



                continue;
            end


            subsystemsCurrentLoop=handlesInLoop(relevantIndicesSubsystemHandles);









            block=get(subsystemsCurrentLoop(1));
            blkName=strrep(block.Name,'/','//');
            path=[block.Path,'/',blkName];

            if isKey(cacheLoops,path)



                elementsLoopInfo=cacheLoops(path);
            else
                blockPath=Simulink.BlockPath(path);
                loopInfo=Simulink.Structure.HiliteTool.findLoop(blockPath);

                if~loopInfo.IsInLoop






                    continue;
                end

                elementsLoopInfo=loopInfo.Elements;
                cacheLoops(path)=elementsLoopInfo;
            end





            [~,relevantIndicesSubsystemHandles,~]=...
            intersect(elementsLoopInfo,subsystemsCurrentLoop,'stable');

            if size(relevantIndicesSubsystemHandles,1)<2
                continue;
            end



            subsystemsCurrentLoop=elementsLoopInfo(relevantIndicesSubsystemHandles);

            for idxSubsysCurrLoop=1:numel(subsystemsCurrentLoop)


                delayHandlesSubsystem=find_system(subsystemsCurrentLoop(idxSubsysCurrLoop),...
                'MatchFilter',@Simulink.match.allVariants,...
                'FollowLinks',followLinks,...
                'LookUnderMasks',lookUnderMasks,...
                'Regexp','on','BlockType','(.*?)Delay$');

                [~,violationIndices,~]=...
                intersect(elementsLoopInfo,delayHandlesSubsystem,'stable');

                if isempty(violationIndices)
                    continue;
                end

                violationsDelayBlocks=elementsLoopInfo(violationIndices);

                FailingObjs=[FailingObjs;...
                violationsDelayBlocks(~ismember(violationsDelayBlocks,...
                FailingObjs))];%#okagrow

                break;
            end
        end
    end

end
