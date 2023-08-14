function newC=elaborateQPSK(this,prm)







    [derot,prm,newC]=qpskDerotate(this,prm,prm.InputSignals(1));

    prm.decision_name='hardDecision';
    decision=qpskCompareAndDecide(this,prm,derot);


    outputDTC(this,prm.hN,decision,prm.OutputSignals);

end



function[derot,prm,newC]=qpskDerotate(this,prm,insignal)




    prm.compOps={{'re','lt'},{'re','eq'},{'im','lt'},{'im','eq'}};
    quadrant_idx=[1,1,4,1,2,1,4,1,2,3,3,1,1,1,1,1];


    if isfield(prm,'sinInitPhase')

        [derot,newC]=this.derotate(prm,insignal);
        quadrant_mapping=[0,1,2,3];
    else




        switch find(prm.phaseBins==1)
        case 1
            quadrant_mapping=[0,1,2,3];
        case 2
            quadrant_mapping=[3,0,1,2];
        case 3
            quadrant_mapping=[2,3,0,1];
        case 4
            quadrant_mapping=[1,2,3,0];
        end


        inT=prm.InputSignals.Type;
        inBT=inT.BaseType;
        derot.re=prm.hN.addSignal2('Name','inphase','Type',inBT);
        derot.im=prm.hN.addSignal2('Name','quadrature','Type',inBT);
        newC=pirelab.getComplex2RealImag(prm.hN,prm.InputSignals(1),[derot.re,derot.im],'real and imag');
    end


    prm.LUTvalues=quadrant_mapping(quadrant_idx);
    prm.LUTvalues(6)=0;




    if prm.isGrayCoded
        prm.LUTvalues=comm.internal.utilities.bin2gray(prm.LUTvalues,'psk',prm.M);
    end


    if isfield(prm,'mapping')
        prm.LUTvalues=this.remapLUT(prm.LUTvalues,prm.mapping);
    end

end
