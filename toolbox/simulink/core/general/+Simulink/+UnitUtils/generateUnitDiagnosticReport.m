function generateUnitDiagnosticReport(model)

    ma=Simulink.ModelAdvisor.getModelAdvisor(model);
    CheckIDs={'mathworks.design.UnitMismatches',...
    'mathworks.design.AutoUnitConversions',...
    'mathworks.design.DisallowedUnitSystems',...
    'mathworks.design.UndefinedUnits',...
    'mathworks.design.AmbiguousUnits'};



    setCallBackContextForChecks(ma,CheckIDs,'None');


    oc=onCleanup(@()setCallBackContextForChecks(ma,CheckIDs,'PostCompile'));

    ma.runCheck(CheckIDs);

    ma.displayReport;

end


function setCallBackContextForChecks(ma,checkIDs,callbackContext)

    for i=1:length(checkIDs)
        checkObj=ma.getCheckObj(checkIDs{1,i});
        checkObj.CallbackContext=callbackContext;
    end

end