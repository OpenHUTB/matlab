function[success,msg]=SuppGenSLTBForComplex(this)






    if this.isInputPortComplex||this.isOutputPortComplex
        success=false;
        msg='Generation of cosimulation model is not supported for complex data or complex coefficients.';
    else
        success=true;
        msg='';
    end


