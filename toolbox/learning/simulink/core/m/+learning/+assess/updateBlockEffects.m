function updateBlockEffects(assessmentObj,isCorrect)




    userBlockValueFile=learning.assess.getAssessmentPlotLogFile();


    if~exist(userBlockValueFile,'file')
        return
    end
    load(userBlockValueFile,'userStruct');


    if isCorrect
        status=learning.simulink.glowEnum.Green;
        learning.simulink.glowGrader.setGlow(userStruct.correctBlock,...
        status,'GlowGrader');
        learning.simulink.updateGraderBadge(userStruct.correctBlock,status);
    else


        status=learning.simulink.glowEnum.Yellow;
        userModelName=LearningApplication.getModelName();


        matchingBlockTypes=find_system(userModelName,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType',assessmentObj.BlockType,'ReferenceBlock',assessmentObj.ReferenceBlock);
        for i=1:length(matchingBlockTypes)
            learning.simulink.glowGrader.setGlow(matchingBlockTypes(i),...
            status,'GlowGrader');
            learning.simulink.updateGraderBadge(matchingBlockTypes(i),status);
        end
    end
end
