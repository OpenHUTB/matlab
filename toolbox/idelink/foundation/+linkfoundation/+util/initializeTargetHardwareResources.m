function initializeTargetHardwareResources(cs)









    hModel=cs.getModel();

    blocks=i_findTPBlock(hModel);




    if~isempty(get_param(cs,'TargetHardwareResources'))

    elseif~isempty(blocks)
        linkfoundation.util.setTargetHardwareResourcesFromBlock(cs,blocks);
    else
        linkfoundation.util.setDefaultTargetHardwareResources(cs);
    end

    if~isempty(get_param(cs,'TargetHardwareResources'))
        controller=get_param(cs,'TargetHardwareResourcesController');
        if isempty(controller)
            controller=targetpref.Controller.get(cs,-1,'emptyFcn');
            set_param(cs,'TargetHardwareResourcesController',controller);
        end
    end

end



function block=i_findTPBlock(model)


    blocks=find_system(model,'FollowLinks','on','LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','Target Preferences');
    if(length(blocks)>1)
        DAStudio.error('ERRORHANDLER:pjtgenerator:TooManyTgtPrefBlocksInModel',...
        model);
    elseif~isempty(blocks)
        if iscell(blocks)
            block=blocks{1};
        else
            block=blocks;
        end
    else
        block=[];
    end
end
