




function stList=initializeStartListAndSubsystems(obj,subsysH)
    stListLevel0=getSourcesList(subsysH,true);
    stListContext=getSourcesInContext(obj,subsysH);
    stList=[stListLevel0;stListContext];
end

function sources=getSourcesList(subsysH,all)
    stList=Sldv.utils.getBlockHandlesForPortsInSubsys(subsysH);
    constantSrc=find_system(subsysH,'SearchDepth','1','FollowLinks','on','LookUnderMasks','all',...
    'BlockType','Constant');
    dsrSrc=find_system(subsysH,'SearchDepth','1','FollowLinks','on','LookUnderMasks','all',...
    'BlockType','DataStoreRead');

    if all
        sources=getActiveVarientSources([stList;constantSrc;dsrSrc]);
    else
        sources=getActiveVarientSources([constantSrc;dsrSrc]);
    end
end

function sources=getSourcesInContext(obj,subsysH)
    sources=[];
    allSubsys=find_system(subsysH,'SearchDepth','1','FollowLinks','on','LookUnderMasks','all',...
    'BlockType','SubSystem');

    for i=1:length(allSubsys)
        s=allSubsys(i);
        sHdl=get_param(s,'handle');
        if sHdl==subsysH
            continue;
        end
        if checkIfAtomicInlined(obj,sHdl)
            sourcesSelf=getSourcesList(sHdl,false);

            sourcesBelow=getSourcesInContext(obj,sHdl);
            sources=[sources;sourcesSelf;sourcesBelow];
        else
            if isSubsystemStartBlock(sHdl)
                sources=[sources;sHdl];
            end
        end
    end
end

function isStartBlk=isSubsystemStartBlock(subsysH)


    isStartBlk=true;
    if Sldv.ComputeObservable.isVerificationSubSystem(subsysH)
        isStartBlk=false;
        return;
    end
    inports=Sldv.utils.getBlockHandlesForPortsInSubsys(subsysH);
    if~isempty(inports)
        isStartBlk=false;
        return;
    end
end


function isInlined=checkIfAtomicInlined(obj,subsysH)
    isInlined=false;
    ss=Simulink.SubsystemType(subsysH);


    if ss.isAtomicSubsystem()&&...
        ~ss.isStateflowSubsystem()&&...
        ~ss.isInitTermOrResetSubsystem()&&...
        ~ss.isPhysmodSubsystem()&&...
        ~ss.isVariantSubsystem()&&...
        ~ss.isIteratorSubsystem()&&...
        ~Sldv.ComputeObservable.isVerificationSubSystem(subsysH)

        RTWSystemCode=get_param(subsysH,'RTWSystemCode');
        if obj.checkIfAtomicSSToInline(subsysH,RTWSystemCode)
            isInlined=true;
        else
            obj.addToSubSystemQueue(subsysH);
        end
    elseif ss.isActionSubsystem()||...
        ss.isEnabledAndTriggeredSubsystem()||...
        ss.isEnabledSubsystem()||...
        ss.isForEachSubsystem()||...
        ss.isForIteratorSubsystem()||...
        ss.isFunctionCallSubsystem()||...
        ss.isTriggeredSubsystem()||...
        ss.isWhileIteratorSubsystem()||...
        ss.isResettableSubsystem()
        obj.addToSubSystemQueue(subsysH);
    elseif ss.isVirtualSubsystem()
        isInlined=true;
    end
end

function activeSources=getActiveVarientSources(sources)
    activeSources=[];

    for i=1:length(sources)
        isactive=get_param(sources(i),'CompiledIsActive');
        if strcmp(isactive,'on')==1
            if isempty(activeSources)
                activeSources=sources(i);
            else
                activeSources(end+1)=sources(i);
            end
        end
    end
    activeSources=activeSources';
end

