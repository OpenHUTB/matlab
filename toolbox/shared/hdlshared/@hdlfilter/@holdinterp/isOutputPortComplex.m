function success=isOutputPortComplex(this)





    if this.isComplexInputSupported
        success=this.getHDLParameter('filter_complex_inputs');
    else
        success=false;
    end