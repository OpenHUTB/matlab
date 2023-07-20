function[yesno,storage,isDefault]=harnessDiagramHasLinks(harness)


    if ischar(harness)
        if rmisl.isHarnessIdString(harness)
            [~,harness]=rmisl.harnessIdToEditorName(harness);
        end
        harness=get_param(harness,'Handle');
    end

    if rmidata.isExternal(harness)
        [slHs,sfHs]=rmisl.getHarnessObjectsWithReqs(harness);
        if isempty(slHs)&&isempty(sfHs)

            yesno=checkForLinksInCUT(harness);
        else
            yesno=true;
        end
        if nargout>1
            [~,harnessID]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(harness);
            parentModelH=get_param(strtok(harnessID,':'),'Handle');
            [storage,isDefault]=rmimap.StorageMapper.getInstance.getStorageFor(parentModelH);
        end
    else
        [slHs,sfHs]=rmisl.getHandlesWithRequirements(harness);
        yesno=~isempty(slHs)||~isempty(sfHs);
        storage='';
        if nargout>1
            if yesno

                isDefault=~rmi.settings_mgr('get','storageSettings','external');
            else

                isDefault=true;
            end
        end
    end
end


function found=checkForLinksInCUT(harness)
    [~,uniqueID]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(harness);
    [parentName,uuidString]=strtok(uniqueID,':');
    myHarnessInfo=Simulink.harness.find(parentName,'UUID',uuidString(2:end));
    cutObj=get_param(myHarnessInfo.ownerFullPath,'Object');
    itemsToCheck=find(cutObj,'-isa','Simulink.Block');
    for i=1:length(itemsToCheck)
        oneObj=itemsToCheck(i);
        if rmi.objHasReqs(oneObj)
            found=true;return;
        elseif slprivate('is_stateflow_based_block',oneObj.Handle)
            [~,sfFlags,~]=rmisf.getAllObjectsAndRmiFlags(oneObj,[]);
            if any(sfFlags)
                found=true;return;
            end
        end
    end
    found=false;
end


