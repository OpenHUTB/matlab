function success=isOutputPortComplex(this)





    if this.isInputPortComplex||this.nco.isOutputPortComplex
        success=true;
    else
        success=false;
    end

