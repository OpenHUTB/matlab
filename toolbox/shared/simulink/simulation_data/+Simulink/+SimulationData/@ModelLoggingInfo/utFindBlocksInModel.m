function[blks,findSysError]=utFindBlocksInModel(model,...
    variantOpt,...
    commentOpt,...
    linksOpt,...
    maskOpt,...
    bAllSubsystems,...
    blkType)











    args={'IncludeCommented',commentOpt...
    ,'FollowLinks',linksOpt...
    ,'LookUnderMasks',maskOpt};
    if Simulink.internal.useFindSystemVariantsMatchFilter()



        if(strcmp(variantOpt,'ActiveVariants'))
            args=[args,{'MatchFilter'},{@Simulink.match.activeVariants}];
        elseif(strcmp(variantOpt,'AllVariants'))
            args=[args,{'MatchFilter'},{@Simulink.match.allVariants}];
        end
    else
        args=[args,{'Variants'},{variantOpt}];
    end
    if~bAllSubsystems
        args=[args,{'SearchDepth',1}];
    end


    if nargin<7
        args=[args,{'Type','block'}];
    else
        args=[args,{'BlockType',blkType}];
    end

    findSysError=[];
    try
        blks=find_system(model,args{:});
    catch me
        blks={};
        findSysError=me;
    end
end
