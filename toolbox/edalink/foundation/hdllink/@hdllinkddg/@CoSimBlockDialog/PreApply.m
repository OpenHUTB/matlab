function[status,errMsg]=PreApply(this,dialog)






    status=true;
    errMsg='';

    if(this.PortTableSource.NumRows<=0)
        status=false;
        errMsg='Must have at least one input or output port on cosimulation block.';
    end



    if status
        this.SourcesToMaskParams;
        [status,errMsg]=this.preApplyCallback(dialog);
    end


































