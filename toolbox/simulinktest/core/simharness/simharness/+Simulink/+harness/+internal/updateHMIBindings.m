

function updateHMIBindings(cutBlockHandle)


    assert(ishandle(cutBlockHandle));
    blockType=get_param(cutBlockHandle,'BlockType');


    assert(isequal(blockType,'SubSystem')||isequal(blockType,'Reference'));


    cutBlock=getfullname(cutBlockHandle);
    origModel=bdroot(cutBlock);
    try
        mwebhmi=Simulink.HMI.WebHMI.getWebHMI(get_param(origModel,'handle'));
    catch
        mwebhmi='';
    end
    if~isempty(mwebhmi)
        widgetBlks=find_system(cutBlock,'LookUnderMasks','all','FollowLinks','on',...
        'MatchFilter',@Simulink.match.allVariants,'MaskType','MWDashboardBlock');
        for i=1:length(widgetBlks)
            id=utils.getInstanceId(get_param(widgetBlks{i},'object'));
            mwebhmi.undeleteBlock(id,false);
        end
    end

end
