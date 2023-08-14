function bResult=isObjExcluded_hisl_0070(Object,opt)

    objHandle=-1;
    if isnumeric(Object)
        objHandle=Object;
        obj=get_param(Object,'Object');
        Object=obj.getFullName();
    else
        objHandle=Object.Handle;
        Object=Object.getFullName();
    end







    bResult=Advisor.Utils.Utils_hisl_0070.isInExcludedBlockList(objHandle,opt);
    if bResult
        return;
    end








    if opt.link2ContainerOnly




        if strcmp(get_param(objHandle,'Type'),'annotation')
            childBlks=Advisor.Utils.Utils_hisl_0070.getChildOfAnnotation(objHandle,opt);
        else


            childBlks=find_system(Object,'LookUnderMasks',opt.lookUnderMask,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',opt.followLinks,'SearchDepth',1,'type','block');
            childBlks=setdiff(childBlks,Object);
            if Simulink.internal.isArchitectureModel(bdroot(Object))
                Fcnhdl=@(childBlk)Advisor.Utils.Utils_hisl_0070.isInExcludedBlockList(childBlk,opt);
                flag=cellfun(Fcnhdl,childBlks);
                if all(flag)
                    childBlks=[];
                end
            end

        end

        if isempty(childBlks)


            bResult=~(Simulink.internal.isArchitectureModel(bdroot(Object)));
        else
            bIsContainerExempt=true;
            for i=1:numel(childBlks)

                bIsContainerExempt=bIsContainerExempt&&Advisor.Utils.Utils_hisl_0070.isConditionallyExempt(childBlks{i},opt);
                if bIsContainerExempt==false
                    break;
                end
            end
            if~bIsContainerExempt
                bResult=false;
            else
                bResult=true;
            end
        end
    else
        bIsHiddenSFSL=~strcmp(get_param(Object,'BlockType'),'SubSystem')&&Advisor.Utils.isSFChart(get_param(get_param(Object,'Parent'),'Handle'));

        bResult=Advisor.Utils.Utils_hisl_0070.hasReqs(Object,opt)||bIsHiddenSFSL;
    end
end



