function cleanEmbeddedLinks(objList)







    for i=1:length(objList)
        if~isempty(objList{i})
            stripEmbeddedLinks(objList{i});
        end
    end
end

function stripEmbeddedLinks(objs)
    if isa(objs,'double')
        stripEmbeddedGivenHandles(objs);
    else
        stripEmbeddedGivenSIDs(objs);
    end
end

function stripEmbeddedGivenHandles(objs)
    for i=1:length(objs)
        stripOneObject(objs(i));
    end
end

function stripOneObject(obj)
    [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);


    GUID=rmi.guidGet(objH);
    reqstr=['{} %',GUID];


    rmi.setRawReqs(objH,isSf,reqstr,modelH);

    if isSigBuilder


        fromWsH=find_system(objH,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'BlockType','FromWorkspace');
        blkInfo=get_param(fromWsH,'VnvData');
        if~isempty(blkInfo)&&~isempty(blkInfo.groupCnt)&&~isempty(blkInfo.groupReqCnt)
            blkInfo.groupReqCnt=zeros(1,blkInfo.groupCnt);
            if~strcmp(get_param(fromWsH,'StaticLinkStatus'),'implicit')
                set_param(fromWsH,'VnvData',blkInfo);
            end
        end
    end
end

function stripEmbeddedGivenSIDs(objs)
    diagName=objs{1};
    ownerPath=objs{2};
    if~isempty(ownerPath)

        Simulink.harness.open(ownerPath,diagName,'CreateOpenContext',true,'ReuseWindow',true);
    end
    for i=3:length(objs)
        obj=Simulink.ID.getHandle(objs{i});
        stripOneObject(obj);
    end


    set_param(diagName,'HasReqInfo','off');
    if~isempty(ownerPath)
        systemBD=bdroot(ownerPath);
        if Simulink.harness.internal.isSavedIndependently(systemBD)





            save_system(systemBD);

            save_system(diagName);
        end
        Simulink.harness.close(ownerPath,diagName);
    end
end
