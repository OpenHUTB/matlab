function defaultSet=getDefaultInstructionSetExtensions(hwDeviceType,isERT)


    keySet={'Intel->x86-64 (Windows64)','Intel->x86-64 (Linux 64)',...
    'AMD->Athlon 64','AMD->x86-64 (Windows64)','AMD->x86-64 (Linux 64)'};
    valueSet={'SSE2','SSE2','SSE2','SSE2','SSE2'};

    persistent deviceToInstructionSetMap
    if isempty(deviceToInstructionSetMap)
        deviceToInstructionSetMap=containers.Map(keySet,valueSet);
    end

    if isKey(deviceToInstructionSetMap,hwDeviceType)
        defaultSet={deviceToInstructionSetMap(hwDeviceType)};
    else
        [isAvailable,availableInstructionSetsArray]=RTW.getAvailableInstructionSets(hwDeviceType,isERT);
        if isAvailable


            if isMatlabHostComputer(hwDeviceType)
                if ismac
                    defaultSet={'None'};
                elseif ismember('SSE2',availableInstructionSetsArray)
                    defaultSet={'SSE2'};
                else
                    defaultSet=availableInstructionSetsArray(1);
                end
            else
                last=length(availableInstructionSetsArray);
                defaultSet=availableInstructionSetsArray(last);



                defaultSet={'None'};

            end
        else
            defaultSet={};
        end
    end
end
