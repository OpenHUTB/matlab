function getPol2CartCordicComp(hN,hInSignals,hOutSignals,cordicInfo)











    magnitude=hInSignals(1);
    angle=hInSignals(2);
    sin=hOutSignals(1);
    cos=hOutSignals(2);
    inputType=angle.type;



    intermWL=inputType.WordLength;
    intermFL=intermWL-2;
    intermDT=numerictype(1,intermWL,intermFL);
    intermType=pir_sfixpt_t(intermWL,-intermFL);


    ufix1Type=pir_ufixpt_t(1,0);
    lutValues=cordicInfo.lutValue;

    angle_ex=pirelab.getTypeInfoAsFi(inputType);
    intermFimath=eml_al_cordic_fimath(angle_ex);
    K=fi(cordicInfo.scaleFactor,1,intermWL,intermFL,intermFimath);



    z0=hN.addSignal(intermType,'z0');
    negate=hN.addSignal(ufix1Type,'negate');
    tOutSignals=[negate,z0];
    hdlarch.cordic.getCordicQuadCorrectionBeforeComp(hN,angle,tOutSignals,K);


    z0_p=hN.addSignal(intermType,'z0_p');
    d1C=pirelab.getUnitDelayComp(hN,z0,z0_p,'z0_reg');
    d1C.addComment('Pipeline registers');

    negate_p=hN.addSignal(ufix1Type,'negate_p');
    pirelab.getIntDelayComp(hN,negate,negate_p,cordicInfo.iterNum+1,'negate_reg');



    x0=hN.addSignal(intermType,'x0');
    y0=hN.addSignal(intermType,'y0');


    pirelab.getConstComp(hN,x0,K);
    pirelab.getConstComp(hN,y0,0);


    tInSignals=[x0,y0,z0_p];
    for stageNum=1:cordicInfo.iterNum


        x=hN.addSignal(intermType,sprintf('x%d',stageNum));
        y=hN.addSignal(intermType,sprintf('y%d',stageNum));
        z=hN.addSignal(intermType,sprintf('z%d',stageNum));
        tOutSignals=[x,y,z];


        lut_value=fi(lutValues(stageNum),intermDT,intermFimath);


        hdlarch.cordic.getCordicKernelComp(hN,tInSignals,tOutSignals,lut_value,uint8(stageNum));


        x_p=hN.addSignal(intermType,sprintf('x%d_p',stageNum));
        y_p=hN.addSignal(intermType,sprintf('y%d_p',stageNum));
        d2C=pirelab.getUnitDelayComp(hN,x,x_p,'x_reg');
        d2C.addComment('Pipeline registers');
        pirelab.getUnitDelayComp(hN,y,y_p,'y_reg');
        if stageNum~=cordicInfo.iterNum
            z_p=hN.addSignal(intermType,sprintf('z%d_p',stageNum));
            pirelab.getUnitDelayComp(hN,z,z_p,'z_reg');
        else
            z_p=z;
        end


        tInSignals=[x_p,y_p,z_p];
    end


    xout=hN.addSignal(intermType,'xout');
    yout=hN.addSignal(intermType,'yout');
    tInSignals=[x_p,y_p,negate_p];
    tOutSignals=[xout,yout];
    hdlarch.cordic.getCordicQuadCorrectionAfterComp(hN,tInSignals,tOutSignals);


    mag_delayed=hN.addSignal(magnitude.Type,'mag_delayed');
    pirelab.getIntDelayComp(hN,magnitude,mag_delayed,cordicInfo.iterNum+1,'mag_delay');

    pirelab.getMulComp(hN,[xout,mag_delayed],sin,'Floor','Wrap','magMulSin');
    pirelab.getMulComp(hN,[yout,mag_delayed],cos,'Floor','Wrap','magMulCos');
end


function cordicFimath=eml_al_cordic_fimath(angle)




    if isfloat(angle)


        eml_assert(0);
    else


        angleType=numerictype(angle);
        ioWordLength=angleType.WordLength;
        ioFracLength=ioWordLength-2;




        cordicFimath=fimath('SumMode','SpecifyPrecision',...
        'SumWordLength',ioWordLength,...
        'SumFractionLength',ioFracLength,...
        'RoundMode','floor',...
        'OverflowMode','wrap'...
        );
    end
end


