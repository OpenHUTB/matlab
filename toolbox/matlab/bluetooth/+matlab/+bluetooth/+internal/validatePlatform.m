function validatePlatform

    if~(ispc||ismac)
        id="MATLAB:bluetooth:common:unsupportedPlatform";
        throwAsCaller(MException(id,getString(message(id))));
    end

    if ispc
        [status,result]=system("ver");
        if status==0

            version=regexp(result,"(?<=.*Version )\d*(?=\..*)","match");
            if~isempty(version)&&(str2double(version)<10)
                matlabshared.blelib.internal.localizedError("MATLAB:bluetooth:common:unsupportedWindows");
            end
        end
    end
end