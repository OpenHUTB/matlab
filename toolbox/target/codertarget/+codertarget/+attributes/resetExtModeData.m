function resetExtModeData(hObj)





    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if codertarget.attributes.getAttribute(hObj,'EnableOneClick')
        lExtmodeInfo=targetInfo.ExternalModeInfo;
        try
            if~isempty(lExtmodeInfo)


                connectionInfo=codertarget.attributes.getConnectionInfo(hObj);
                codertarget.data.setParameterValue(hObj,'ConnectionInfo',connectionInfo);

                if codertarget.data.isParameterInitialized(hObj,'ExtMode.Configuration')
                    configuration=codertarget.data.getParameterValue(hObj,'ExtMode.Configuration');
                else
                    if numel(lExtmodeInfo)>0

                        configuration=lExtmodeInfo(1).Transport.IOInterfaceName;
                    else
                        configuration='';
                    end
                end
                codertarget.data.setParameterValue(hObj,'ExtMode','');
                codertarget.data.setParameterValue(hObj,'ExtMode.Configuration',configuration);
            end
        catch e

            MSLDiagnostic('codertarget:build:ErrorResetingExtModeData',targetName,e.message).reportAsWarning;
        end
    end
end