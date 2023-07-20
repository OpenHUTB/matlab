function lics=checkoutLicensesForSlbuild(targetType,isAccel,isRaccel,mdl,topOfBuildModel)





    persistent simulinkcoder_installed;













    if isempty(simulinkcoder_installed)
        tmp=coder.make.internal.cachedVer('simulinkcoder');
        simulinkcoder_installed=~isempty(tmp);
    end

    stf=get_param(mdl,'SystemTargetFile');

    isSimulinkTarget=isequal(stf,'realtime.tlc')||...
    (codertarget.target.isCoderTarget(mdl)&&slfeature('UnifiedTargetHardwareSelection'));

    isFMUTarget=isequal(stf,'fmu2cs.tlc');

    opCountMode=get_param(mdl,'OpCountcollection');
    isOpCountCollectionOn=strcmp(opCountMode,'on');

    if(isequal(targetType,'SIM')||...
        isAccel||...
        isRaccel||...
        isSimulinkTarget||isOpCountCollectionOn)


        lics=[];
        return;
    elseif isFMUTarget

        [m,errmsg]=builtin('license','checkout','Simulink_Compiler');
        if~m
            ex=MSLException([],...
            message('Simulink:utility:invalidSimulinkCompilerLicenseForFMU'));
            ex=ex.addCause(MException('SimulinkCompiler:LicenseCheckoutError','%s',errmsg));
            throwAsCaller(ex);
        end


        fmuGlobalSettings=coder.internal.fmuexport.getSetFMUSetting;
        if slsvTestingHook('FMUExportTestingMode')==0&&...
            (~fmuGlobalSettings.isKey([topOfBuildModel,'.CalledFromExportedToFMU2CS'])&&...
            isempty(get_param(gcs,'ProtectedModelCreator')))
            DAStudio.error('FMUExport:FMU:InvalidSlbuildForFMUExport');
        end
        lics={'Simulink_Compiler'};
        return;
    elseif~simulinkcoder_installed

        DAStudio.error('Simulink:utility:SimulinkCoderNotInstalled');
    elseif(builtin('_license_checkout','Real-Time_Workshop','quiet')~=0)



        DAStudio.error('Simulink:utility:invalidRTWLicense');
    end
    lics={'MATLAB_Coder','Real-Time_Workshop'};
end
