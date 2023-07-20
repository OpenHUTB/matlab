






function[clr,roSubsys]=changeSubsystemPermissions(model)


    modelH=get_param(model,'handle');


    roSubsys=find_system(modelH,...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'Permissions','ReadOnly'...
    );


    if isempty(roSubsys)
        clr=onCleanup.empty;
        return
    end


    dirtyFlag=get_param(modelH,'Dirty');
    arrayfun(@(ssH)set_param(ssH,'Permissions','ReadWrite'),roSubsys);
    clr=onCleanup(@()restorePermissions(modelH,roSubsys,dirtyFlag));

end


function restorePermissions(modelH,roSubsys,dirtyFlag)

    arrayfun(@(ssH)set_param(ssH,'Permissions','ReadOnly'),roSubsys);
    set_param(modelH,'Dirty',dirtyFlag);

end
