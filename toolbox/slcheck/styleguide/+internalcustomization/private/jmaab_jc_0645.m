function jmaab_jc_0645






    checkID='jc_0645';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0645');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;

    rec.setLicense({styleguide_license});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.RowSpan=[1,1];
    paramLookUnderMasks.ColSpan=[3,4];

    inputParamList={paramFollowLinks,paramLookUnderMasks};

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);



    rec.setCallbackFcn(@checkCallBack,'none','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    [resultData]=checkAlgo(system,mdlAdvObj);
    [bResultStatus,tableOfResults]=Advisor.Utils.getTwoColumnReport('ModelAdvisor:jmaab:jc_0645',resultData);
    mdlAdvObj.setCheckResultStatus(bResultStatus);
    ResultDescription{end+1}=tableOfResults;
end

function resultData=checkAlgo(system,mdlAdvObj)




    resultData=[];


    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');




    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks.Value,'LookUnderMasks',LookUnderMasks.Value,'FindAll','off','Type','block');
    allBlocks=mdlAdvObj.filterResultWithExclusion(allBlocks);
    blockObjs=get_param(allBlocks,'Object');

    if isempty(allBlocks);return;end


    mId='([a-zA-Z_]\w*)';
    pattern='(\d+|(\d+\.\d+))(<|>|>=|<=|<>|+|-|\*|/|\^|\&|\|)(\d+|(\d+\.\d+))';


    for i=1:length(allBlocks)
        block=blockObjs{i};
        tunables=Advisor.Utils.Simulink.getTunableProperties(block.BlockType);


        if isempty(tunables)&&strcmp(block.MaskType,'Compare To Constant')
            tunables={'const'};
        end
        violations={};

        for j=1:length(tunables)
            blkProperty=block.(tunables{j});
            identifier=regexp(blkProperty,mId,'match');

            if(isempty(identifier))
                param=regexprep(blkProperty,'\s*','');
                match=regexp(param,pattern,'match');

                if~isempty(match)||isequal(param,'1')||isequal(param,'0')
                    continue;
                end

                violations=[violations,{[tunables{j},' : ',blkProperty]}];%#ok

            end
        end

        if~isempty(violations)
            resultData=[resultData;{block,violations}];%#ok
        end

    end
end
