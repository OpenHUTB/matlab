function newC=elaborateMPSK(this,prm)








    inT=prm.InputSignals.Type;
    inBT=inT.BaseType;
    inrot.re=prm.hN.addSignal2('Name','inphase','Type',inBT);
    inrot.im=prm.hN.addSignal2('Name','quadrature','Type',inBT);
    newC=pirelab.getComplex2RealImag(prm.hN,prm.InputSignals(1),[inrot.re,inrot.im],'real and imag');



    if isfield(prm,'sin3Pi8Phase')


        prm_pi8=struct('hN',prm.hN,'cosInitPhase',prm.cosInitPhase,...
        'sinInitPhase',prm.sinInitPhase,...
        're_name','inphase_pi8_derotated',...
        'im_name','quadrature_pi8_derotated');
        derot_pi8=derotate(this,prm_pi8,inrot);



        prm_3pi8=struct('hN',prm.hN,'cosInitPhase',prm.cos3Pi8Phase,...
        'sinInitPhase',prm.sin3Pi8Phase,...
        're_name','inphase_3pi8_derotated',...
        'im_name','quadrature_3pi8_derotated');

        derot_3pi8=derotate(this,prm_3pi8,inrot);


    else

        derotprm=struct('hN',prm.hN,'cosInitPhase',prm.cosInitPhase,...
        'sinInitPhase',prm.sinInitPhase,...
        're_name','inphase_derotated',...
        'im_name','quadrature_derotated');

        if prm.isPi8
            derot_pi8=inrot;
            derot_3pi8=derotate(this,derotprm,inrot);

        else
            derot_pi8=derotate(this,derotprm,inrot);
            derot_3pi8=inrot;
        end

    end


    compOps={{'re','lt'},{'re','eq'},{'im','lt'},{'im','eq'}};
    quadrant_idx=[1,1,4,1,2,1,4,1,2,3,3,1,1,1,1,1];
    quadrant_mapping=[0,1,2,3];
    qpskLUTvalues=quadrant_mapping(quadrant_idx);
    qpskLUTvalues(6)=0;

    qpskprm=struct('hN',prm.hN,'compOps',{compOps},'LUTvalues',qpskLUTvalues,...
    'decision_name','quadrant_decision');
    quadrant_decision=qpskCompareAndDecide(this,qpskprm,derot_pi8);


    octant_compares=slicerCompares(this,prm.hN,compOps,derot_3pi8);



    LUTvalues=[repmat(0,4,1);
    repmat(1,4,1);
    repmat(1,4,1);
    repmat(1,4,1);
    repmat([2,3,3,3]',4,1);
    repmat(5,4,1);
    repmat(5,4,1);
    repmat(4,4,1);
    repmat(4,4,1);
    repmat([7,7,6,6]',4,1)];

    q0_origin_idx=[6,8,14,16];
    origin_idx=bsxfun(@plus,[0,16,32,48],q0_origin_idx(:));
    origin_idx=origin_idx(:);
    LUTvalues(origin_idx)=0;



    if prm.isGrayCoded
        LUTvalues=comm.internal.utilities.bin2gray(LUTvalues,'psk',prm.M);
    end


    if isfield(prm,'mapping')
        LUTvalues=this.remapLUT(LUTvalues,prm.mapping);
    end

    decision=slicerLUT(this,prm.hN,LUTvalues,[quadrant_decision,octant_compares]);


    outputDTC(this,prm.hN,decision,prm.OutputSignals);

end



