









function status=license(mode,featureName)


    if nargin>0
        mode=convertStringsToChars(mode);
    end

    if nargin>1
        featureName=convertStringsToChars(featureName);
    end

    status=modeladvisorprivate('isInstalled',featureName);

    if status

        status=logical(license(mode,featureName));




        if strcmpi(mode,'checkout')
            if strcmpi(featureName,'rtw_embedded_coder')
                status=status&&license(mode,'MATLAB_Coder');
                status=status&&license(mode,'Real-Time_Workshop');
            elseif strcmpi(featureName,'real-time_workshop')
                status=status&&license(mode,'MATLAB_Coder');
            end
        end
    end
end
