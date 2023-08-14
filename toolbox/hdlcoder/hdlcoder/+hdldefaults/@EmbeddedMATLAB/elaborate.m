function hNewC=elaborate(this,hN,hC)


    if useML2PIR(this,hC)
        hNewC=hdldefaults.MATLABDatapath.ml2pirElaborate(this,hN,hC);
    else
        hNewC=baseSFElaborate(this,hN,hC);
    end

end

