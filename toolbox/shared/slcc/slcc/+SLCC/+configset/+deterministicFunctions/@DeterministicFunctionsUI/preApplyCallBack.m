function[status,errStr]=preApplyCallBack(this)


    status=true;
    errStr=[];

    allFcns=this.fcnSettingsSS.getAllFunctionEntries();
    try
        this.csCompSrc.set_param('CustomCodeDeterministicFunctions',allFcns);
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
