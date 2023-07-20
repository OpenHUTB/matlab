function newC=elaborateBPSK(this,prm)







    [derot,prm,newC]=bpskDerotate(this,prm,prm.InputSignals(1));


    compout_sig=slicerCompares(this,prm.hN,prm.compOps,derot);


    decision=slicerLUT(this,prm.hN,prm.LUTvalues,compout_sig);


    outputDTC(this,prm.hN,decision,prm.OutputSignals);


end



function[derot,prm,newC]=bpskDerotate(this,prm,insignal)




    if isfield(prm,'sinInitPhase')

        [derot,newC]=this.derotate(prm,insignal);
        prm.LUTvalues=[0,0,1,0,1,1,1,0];
        prm.compOps={{'re','lt'},{'re','eq'},{'im','eq'}};
    else




        switch find(prm.phaseBins==1)
        case 1
            prm.LUTvalues=[0,0,1,0,1,1,1,0];
            prm.compOps={{'re','lt'},{'re','eq'},{'im','eq'}};
        case 2
            prm.LUTvalues=[0,1,0,0,1,1,1,0];
            prm.compOps={{'im','lt'},{'re','eq'},{'im','eq'}};
        case 3
            prm.LUTvalues=[1,1,1,0,0,0,0,1];
            prm.compOps={{'re','lt'},{'re','eq'},{'im','eq'}};
        case 4
            prm.LUTvalues=[1,1,1,0,0,0,0,0];
            prm.compOps={{'im','lt'},{'re','eq'},{'im','eq'}};
        end


        inT=prm.InputSignals.Type;
        inBT=inT.BaseType;
        derot.re=prm.hN.addSignal2('Name','inphase','Type',inBT);
        derot.im=prm.hN.addSignal2('Name','quadrature','Type',inBT);
        newC=pirelab.getComplex2RealImag(prm.hN,prm.InputSignals(1),[derot.re,derot.im],'real and imag');

    end


    if isfield(prm,'mapping')
        prm.LUTvalues=this.remapLUT(prm.LUTvalues,prm.mapping);
    end


end
