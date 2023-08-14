function list=filterNonReportableSystem(list)









    allBadTypes={
    {'MaskType','Stateflow',false}
    {'MaskType','Sigbuilder block',true}
    {'MaskHideContents','on',true}
    {'Opaque','on',true}
    };

    for i=1:length(allBadTypes)
        bad=find_system(list,...
        'SearchDepth',0,...
        allBadTypes{i}{1},allBadTypes{i}{2});

        if~isempty(bad)&&(allBadTypes{i}{3})



            bad=find_system(bad,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all',...
            'FollowLinks','on');
        end




        normalizedList=find_system(list,'SearchDepth',0);

        badInList=intersect(normalizedList,bad);
        [~,keep]=setdiff(normalizedList,badInList);
        list=list(keep);
    end



    filterout=[];


    ss=substruct('()',{});
    if iscell(list)
        ss=substruct('{}',{});
    end

    for i=1:length(list)
        ss.subs={i};
        system=subsref(list,ss);



        systemChild=find_system(system,'SearchDepth',1,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
        if length(systemChild)==1&&...
            (~strcmp(get_param(system,'Type'),'block_diagram')&&~isempty(get_param(system,'OpenFcn')))&&...
            ~strcmp(get_param(system,'MaskType'),'VerificationSubsystem')
            filterout=[filterout,i];%#ok
        end
    end


    list(filterout)=[];
