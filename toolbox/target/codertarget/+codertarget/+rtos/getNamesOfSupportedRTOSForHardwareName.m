function RTOSNames=getNamesOfSupportedRTOSForHardwareName(hwInfo)



    RTOSNames={};
    OSObjs=codertarget.rtos.getSupportedRTOSInfoForHardwareName(hwInfo);
    for i=1:numel(OSObjs)
        RTOSNames{end+1}=OSObjs{i}.Name;%#ok<AGROW>
    end
end


