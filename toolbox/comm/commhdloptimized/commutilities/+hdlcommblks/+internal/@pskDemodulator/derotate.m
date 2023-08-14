function[derot,newC]=derotate(this,prm,insig)








    cosphase=prm.cosInitPhase;
    sinphase=prm.sinInitPhase;

    if isfield(prm,'re_name')
        re_name=prm.re_name;
    else
        re_name='inphase_derotated';
    end

    if isfield(prm,'im_name')
        im_name=prm.im_name;
    else
        im_name='quadrature_derotated';
    end

    if~isstruct(insig)
        inT=insig.Type;
        inBT=inT.BaseType;

        insigre=prm.hN.addSignal2('Name','inphase','Type',inBT);
        insigim=prm.hN.addSignal2('Name','quadrature','Type',inBT);
        pirelab.getComplex2RealImag(prm.hN,insig,[insigre,insigim],'real and imag');
    else
        insigre=insig.re;
        insigim=insig.im;
        inBT=insigre.Type;
    end

    derot.re=prm.hN.addSignal2('Name','inphase_derotated','Type',inBT);
    derot.im=prm.hN.addSignal2('Name','quadrature_derotated','Type',inBT);


    reps(1)=prm.hN.addSignal2('Name',[re_name,'_CosAddend'],'Type',inBT);
    reps(2)=prm.hN.addSignal2('Name',[im_name,'_SinAddend'],'Type',inBT);
    imps(1)=prm.hN.addSignal2('Name',[re_name,'_SinAddend'],'Type',inBT);
    imps(2)=prm.hN.addSignal2('Name',[im_name,'_CosAddend'],'Type',inBT);


    newC=pirelab.getGainComp(prm.hN,insigre,reps(1),cosphase,1,0,'nearest','saturate');
    pirelab.getGainComp(prm.hN,insigim,imps(1),sinphase,1,0,'nearest','saturate');

    pirelab.getGainComp(prm.hN,insigre,reps(2),sinphase,1,0,'nearest','saturate');
    pirelab.getGainComp(prm.hN,insigim,imps(2),cosphase,1,0,'nearest','saturate');



    pirelab.getAddComp(prm.hN,[reps(1),imps(1)],derot.re,'nearest','saturate');
    pirelab.getSubComp(prm.hN,[imps(2),reps(2)],derot.im,'nearest','saturate');


end

