function success=isInputPortComplex(this)





    if this.isComplexInputSupported
        success=this.getHDLParameter('filter_complex_inputs');
    else
        success=false;
    end