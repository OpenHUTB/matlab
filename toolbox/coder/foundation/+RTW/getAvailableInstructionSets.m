function[isAvailable,simdInstructionSetsArray]=getAvailableInstructionSets(hwDeviceTypeString,isERT)










    hh=targetrepository.getHardwareImplementationHelper();

    if isMatlabHostComputer(hwDeviceTypeString)
        [isAvailable,simdInstructionSetsArray]=loc_getHostSimdInfo();
    elseif isempty(hwDeviceTypeString)||isempty(hh.getDevice(hwDeviceTypeString))
        [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
    else
        [isAvailable,simdInstructionSetsArray]=loc_getTargetSimdInfo(hwDeviceTypeString);
    end


    if~isERT
        if ismember('SSE2',simdInstructionSetsArray)
            simdInstructionSetsArray={'SSE2'};
        else
            [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
        end
    end
end

function[isAvailable,simdInstructionSetsArray]=loc_getHostSimdInfo()
    hostSimdVersion=getHostSimdVersion();
    if ismac
        [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
    elseif isempty(hostSimdVersion)||strcmp(hostSimdVersion,'None')
        [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
    else
        isAvailable=true;
        repository=targetframework.internal.repository.createTargetRepository();
        highestInstructionSet=repository.get('InstructionSet','Name',hostSimdVersion);
        simdInstructionSetsArray=loc_getSortedInstructionSetExtensions([highestInstructionSet,highestInstructionSet.Prerequisites]);
    end
end

function[isAvailable,simdInstructionSetsArray]=loc_getTargetSimdInfo(hwDeviceTypeString)
    hh=targetrepository.getHardwareImplementationHelper();
    hwDevice=hh.getDevice(hwDeviceTypeString);
    if isa(hwDevice,'target.internal.Processor')
        instructionSetsArchitecture=hwDevice.InstructionSetArchitecture;
        if isempty(instructionSetsArchitecture)||...
            isempty(instructionSetsArchitecture.Extensions)
            [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
            return;
        end
        simdInstructionSetsArray=loc_getSortedInstructionSetExtensions(instructionSetsArchitecture.Extensions);
        isAvailable=~isempty(simdInstructionSetsArray);
    else
        [isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo();
    end
end

function[isAvailable,simdInstructionSetsArray]=loc_getUnavailableInfo()
    unAvailableString='None';
    isAvailable=false;
    simdInstructionSetsArray={unAvailableString};
end

function sortedSimdNameArray=loc_getSortedInstructionSetExtensions(inputInstructionSetArray)

    sortedInstructionSets=target.internal.InstructionSetArchitecture.getSortedInstructionSets(...
    inputInstructionSetArray);


    sortedSimdNameArray=...
    reshape({sortedInstructionSets.Name},length(sortedInstructionSets),1);


    sortedSimdNameArray=flip(sortedSimdNameArray);
end
