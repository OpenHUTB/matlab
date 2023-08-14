function doTflHwValidation(hTflCtrl,TflStr,HwStr)









    if~isa(hTflCtrl,'RTW.TflControl')
        DAStudio.error('RTW:tfl:inValidTflHwValidationCaller');
    end

    tr=RTW.TargetRegistry.get;
    crls=coder.internal.getCRLs(tr,TflStr);
    if~isempty(crls)
        n=length(crls);
        mainError=[];
        for i=1:n
            Tfl=crls(i);
            errorForLib=loc_validateHW(Tfl,HwStr);
            if~isempty(errorForLib)
                if isempty(mainError)
                    mainError=MSLException('RTW:tfl:CrlHardwareCompatibilityIssues',HwStr);
                end
                mainError=mainError.addCause(errorForLib);
            end
        end
        if~isempty(mainError)
            throw(mainError);
        end
    end

end

function validationError=loc_validateHW(Tfl,HwStr)
    validationError=[];
    if isempty(Tfl)
        return;
    end

    TflSupportedHw=Tfl.TargetHWDeviceType;



    if isempty(TflSupportedHw)||ismember('*',TflSupportedHw)||ismember('',TflSupportedHw)
        return;
    else

        hh=targetrepository.getHardwareImplementationHelper();
        dev=hh.getDevice(HwStr);

        if isempty(dev)
            SelectedHwFullName=HwStr;
        else
            SelectedHwFullName=dev.getQualifiedParameterString();
        end

        for idx=1:length(TflSupportedHw)
            supportedDevice=hh.getDevice(TflSupportedHw{idx});

            if isempty(supportedDevice)

                thisSupportedHwFullName{idx}=TflSupportedHw{idx};%#ok<AGROW>
            else

                thisSupportedHwFullName{idx}=supportedDevice.getQualifiedParameterString();%#ok<AGROW>
            end

            if strcmp(thisSupportedHwFullName{idx},SelectedHwFullName)
                return;
            end
        end
    end


    validationError=MSLException('RTW:tfl:TflHwIncompatible',Tfl.Name,HwStr,...
    sprintf(' \n%s',thisSupportedHwFullName{:}));
end





