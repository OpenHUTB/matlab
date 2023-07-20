function[adjList,adjHandles]=getBlocksOnlyGraphFromSubsystem(system,blockOnly)










    if nargin==1
        blockOnly=true;
    end


    adjList=[];
    adjHandles=[];

    if~isnumeric(system)
        system=get_param(system,'handle');
    end



    allblks=find_system(system,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'SearchDepth',1,'FindAll','on','type','block');
    if isempty(allblks)
        return;
    end

    allblks=setdiff(allblks,system);

    if isempty(allblks)
        return;
    end


    allsigs=find_system(system,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'SearchDepth',1,'FindAll','on','type','line');

    if blockOnly
        entities=allblks;
    else
        entities=[allblks;allsigs];
    end

    adjMat=zeros(length(entities));

    for i=1:length(allsigs)
        o=get_param(allsigs(i),'object');


        if isempty(o.SrcBlockHandle)||isempty(o.DstBlockHandle)
            continue;
        else
            fromPos=ismember(entities,o.SrcBlockHandle);
            toPos=ismember(entities,o.DstBlockHandle);
            if blockOnly
                adjMat(fromPos,toPos)=1;
            else
                adjMat(fromPos,ismember(entities,allsigs(i)))=1;
                adjMat(ismember(entities,allsigs(i)),toPos)=1;
            end
        end
    end

    adjList=sparse(adjMat);
    adjHandles=entities;
end
