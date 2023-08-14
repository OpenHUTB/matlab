function success=isInputPortComplex(this)




    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if this.isComplexInputSupported
        if emitMode
            success=this.getHDLParameter('filter_complex_inputs');
        else
            success=this.InputComplex(1);
        end
    else
        success=false;
    end
