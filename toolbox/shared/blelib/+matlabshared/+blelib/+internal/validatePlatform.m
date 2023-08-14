function validatePlatform





    if~(ispc||ismac)
        matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:unsupportedPlatform');
    end


    if ispc
        [status,result]=system('ver');
        if status==0




            version=regexp(result,'(?<=.*Version )\d*(?=\..*)','match');
            if~isempty(version)&&(str2double(version)<10)
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:unsupportedWindows');
            end
        end


        windowsVer=system_dependent('getos');


        version=regexp(windowsVer,'\d*','match');
        if str2double(version)==11
            matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:unsupportedWindows11');
        end
    end
end
