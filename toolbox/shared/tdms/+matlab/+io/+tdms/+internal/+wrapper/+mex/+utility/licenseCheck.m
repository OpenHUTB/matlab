function licenseCheck()





    if isempty(builtin('license','inuse','Data_Acq_Toolbox'))&&...
        isempty(builtin('license','inuse','Communication_Toolbox'))

        [daqStatus,~]=builtin('license','checkout','Data_Acq_Toolbox');
        if~daqStatus

            [commsStatus,~]=builtin('license','checkout','Communication_Toolbox');
            if~commsStatus


                error(message('tdms:TDMS:LicenseNotFound'));
            end
        end
    end
end