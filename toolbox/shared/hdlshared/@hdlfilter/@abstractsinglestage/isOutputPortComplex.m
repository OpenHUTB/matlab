function success=isOutputPortComplex(this)




    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if this.isComplexInputSupported||this.isComplexCoeffSupported
        if emitMode
            success=~isreal(this.Coefficients)||this.getHDLParameter('filter_complex_inputs');
        else
            success=~isreal(this.Coefficients)||this.InputComplex(1);
        end
    else
        success=false;
    end
