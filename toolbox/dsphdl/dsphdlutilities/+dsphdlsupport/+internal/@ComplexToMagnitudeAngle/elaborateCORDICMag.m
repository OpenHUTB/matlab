function resetIn=elaborateCORDICMag(this,topNet,blockInfo,validNet,validIn,validOut)












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


    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');

    targetWL=1;
    if strcmpi(blockInfo.synthesisTool,'Xilinx Vivado')||strcmpi(blockInfo.synthesisTool,'Xilinx ISE')
        targetWL=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    elseif strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
        targetWL=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    end

    outWL=hTm.WordLength;
    outFL=hTm.FractionLength;

    multiplierOutputWL=outWL+18;
    multiplierOutputFL=outFL-(-17);
    multiplierOutputType=pir_fixpt_t(1,multiplierOutputWL,multiplierOutputFL);
    addOutWL=multiplierOutputWL;
    addOutFL=multiplierOutputFL;
    addOutputType=pir_fixpt_t(1,addOutWL,addOutFL*-1);
    targetFL=-17+outFL;
    targetOutputType=pir_fixpt_t(1,max(addOutWL,targetWL),targetFL);
    dspOutWL=max(addOutWL,targetWL);
    dspOutFL=targetFL;



    outSignals=topNet.PirOutputSignals;
    magnitude=outSignals(1);




    xC=cell(1,(blockInfo.NIters)+2);
    yC=cell(1,(blockInfo.NIters)+2);


    xCD=cell(1,(blockInfo.NIters)+2);
    yCD=cell(1,(blockInfo.NIters)+2);



    for ii=1:1:(blockInfo.NIters+2)

        xC{ii}=topNet.addSignal2('Type',hTm,'Name',['xout',num2str(ii)]);
        yC{ii}=topNet.addSignal2('Type',hTm,'Name',['yout',num2str(ii)]);
        xC{ii}.SimulinkRate=In.SimulinkRate;
        yC{ii}.SimulinkRate=In.SimulinkRate;

        xCD{ii}=topNet.addSignal2('Type',hTm,'Name',['xin',num2str(ii)]);
        yCD{ii}=topNet.addSignal2('Type',hTm,'Name',['yin',num2str(ii)]);
        xC{ii}.SimulinkRate=In.SimulinkRate;
        yC{ii}.SimulinkRate=In.SimulinkRate;
    end



    sigInfo.absdatatype=hTm;
    sigInfo.booleanT=booleanT;
    sigInfo.booleanTwo=booleanTwo;
    sigInfo.shiftT=shiftT;
    sigInfo.hTin=hTin;
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

    pirelab.getIntDelayComp(topNet,xMapped,xCD{1},1,'DelayQuadMapper1');
    pirelab.getIntDelayComp(topNet,yMapped,yCD{1},1,'DelayQuadMapper2');

    QuadrantBFout=[xMapped,yMapped];

    pirelab.instantiateNetwork(topNet,QuadrantBFnet,...
    QuadrantBFin,QuadrantBFout,'QuadrantMapper');








    CORDICnet=this.elabCORDICIteration(...
    topNet,sigInfo,dataRate,blockInfo);


    for ii=1:1:(blockInfo.NIters+1)





        idx=topNet.addSignal2('Type',shiftT,'Name',['shift',num2str((ii))]);
        pirelab.getConstComp(topNet,idx,(ii),['shift',num2str(ii-1)],'off','true');
        idx.SimulinkRate=In.SimulinkRate;


        CORDICin=[xCD{ii},yCD{ii},idx];
        CORDICout=[xC{ii},yC{ii}];

        pirelab.instantiateNetwork(topNet,CORDICnet,...
        CORDICin,CORDICout,'Iteration');

        if ii<blockInfo.NIters+1

            pirelab.getIntDelayComp(topNet,xC{ii},xCD{ii+1},1,['Pipeline',num2str(ii)]);
            pirelab.getIntDelayComp(topNet,yC{ii},yCD{ii+1},1,['Pipeline',num2str(ii)]);
        end

    end


    validoutS=validNet.addSignal2('Type',validIn.Type,'Name','ValidOutDelayed');
    if blockInfo.ScaleOutput&&blockInfo.UseMultipliers
        pirelab.getIntDelayComp(validNet,validIn,validoutS,((blockInfo.NIters)+1)+6,'Delay_ValidIn',0);
    else
        pirelab.getIntDelayComp(validNet,validIn,validoutS,((blockInfo.NIters)+1)+2,'Delay_ValidIn',0);
    end



    reset=validNet.addSignal2('Type',validIn.Type,'Name','reset_outval');










    resetIn=reset;
    if(topNet~=validNet)

        resetEnb=inSignals(end);
    else
        resetEnb=reset;
    end



    pirelab.getBitwiseOpComp(validNet,validoutS,reset,'not','invert_reset');

    zeroConst=topNet.addSignal2('Type',hTm,'Name','zeroC');
    zeroConst.SimulinkRate=In.SimulinkRate;
    pirelab.getConstComp(topNet,zeroConst,0,'Initial_Val','on',0,'','','');

    outSwitchMag=topNet.addSignal2('Type',hTm,'Name','outSwitchMag');



    xscaling=zeros(1,(blockInfo.NIters));

    for ii=1:1:blockInfo.NIters
        xscaling(ii)=cosd(atand(2^-ii));

    end
    y=prod(xscaling);

    coefMaxType=pir_sfixpt_t(18,-17);

    if blockInfo.ScaleOutput
        if blockInfo.UseMultipliers
            Y=topNet.addSignal2('Type',coefMaxType,'Name','Y');
            y=fi(y,0,18,17,'RoundingMethod','Floor','OverflowAction',...
            'Wrap');
            comp=pirelab.getConstComp(topNet,Y,y);

        else
            if hTm.WordLength>15
                y=fi(y,0,15,15,'RoundingMethod','Round','OverflowAction',...
                'Wrap');

            else
                y=fi(y,0,hTm.WordLength,hTm.WordLength,'RoundingMethod','Floor','OverflowAction',...
                'Wrap');

            end
        end
    end
    if blockInfo.ScaleOutput
        xoutscaled=topNet.addSignal2('Type',hTm,'Name','xoutscaled');

        if blockInfo.UseMultipliers
            dspOutType=pir_sfixpt_t(dspOutWL,dspOutFL);
            dinDly=topNet.addSignal2('Type',hTm,'Name','dinDly');
            multOut=topNet.addSignal2('Type',dspOutType,'Name','multOut');
            syncReset=topNet.addSignal2('Type',booleanT,'Name','syncRST');
            syncReset.SimulinkRate=dataRate;
            pirelab.getConstComp(topNet,syncReset,0);

            scaleProductMult=elabScaleProductMult(this,topNet,blockInfo,dataRate,...
            xCD{1},Y,dinDly,multOut,syncReset,...
            hTm.WordLength,hTm.FractionLength,...
            Y.Type.WordLength,Y.Type.FractionLength,...
            dspOutWL,dspOutFL);%#ok<*NASGU>

            pirelab.instantiateNetwork(topNet,scaleProductMult,...
            [xCD{blockInfo.NIters+1},Y,syncReset],...
            [dinDly,multOut],...
            'ScaleProductMult');

            pirelab.getDTCComp(topNet,multOut,xoutscaled,'Floor','Wrap');

        else

            pirelab.getGainComp(topNet,xCD{blockInfo.NIters+1},xoutscaled,y,1,1,'Floor','Wrap','CSD Gain Factor');


        end
        pirelab.getSwitchComp(topNet,[zeroConst,xoutscaled],outSwitchMag,resetEnb,'muxMag','~=',0);
        pirelab.getIntDelayComp(topNet,outSwitchMag,xCD{blockInfo.NIters+2},1,'Output Register',0,0,0,[],0,0);

    else


        pirelab.getSwitchComp(topNet,[zeroConst,xCD{blockInfo.NIters+1}],outSwitchMag,resetEnb,'muxMag','~=',0);
        pirelab.getIntDelayComp(topNet,outSwitchMag,xCD{blockInfo.NIters+2},1,'Output Register',0,0,0,[],0,0);

    end
    pirelab.getWireComp(topNet,xCD{blockInfo.NIters+2},magnitude);
    pirelab.getIntDelayComp(validNet,validoutS,validOut,1,'DelayValidOut');

    t=pirelab.getAnnotationComp(topNet,'Terminator');
    t.addInputPort('inT');
    yC{ii}.addReceiver(t,0)