function signalObservers=getSignalObserversForModel(allMdls,allBlockHandles,synthBlkHMap)





    import Analysis.*;

    isNewBackend=slfeature('NewSlicerBackend');

    observerSinks=getSignalObservers();

    nSignalObserver=int32(0);
    signalObserversHandles=zeros(1,1000);

    for i=1:length(allBlockHandles)
        handle=allBlockHandles(i);
        blkObj=get(handle,'Object');

        if strcmp(blkObj.type,'block')&&...
            (isNewBackend||~isempty(blkObj.RuntimeObject))

            bt=blkObj.BlockType;

            if find(strcmp(observerSinks.BlockType,bt))
                nSignalObserver=nSignalObserver+1;
                signalObserversHandles(nSignalObserver)=handle;
            end
        end
    end


    observerSubsys=[];
    for d=1:length(observerSinks.Subsystem)


        subsys=find_system(allMdls,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on',...
        'ReferenceBlock',sprintf(observerSinks.Subsystem{d}));
        if(~isempty(subsys))
            observerSubsys=cat(2,observerSubsys,subsys');
        end
    end

    for d=1:length(observerSinks.Masktype)


        subsys=find_system(allMdls,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on',...
        'MaskType',sprintf(observerSinks.Masktype{d}));
        if(~isempty(subsys))
            observerSubsys=cat(2,observerSubsys,subsys');
        end
    end

    for o=1:length(observerSubsys)
        nSignalObserver=nSignalObserver+1;
        signalObserversHandles(nSignalObserver)=observerSubsys(o);


        children=find_system(observerSubsys(o),'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on','type','block');
        children(children==observerSubsys(o))=[];
        nChildren=numel(children);
        signalObserversHandles((nSignalObserver+1):...
        (nSignalObserver+nChildren))=children;
        nSignalObserver=nSignalObserver+nChildren;
    end




    if~isNewBackend&&nargin==3






        synthBlks=synthBlkHMap.values;
        synthBlks=[synthBlks{:}];
        for i=1:length(synthBlks)
            toAdd=false;
            synthBlkPath=getfullname(synthBlks(i));
            blkLength=length(synthBlkPath);
            for o=1:length(observerSubsys)
                obsSysPath=getfullname(observerSubsys(o));
                sysLength=length(obsSysPath);
                if(sysLength>=blkLength)
                    continue;
                end

                if strcmp(obsSysPath,synthBlkPath(1:sysLength))
                    toAdd=true;
                    break;
                end
            end
            if toAdd
                nSignalObserver=nSignalObserver+1;
                signalObserversHandles(nSignalObserver)=synthBlks(i);
            end
        end

    end

    signalObserversHandles=signalObserversHandles(1:nSignalObserver);
    signalObservers=intersect(signalObserversHandles,allBlockHandles);
end
