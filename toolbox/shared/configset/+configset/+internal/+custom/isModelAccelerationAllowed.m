function[out,dscr]=isModelAccelerationAllowed(~,name)




    dscr=[name,' is not Available in student version'];

    if slInternal('isModelAccelerationAllowed')
        out=configset.internal.data.ParamStatus.Normal;
    else
        out=configset.internal.data.ParamStatus.UnAvailable;
    end

