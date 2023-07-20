









function maab_jc_0121
    rec=ModelAdvisor.Check('mathworks.maab.jc_0121');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc_0121_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID=rec.ID;
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:styleguide:jc_0121',@hCheckAlgo),...
    'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc_0121_tip');
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
    mdladvRoot.publish(rec,sg_maab_group);
end


function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');



    sumBlocks=mdlAdvObj.filterResultWithExclusion(...
    find_system(system,'FollowLinks',flv.Value,'LookUnderMasks',lum.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','Sum'));

    if isempty(sumBlocks)
        return
    end

    for sumBlockCount=1:length(sumBlocks)
        sumBlockObj=get(get_param(sumBlocks{sumBlockCount},'handle'));
        if isempty(sumBlockObj)
            continue;
        end
        if strcmp(sumBlockObj.IconShape,'rectangular')
            violations=ModelAdvisor.internal.sumBlock.getViolationsOverlappingSignals(sumBlockObj);
            for vCount=1:length(violations)
                tempFailObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempFailObj,'Signal',violations(vCount));
                tempFailObj.RecAction=...
                DAStudio.message('ModelAdvisor:styleguide:jc_0121_rec_action_signal_overlap');
                tempFailObj.Status=...
                DAStudio.message('ModelAdvisor:styleguide:jc_0121_warn_signal_overlap');
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
            end
        else

            blockPath=Simulink.BlockPath(sumBlocks{sumBlockCount});
            loopInfo=Simulink.Structure.HiliteTool.findLoop(blockPath);

            if~loopInfo.IsInLoop
                tempFailObj=ModelAdvisor.internal.prepareFailureObject(...
                sumBlocks{sumBlockCount},...
                DAStudio.message('ModelAdvisor:styleguide:jc_0121_rec_action_signal_sum_round_nf'),...
                DAStudio.message('ModelAdvisor:styleguide:jc_0121_warn_signal_sum_round_nf'));
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
            else
                if ModelAdvisor.internal.sumBlock.hasMoreThanSpecifiedInputs(sumBlockObj,3)
                    tempFailObj=ModelAdvisor.internal.prepareFailureObject(...
                    sumBlocks{sumBlockCount},...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_rec_action_gt3_inputs'),...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_warn_gt3_inputs'));
                    FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
                end

                if ModelAdvisor.internal.sumBlock.haveMisplacedSignalsInput(sumBlockObj)
                    tempFailObj=ModelAdvisor.internal.prepareFailureObject(...
                    sumBlocks{sumBlockCount},...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_rec_action_misplaced_inputs'),...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_warn_misplaced_inputs'));
                    FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
                end

                if ModelAdvisor.internal.sumBlock.haveMisplacedSignalsOutput(sumBlockObj)
                    tempFailObj=ModelAdvisor.internal.prepareFailureObject(...
                    sumBlocks{sumBlockCount},...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_rec_action_misplaced_output'),...
                    DAStudio.message('ModelAdvisor:styleguide:jc_0121_warn_misplaced_output'));
                    FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
                end
            end
        end
    end
end
