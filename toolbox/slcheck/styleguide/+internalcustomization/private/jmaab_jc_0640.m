function jmaab_jc_0640






    checkID='jc_0640';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0640');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=false;

    rec.setLicense({styleguide_license});



    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.RowSpan=[1,1];
    paramLookUnderMasks.ColSpan=[3,4];

    rec.setInputParametersLayoutGrid([4,4]);
    rec.setInputParameters({paramFollowLinks,paramLookUnderMasks});



    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function result=checkCallBack(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    violations=checkAlgo(mdlAdvObj,system);
    result=Advisor.Utils.Report.getReport(violations,'ModelAdvisor:jmaab:jc_0640');
    result.setSubBar(false);
    mdlAdvObj.setCheckResultStatus(isempty(violations));
end


function violations=checkAlgo(mdlAdvObj,system)
    violations=[];


    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');


    if~isequal(get_param(bdroot(system),'UnderspecifiedInitializationDetection'),'Classic')
        return;
    end



    conditionalSS=get_param(find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks.Value,...
    'LookUnderMasks',LookUnderMasks.Value,...
    'regexp','on',...
    'BlockType','(EnablePort|TriggerPort|ActionPort)'),'Parent');

    conditionalSS=unique(mdlAdvObj.filterResultWithExclusion(conditionalSS));

    for idx=1:numel(conditionalSS)
        subsys=conditionalSS{idx};

        if isequal(subsys,bdroot)
            continue;
        end


        if Stateflow.SLUtils.isStateflowBlock(subsys)||Stateflow.SLUtils.isChildOfStateflowBlock(subsys)
            continue;
        end


        outportBlks=find_system(subsys,'SearchDepth',1,'BlockType','Outport');





        for jdx=1:numel(outportBlks)
            outObj=get_param(outportBlks{jdx},'object');
            dstPort=outObj.getActualDst;
            srcPort=outObj.getActualSrc;
            dstIsMergeBlk=false;

            if~isempty(dstPort)&&~isequal(dstPort,-1)
                dstBlk=get_param(dstPort(1),'Parent');
                try
                    dstBlk=get_param(dstBlk,'object');
                catch
                    hitIndices=regexp(dstBlk,'/');
                    dstBlk=extractBefore(dstBlk,hitIndices(end));
                    dstBlk=get_param(dstBlk,'object');
                end
                if strcmp(dstBlk.BlockType,'Merge')
                    dstIsMergeBlk=true;
                    violations=[violations,checkInitialOutputSetting(dstBlk,subsys)];%#ok<AGROW>
                end
            end


            if~dstIsMergeBlk&&~isempty(srcPort)&&~isequal(srcPort,-1)&&isequal(size(srcPort,1),1)
                srcBlk=get_param(srcPort(1),'Parent');
                srcBlk=get_param(srcBlk,'object');
                if strcmp(srcBlk.BlockType,'Constant')||strcmp(srcBlk.BlockType,'Delay')
                    violations=[violations,checkInitialOutputSetting(outObj,subsys)];%#ok<AGROW
                end
            end
        end
    end
end

function violation=checkInitialOutputSetting(destBlk,subsys)
    violation=[];
    if isequal(destBlk.InitialOutput,'[]')
        violation=ModelAdvisor.Violation(subsys,destBlk);
    end
end
