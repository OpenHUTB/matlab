function[status,errMsg]=preApply(this,dialog)






    status=true;
    errMsg='';





    if status
        [status,errMsg]=this.preApplyCallback(dialog);
    end

