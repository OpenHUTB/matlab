function success=isOutputPortComplex(this)





    if this.isComplexInputSupported||this.isComplexCoeffSupported
        success=~isreal(this.polyphaseCoefficients)||this.getHDLParameter('filter_complex_inputs');
    else
        success=false;
    end