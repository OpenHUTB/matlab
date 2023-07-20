function success=isComplexCoeffSupported(this)





    if~strcmpi(this.implementation,'parallel')
        success=false;
    else
        success=true;
    end