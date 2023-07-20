function newPref=setpref(groupLabel,propertyCells,valueCells)




    if(~strcmpi(groupLabel,'MATLABReleases'))
        stm.internal.setGlobalPreference(groupLabel,propertyCells,valueCells);
        if strcmpi(groupLabel,'ShowSimulationLogs')
            newPref=sltest.testmanager.getpref(groupLabel,propertyCells);
        else
            newPref=sltest.testmanager.getpref(groupLabel);
        end
    else
        idMap=Simulink.sdi.Map(char('?'),int32(0));
        pathMap=Simulink.sdi.Map(char('?'),int32(0));
        usingCrossReleaseMgr=slfeature('CrossReleaseManagerGUI');
        for k=1:length(valueCells)
            if isempty(valueCells{k})
                continue;
            end
            valueCells{k}.MATLABRoot=convertStringsToChars(valueCells{k}.MATLABRoot);
            valueCells{k}.Name=convertStringsToChars(valueCells{k}.Name);
            if pathMap.isKey(valueCells{k}.MATLABRoot)
                error(message('stm:MultipleReleaseTesting:DuplicatesFoundInReleaseList',valueCells{k}.MATLABRoot));
            end
            pathMap.insert(valueCells{k}.MATLABRoot,0);
        end

        currentReleases=stm.internal.getGlobalPreference('release',{'releaselist'});
        for k=1:length(currentReleases)
            if pathMap.isKey(currentReleases(k).MATLABRoot)
                error(message('stm:MultipleReleaseTesting:MatlabVersionAlreadyInList',currentReleases(k).MATLABRoot));
            end

            pathMap.insert(currentReleases(k).MATLABRoot,0);
            idMap.insert(currentReleases(k).Name,k);
        end

        replaceAll=any(strcmpi(propertyCells,'Releaselist'));
        for k=1:length(valueCells)
            if(isempty(valueCells{k})&&~replaceAll)
                locRemoveRelease(propertyCells{k});
                continue;
            end

            name=strip(valueCells{k}.Name);
            if(length(name)>20)
                error(message('stm:MultipleReleaseTesting:ReleaseNameNotValid'));
            end
            loc=strip(valueCells{k}.MATLABRoot);
            selected=valueCells{k}.Selected;

            name=strrep(name,' ','');
            stm.internal.util.validateParameterName(name);
            stm.internal.MRT.utility.checkRootLocation(loc);

            if(idMap.isKey(name))
                idMap.insert(name,0);
                locRemoveRelease(name);
            end
            locAddRelease(name,loc,selected);
        end

        if(replaceAll)
            for k=1:idMap.getCount()
                x=idMap.getDataByIndex(k);
                if(x>0)
                    name=idMap.getKeyByIndex(k);
                    if(~currentReleases(x).IsDefault)
                        locRemoveRelease(name);
                    end
                end
            end
        end

        newPref=sltest.testmanager.getpref(groupLabel,propertyCells);
    end

    function locAddRelease(name,loc,selected)
        if usingCrossReleaseMgr
            Simulink.CoSimServiceUtils.registerMatlab(name,loc);
            Simulink.CoSimServiceUtils.updateReleaseCheckbox(name,selected);
        else
            stm.internal.addRelease(name,loc,selected);
        end
    end

    function locRemoveRelease(name)
        if usingCrossReleaseMgr
            Simulink.CoSimServiceUtils.unregisterMatlab(name);
        else
            stm.internal.removeRelease(name);
        end
    end
end