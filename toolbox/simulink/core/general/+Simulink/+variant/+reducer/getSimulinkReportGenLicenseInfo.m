
function[isSRPTCheckedOut,err]=getSimulinkReportGenLicenseInfo()



    [isSRPTCheckedOut,licenseCheckoutErrorMsg]=license('checkout','SIMULINK_Report_Gen');
    err='';
    if~isSRPTCheckedOut
        err=MException('Simulink:Variants:SimRptCheckoutFailed','%s',licenseCheckoutErrorMsg);
    end
end
