function[status,errStr]=preApplyCallBack(this)


    status=true;
    errStr=[];

    allFcnMajorityEntries=this.fcnSettingsSS.getAllFuncionMajorityEntries();
    try
        this.csCompSrc.set_param('CustomCodeFunctionArrayLayout',allFcnMajorityEntries);
    catch e
        status=false;
        errStr=e.message;
    end

    if~status
        return;
    end

    this.thisDlg.enableApplyButton(false,false);


    if this.enableApplyOnParentUponApply
        this.parentDlg.enableApplyButton(true,false);
        this.enableApplyOnParentUponApply=false;
    end
end
