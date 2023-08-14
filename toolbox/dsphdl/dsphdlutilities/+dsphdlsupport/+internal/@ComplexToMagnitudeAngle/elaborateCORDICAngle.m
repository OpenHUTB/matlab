function resetIn=elaborateCORDICAngle(this,topNet,blockInfo,validNet,validIn,validOut)












    inSignals=topNet.PirInputSignals;

    In=inSignals(1);

    hTin=topNet.getType('FixedPoint',...
    'Signed',In.Type.BaseType.Signed,...
    'WordLength',((In.Type.BaseType.WordLength)),...
    'FractionLength',((In.Type.BaseType.FractionLength)));

    real=topNet.addSignal2('Type',hTin,'Name','real');
    imag=topNet.addSignal2('Type',hTin,'Name','imag');
    imag.SimulinkRate=In.SimulinkRate;



    if isa(In.Type,'hdlcoder.tp_complex')
        inp={real,imag};
        pirelab.getComplex2RealImag(topNet,In,inp);
    else
        pirelab.getWireComp(topNet,In,real);
        pirelab.getConstComp(topNet,imag,0,'c');
    end

    dataRate=real.SimulinkRate;




    if strcmpi(blockInfo.NumIterationsSource,'Auto')
        blockInfo.NIters=((hTin.WordLength)-1);
    else
        blockInfo.NIters=blockInfo.NumIterations;
    end





    if In.Type.BaseType.Signed==1


        hTm=topNet.getType('FixedPoint',...
        'Signed',1,...
        'WordLength',((In.Type.BaseType.WordLength)+1),...
        'FractionLength',((In.Type.BaseType.FractionLength)));

    else
        hTm=topNet.getType('FixedPoint',...
        'Signed',1,...
        'WordLength',((In.Type.BaseType.WordLength)+2),...
        'FractionLength',((In.Type.BaseType.FractionLength)));

    end


    if strcmpi(blockInfo.AngleFormat,'Radians')


        hTa=topNet.getType('FixedPoint',...
        'Signed',1,...
        'Wordlength',((In.Type.BaseType.WordLength)+3),...
        'FractionLength',-(((In.Type.BaseType.WordLength))));

        lutT=topNet.getType('FixedPoint',...
        'Signed',0,...
        'Wordlength',((In.Type.BaseType.WordLength)),...
        'FractionLength',-(((In.Type.BaseType.WordLength))));

        zType=topNet.getType('FixedPoint',...
        'Signed',1,...
        'Wordlength',((In.Type.BaseType.WordLength)+1),...
        'FractionLength',-(((In.Type.BaseType.WordLength))));


    else


        NormalizeStep=pi/(2^((In.Type.BaseType.WordLength)+2));

        hTa=topNet.getType('FixedPoint',...
        'Signed',1,...
        'Wordlength',((In.Type.BaseType.WordLength)+3),...
        'FractionLength',-(((In.Type.BaseType.WordLength)))-2);

        lutT=topNet.getType('FixedPoint',...
        'Signed',0,...
        'Wordlength',((In.Type.BaseType.WordLength)),...
        'FractionLength',-(((In.Type.BaseType.WordLength)+2)));

        zType=topNet.getType('FixedPoint',...
        'Signed',1,...
        'Wordlength',((In.Type.BaseType.WordLength)+3),...
        'FractionLength',-(((In.Type.BaseType.WordLength)+2)));


    end

    concatT=topNet.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',3,...
    'FractionLength',0);

    booleanT=topNet.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',1,...
    'FractionLength',0);

    booleanTwo=topNet.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',2,...
    'FractionLength',0);

    shiftT=topNet.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',(ceil(log2(blockInfo.NIters)))+1,...
    'FractionLength',0);


    outSignals=topNet.PirOutputSignals;
    angle=outSignals(1);




    xC=cell(1,(blockInfo.NIters)+2);
    yC=cell(1,(blockInfo.NIters)+2);
    zC=cell(1,(blockInfo.NIters)+2);

    xCD=cell(1,(blockInfo.NIters)+2);
    yCD=cell(1,(blockInfo.NIters)+2);
    zCD=cell(1,(blockInfo.NIters)+2);


    for ii=1:1:(blockInfo.NIters+2)

        xC{ii}=topNet.addSignal2('Type',hTm,'Name',['xout',num2str(ii)]);
        yC{ii}=topNet.addSignal2('Type',hTm,'Name',['yout',num2str(ii)]);
        zC{ii}=topNet.addSignal2('Type',zType,'Name',['zout',num2str(ii)]);
        xC{ii}.SimulinkRate=In.SimulinkRate;
        yC{ii}.SimulinkRate=In.SimulinkRate;
        zC{ii}.SimulinkRate=In.SimulinkRate;

        xCD{ii}=topNet.addSignal2('Type',hTm,'Name',['xin',num2str(ii)]);
        yCD{ii}=topNet.addSignal2('Type',hTm,'Name',['yin',num2str(ii)]);
        zCD{ii}=topNet.addSignal2('Type',zType,'Name',['zin',num2str(ii)]);
        xCD{ii}.SimulinkRate=In.SimulinkRate;
        yCD{ii}.SimulinkRate=In.SimulinkRate;
        zCD{ii}.SimulinkRate=In.SimulinkRate;


    end


    concatV=topNet.addSignal2('Type',concatT,'Name','ControlQC');


    sigInfo.absdatatype=hTm;
    sigInfo.angdatatype=hTa;
    sigInfo.booleanT=booleanT;
    sigInfo.booleanTwo=booleanTwo;
    sigInfo.concatT=concatT;
    sigInfo.shiftT=shiftT;
    sigInfo.hTin=hTin;
    sigInfo.lutT=lutT;
    sigInfo.zType=zType;
    sigInfo.roundm='Floor';
    sigInfo.satm='Saturate';




    QuadrantBFnet=this.elabQuadrantMapper(...
    topNet,sigInfo,blockInfo,dataRate);

    real_in=topNet.addSignal2('Type',hTm,'Name','qMapReal');
    imag_in=topNet.addSignal2('Type',hTm,'Name','qMapImag');
    real_in.SimulinkRate=In.SimulinkRate;
    imag_in.SimulinkRate=In.SimulinkRate;

    real_inReg=topNet.addSignal2('Type',hTm,'Name','In1Register');
    imag_inReg=topNet.addSignal2('Type',hTm,'Name','In2Register');
    real_inReg.SimulinkRate=In.SimulinkRate;
    imag_inReg.SimulinkRate=In.SimulinkRate;

    pirelab.getIntDelayComp(topNet,real_in,real_inReg,1,'DelayRealInput');
    pirelab.getIntDelayComp(topNet,imag_in,imag_inReg,1,'DelayImagInput');

    xMapped=topNet.addSignal2('Type',hTm,'Name','XQMapped');
    yMapped=topNet.addSignal2('Type',hTm,'Name','yQMapped');
    xMapped.SimulinkRate=In.SimulinkRate;
    yMapped.SimulinkRate=In.SimulinkRate;

    pirelab.getDTCComp(topNet,real,real_in,'Floor','Wrap');
    pirelab.getDTCComp(topNet,imag,imag_in,'Floor','Wrap');

    QuadrantBFin=[real_inReg,imag_inReg];
    QuadrantBFout=[xMapped,yMapped,concatV];

    pirelab.getIntDelayComp(topNet,xMapped,xCD{1},1,'DelayQuadMapper1');
    pirelab.getIntDelayComp(topNet,yMapped,yCD{1},1,'DelayQuadMapper2');

    pirelab.instantiateNetwork(topNet,QuadrantBFnet,...
    QuadrantBFin,QuadrantBFout,'QuadrantMapper');

    pirelab.getConstComp(topNet,zCD{1},0);


    concatVD=topNet.addSignal2('Type',concatT,'Name','ControlQCDelay');
    pirelab.getIntDelayComp(topNet,concatV,concatVD,((blockInfo.NIters)+1),'DelayQC_Control',0);




    CORDICnet=this.elabCORDICIteration(...
    topNet,sigInfo,dataRate,blockInfo);


    for ii=1:1:(blockInfo.NIters+1)





        idx=topNet.addSignal2('Type',shiftT,'Name',['shift',num2str((ii))]);
        pirelab.getConstComp(topNet,idx,(ii),['shift',num2str(ii-1)],'off','true');
        idx.SimulinkRate=In.SimulinkRate;



        lut_value=topNet.addSignal2('Type',lutT,'Name',['lut_value',num2str(ii)]);
        lut_value.SimulinkRate=In.SimulinkRate;

        if strcmp(blockInfo.AngleFormat,'Radians')

            pirelab.getConstComp(topNet,lut_value,(atan(2^(-(ii)))));

        elseif strcmp(blockInfo.AngleFormat,'Normalized')
            numIncr=round(((atan(2^(-ii)))/(NormalizeStep)));
            angNorm=numIncr*(1/(2^((In.Type.BaseType.WordLength)+2)));
            pirelab.getConstComp(topNet,lut_value,angNorm);

        end




        CORDICin=[xCD{ii},yCD{ii},zCD{ii},lut_value,idx];
        CORDICout=[xC{ii},yC{ii},zC{ii}];

        pirelab.instantiateNetwork(topNet,CORDICnet,...
        CORDICin,CORDICout,'Iteration');

        if ii<blockInfo.NIters+1

            pirelab.getIntDelayComp(topNet,xC{ii},xCD{ii+1},1,['Pipeline',num2str(ii)]);
            pirelab.getIntDelayComp(topNet,yC{ii},yCD{ii+1},1,['Pipeline',num2str(ii)]);
            pirelab.getIntDelayComp(topNet,zC{ii},zCD{ii+1},1,['Pipeline',num2str(ii)]);


        end

    end


    validoutS=validNet.addSignal2('Type',validIn.Type,'Name','ValidOutDelayed');
    pirelab.getIntDelayComp(validNet,validIn,validoutS,((blockInfo.NIters)+3),'Delay_ValidIn',0);

    t=pirelab.getAnnotationComp(topNet,'Terminator');
    t.addInputPort('inT');
    xC{ii-1}.addReceiver(t,0)
    t1=pirelab.getAnnotationComp(topNet,'Terminator1');
    t1.addInputPort('inT1');
    yC{ii-1}.addReceiver(t1,0)



    zout_corrected=topNet.addSignal2('Type',hTa,'Name','zout_corrected');
    zout_correctedP=topNet.addSignal2('Type',hTa,'Name','zout_corrected');

    QuadrantAFin=[zCD{(blockInfo.NIters+1)},concatVD];
    QuadrantAFout=zout_corrected;

    QuadrantAFnet=this.elabQuadrantCorrection(...
    topNet,sigInfo,real.SimulinkRate,blockInfo);

    pirelab.instantiateNetwork(topNet,QuadrantAFnet,...
    QuadrantAFin,QuadrantAFout,'QuadrantCorrection');

    reset=validNet.addSignal2('Type',validIn.Type,'Name','reset_outval');
    pirelab.getBitwiseOpComp(validNet,validoutS,reset,'not','invert_reset');











    resetIn=reset;
    if(topNet~=validNet)

        resetEnb=inSignals(end);
    else
        resetEnb=reset;
    end

    zeroConstAng=topNet.addSignal2('Type',hTa,'Name','zeroCA');
    zeroConstAng.SimulinkRate=In.SimulinkRate;
    pirelab.getConstComp(topNet,zeroConstAng,0,'Initial_ValAng','on',0,'','','');
    outSwitchAng=topNet.addSignal2('Type',hTa,'Name','outSwitchAng');


    pirelab.getSwitchComp(topNet,[zeroConstAng,zout_corrected],outSwitchAng,resetEnb,'muxAng','~=',0);
    pirelab.getIntDelayComp(topNet,outSwitchAng,zout_correctedP,1,'Output Register',0,0,0,[],0,0);




    pirelab.getWireComp(topNet,zout_correctedP,angle);
    pirelab.getIntDelayComp(validNet,validoutS,validOut,1,'DelayValidOut');
