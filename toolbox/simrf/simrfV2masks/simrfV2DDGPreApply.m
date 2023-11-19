function[status,errMsg]=simrfV2DDGPreApply(blockObj,dlg)

    errMsg=blockObj.validateChanges(dlg);

    if isempty(errMsg)
        [status,errMsg]=blockObj.preApplyCallback(dlg);
    else
        status=false;
    end
