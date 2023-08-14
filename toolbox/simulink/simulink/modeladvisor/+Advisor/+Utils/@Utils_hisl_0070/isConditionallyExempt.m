function bResult=isConditionallyExempt(Object,opt)
    if Advisor.Utils.Utils_hisl_0070.isInExcludedBlockList(Object,opt)
        bResult=true;
    elseif isInsideLinkedArea(Object)
        bResult=true;
    elseif Stateflow.SLUtils.isStateflowBlock(get_param(Object,'Handle'))
        bResult=Advisor.Utils.Utils_hisl_0070.isSFObjExcluded_hisl_0070(idToHandle(sfroot,sfprivate('block2chart',get_param(Object,'Handle'))),opt,true);
    elseif Advisor.Utils.Utils_hisl_0070.hasReqs(Object,opt)
        bResult=true;
    elseif strcmp(get_param(Object,'BlockType'),'SubSystem')





        if~(Simulink.internal.isArchitectureModel(bdroot(Object)))
            children=find_system(Object,'LookUnderMasks',opt.lookUnderMask,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',opt.followLinks,'SearchDepth',1,'type','block');
        else

            children=find_system(Object,'LookUnderMasks',opt.lookUnderMask,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',opt.followLinks,'SearchDepth',1,'BlockType','SubSystem');
        end
        children=setdiff(children,Object);
        bResult=~isempty(children);
    else
        bResult=false;
    end
end

function retval=isInsideLinkedArea(block)
    retval=false;
    parent=get_param(block,'Parent');


    area=find_system(parent,'FindAll','on','SearchDepth',1,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'type','annotation','AnnotationType','area_annotation');
    if~isempty(area)
        blockPosition=get_param(block,'Position');
        for idx=1:numel(area)

            if rmi.objHasReqs(area(idx),[])
                areaPosition=get_param(area(idx),'Position');
                if(blockPosition(:,1)>=areaPosition(1)&&blockPosition(:,3)<=areaPosition(3)&&blockPosition(:,2)>=areaPosition(2)&&blockPosition(:,4)<=areaPosition(4))
                    retval=true;
                    return
                end
            end
        end
    end
end