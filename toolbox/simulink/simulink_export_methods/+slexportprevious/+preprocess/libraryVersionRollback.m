

function libraryVersionRollback(obj)
    aTargetSimulinkRelease=obj.targetVersion.release;


    if simulink_version(aTargetSimulinkRelease)<simulink_version('R2021a')
        return;
    end


    aBlks=obj.findBlocks();




    aLibInfos=libinfo(aBlks,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);


    aLibBlockMap=containers.Map;

    try
        for i=1:length(aLibInfos)
            processLinkedBlock(aLibInfos(i),aLibBlockMap,aTargetSimulinkRelease);
        end
    catch exp
        obj.reportWarning(exp)
    end


    aLibNames=keys(aLibBlockMap);
    for i=1:length(aLibNames)
        aBlks=aLibBlockMap(aLibNames{i});
        for j=3:length(aBlks)






            if obj.ver.isSLX
                obj.appendRule(sprintf('<Block<BlockType|Reference><SID|"%s"><LibraryVersion|"%s":repval "%s">>',...
                aBlks{j},aBlks{1},aBlks{2}));
            elseif obj.ver.isMDL
                obj.appendRule(sprintf('<Block<SID|"%s"><LibraryVersion|"%s":repval "%s">>',...
                aBlks{j},aBlks{1},aBlks{2}));
            end
        end
    end
end

function processLinkedBlock(aLibInfo,aLibBlockMap,aTargetSimulinkRelease)
    aLibName=aLibInfo.Library;
    if isempty(aLibName)
        return;
    end

    if~aLibBlockMap.isKey(aLibName)
        isLibLoaded=bdIsLoaded(aLibName);
        if~isLibLoaded
            load_system(aLibName);
        end

        aCurrentLibVersion=get_param(aLibInfo.Block,'LibraryVersion');

        aModelVersionFormatObj=Simulink.ModelVersionFormat(aLibName);
        aRolledbackLibVersion=aModelVersionFormatObj.rollback(aTargetSimulinkRelease);

        aLibBlockMap(aLibName)={aCurrentLibVersion,aRolledbackLibVersion};

        if~isLibLoaded
            close_system(aLibName);
        end
    end

    aBlocks=aLibBlockMap(aLibName);
    aBlocks{end+1}=get_param(aLibInfo.Block,'SID');
    aLibBlockMap(aLibName)=aBlocks;%#ok<NASGU>
end
