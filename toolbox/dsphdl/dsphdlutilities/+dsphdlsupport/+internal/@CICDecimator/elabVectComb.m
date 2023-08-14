function cSection=elabVectComb(~,hTopN,blockInfo,slRate,dsOut_re,dsOut_im,ds_vout,internalReset,combOut_re,combOut_im,c_vout)



    in1=dsOut_re;
    in2=dsOut_im;
    in3=ds_vout;
    in4=internalReset;

    out1=combOut_re;
    out2=combOut_im;
    out3=c_vout;


    cSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','cSection',...
    'InportNames',{'dsOut_re','dsOut_im','ds_vout','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'combOut_re','combOut_im','c_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dsOut_re=cSection.PirInputSignals(1);
    dsOut_im=cSection.PirInputSignals(2);
    ds_vout=cSection.PirInputSignals(3);
    internalReset=cSection.PirInputSignals(4);

    combOut_re=cSection.PirOutputSignals(1);
    combOut_im=cSection.PirOutputSignals(2);
    c_vout=cSection.PirOutputSignals(3);

    sfixTypeN=[];
    for i=blockInfo.NumSections:(2*6)-1
        sfixTypeN=[sfixTypeN,pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength)];
    end
    dTypeN=[];
    for i=1:6
        dTypeN=[dTypeN,pirelab.getPirVectorType(sfixTypeN(i),blockInfo.numcombinputs)];
    end

    dtype=pir_sfixpt_t(dsOut_re.Type.BaseType.WordLength,dsOut_re.Type.BaseType.FractionLength);
    inmuxoutre=[];
    for i=1:blockInfo.numcombinputs
        dins(i)=cSection.addSignal(dtype,['inmuxoutre',num2str(i)]);%#ok<*AGROW>
        inmuxoutre=[inmuxoutre,dins(i)];
    end

    inmuxoutim=[];
    for i=1:blockInfo.numcombinputs
        dins(i)=cSection.addSignal(dtype,['inmuxoutre',num2str(i)]);%#ok<*AGROW>
        inmuxoutim=[inmuxoutim,dins(i)];
    end
    pirelab.getDemuxComp(cSection,dsOut_re,inmuxoutre);
    pirelab.getDemuxComp(cSection,dsOut_im,inmuxoutim);

    stage1WL=dTypeN(1).BaseType.WordLength;
    stage1FL=dTypeN(1).BaseType.FractionLength;
    stage2WL=dTypeN(2).BaseType.WordLength;
    stage2FL=dTypeN(2).BaseType.FractionLength;
    stage3WL=dTypeN(3).BaseType.WordLength;
    stage3FL=dTypeN(3).BaseType.FractionLength;
    stage4WL=dTypeN(4).BaseType.WordLength;
    stage4FL=dTypeN(4).BaseType.FractionLength;
    stage5WL=dTypeN(5).BaseType.WordLength;
    stage5FL=dTypeN(5).BaseType.FractionLength;
    stage6WL=dTypeN(6).BaseType.WordLength;
    stage6FL=dTypeN(6).BaseType.FractionLength;
    stageNWL=combOut_re.Type.BaseType.WordLength;
    stageNFL=combOut_re.Type.BaseType.FractionLength;

    for i=1:blockInfo.numcombinputs
        dataOutcreg1_re(i)=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutcreg1_re',num2str(i)]);
        dataOutcreg1_re(i).SimulinkRate=slRate;
        dataOutcreg1_im(i)=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutcreg1_im',num2str(i)]);
        dataOutcreg1_im(i).SimulinkRate=slRate;
        dataOutcreg2_re(i)=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutcreg2_re',num2str(i)]);
        dataOutcreg2_re(i).SimulinkRate=slRate;
        dataOutcreg2_im(i)=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutcreg2_im',num2str(i)]);
        dataOutcreg2_im(i).SimulinkRate=slRate;
        dataOutcreg3_re(i)=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutcreg3_re',num2str(i)]);
        dataOutcreg3_re(i).SimulinkRate=slRate;
        dataOutcreg3_im(i)=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutcreg3_im',num2str(i)]);
        dataOutcreg3_im(i).SimulinkRate=slRate;
        dataOutcreg4_re(i)=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutcreg4_re',num2str(i)]);
        dataOutcreg4_re(i).SimulinkRate=slRate;
        dataOutcreg4_im(i)=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutcreg4_im',num2str(i)]);
        dataOutcreg4_im(i).SimulinkRate=slRate;
        dataOutcreg5_re(i)=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutcreg5_re',num2str(i)]);
        dataOutcreg5_re(i).SimulinkRate=slRate;
        dataOutcreg5_im(i)=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutcreg5_im',num2str(i)]);
        dataOutcreg5_im(i).SimulinkRate=slRate;
        dataOutcreg6_re(i)=cSection.addSignal(pir_sfixpt_t(stageNWL,stageNFL),['dataOutcreg6_re',num2str(i)]);
        dataOutcreg6_re(i).SimulinkRate=slRate;
        dataOutcreg6_im(i)=cSection.addSignal(pir_sfixpt_t(stageNWL,stageNFL),['dataOutcreg6_im',num2str(i)]);
        dataOutcreg6_im(i).SimulinkRate=slRate;
        dataOutcreg1_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutcreg1_rereg',num2str(i)]);
        dataOutcreg1_rereg(i).SimulinkRate=slRate;
        dataOutcreg1_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutcreg1_imreg',num2str(i)]);
        dataOutcreg1_imreg(i).SimulinkRate=slRate;
        dataOutcreg2_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutcreg2_rereg',num2str(i)]);
        dataOutcreg2_rereg(i).SimulinkRate=slRate;
        dataOutcreg2_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutcreg2_imreg',num2str(i)]);
        dataOutcreg2_imreg(i).SimulinkRate=slRate;
        dataOutcreg3_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutcreg3_rereg',num2str(i)]);
        dataOutcreg3_rereg(i).SimulinkRate=slRate;
        dataOutcreg3_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutcreg3_imreg',num2str(i)]);
        dataOutcreg3_imreg(i).SimulinkRate=slRate;
        dataOutcreg4_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutcreg4_rereg',num2str(i)]);
        dataOutcreg4_rereg(i).SimulinkRate=slRate;
        dataOutcreg4_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutcreg4_imreg',num2str(i)]);
        dataOutcreg4_imreg(i).SimulinkRate=slRate;
        dataOutcreg5_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutcreg5_rereg',num2str(i)]);
        dataOutcreg5_rereg(i).SimulinkRate=slRate;
        dataOutcreg5_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutcreg5_imreg',num2str(i)]);
        dataOutcreg5_imreg(i).SimulinkRate=slRate;
        dataOutcreg6_rereg(i)=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutcreg6_rereg',num2str(i)]);
        dataOutcreg6_rereg(i).SimulinkRate=slRate;
        dataOutcreg6_imreg(i)=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutcreg6_imreg',num2str(i)]);
        dataOutcreg6_imreg(i).SimulinkRate=slRate;
    end
    dataOutComreg1_re=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'dataOutComreg1_re');
    dataOutComreg1_re.SimulinkRate=slRate;
    dataOutComreg1_im=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'dataOutComreg1_im');
    dataOutComreg1_im.SimulinkRate=slRate;
    dataOutCom1reg1_re=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'dataOutCom1reg1_re');
    dataOutCom1reg1_re.SimulinkRate=slRate;
    dataOutCom1reg1_im=cSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'dataOutCom1reg1_im');
    dataOutCom1reg1_im.SimulinkRate=slRate;
    dataOutComreg2_re=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'dataOutComreg2_re');
    dataOutComreg2_re.SimulinkRate=slRate;
    dataOutComreg2_im=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'dataOutComreg2_im');
    dataOutComreg2_im.SimulinkRate=slRate;
    dataOutCom2reg2_re=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'dataOutCom2reg2_re');
    dataOutCom2reg2_re.SimulinkRate=slRate;
    dataOutCom2reg2_im=cSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'dataOutCom2reg2_im');
    dataOutCom2reg2_im.SimulinkRate=slRate;
    dataOutComreg3_re=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'dataOutComreg3_re');
    dataOutComreg3_re.SimulinkRate=slRate;
    dataOutComreg3_im=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'dataOutComreg3_im');
    dataOutComreg3_im.SimulinkRate=slRate;
    dataOutCom3reg3_re=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'dataOutCom3reg3_re');
    dataOutCom3reg3_re.SimulinkRate=slRate;
    dataOutCom3reg3_im=cSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'dataOutCom3reg3_im');
    dataOutCom3reg3_im.SimulinkRate=slRate;
    dataOutComreg4_re=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'dataOutComreg4_re');
    dataOutComreg4_re.SimulinkRate=slRate;
    dataOutComreg4_im=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'dataOutComreg4_im');
    dataOutComreg4_im.SimulinkRate=slRate;
    dataOutCom4reg4_re=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'dataOutCom4reg4_re');
    dataOutCom4reg4_re.SimulinkRate=slRate;
    dataOutCom4reg4_im=cSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'dataOutCom4reg4_im');
    dataOutCom4reg4_im.SimulinkRate=slRate;
    dataOutComreg5_re=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'dataOutComreg5_re');
    dataOutComreg5_re.SimulinkRate=slRate;
    dataOutComreg5_im=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'dataOutComreg5_im');
    dataOutComreg5_im.SimulinkRate=slRate;
    dataOutCom5reg5_re=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'dataOutCom5reg5_re');
    dataOutCom5reg5_re.SimulinkRate=slRate;
    dataOutCom5reg5_im=cSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'dataOutCom5reg5_im');
    dataOutCom5reg5_im.SimulinkRate=slRate;
    dataOutComreg6_re=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'dataOutComreg6_re');
    dataOutComreg6_re.SimulinkRate=slRate;
    dataOutComreg6_im=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'dataOutComreg6_im');
    dataOutComreg6_im.SimulinkRate=slRate;
    dataOutCom6reg6_re=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'dataOutCom6reg6_re');
    dataOutCom6reg6_re.SimulinkRate=slRate;
    dataOutCom6reg6_im=cSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'dataOutCom6reg6_im');
    dataOutCom6reg6_im.SimulinkRate=slRate;

    pirelab.getIntDelayEnabledResettableComp(cSection,inmuxoutre(end),dataOutComreg1_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,inmuxoutim(end),dataOutComreg1_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg1_re(end),dataOutComreg2_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg1_im(end),dataOutComreg2_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg2_re(end),dataOutComreg3_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg2_im(end),dataOutComreg3_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg3_re(end),dataOutComreg4_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg3_im(end),dataOutComreg4_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg4_re(end),dataOutComreg5_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg4_im(end),dataOutComreg5_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg5_re(end),dataOutComreg6_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg5_im(end),dataOutComreg6_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,inmuxoutre(end-1),dataOutCom1reg1_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,inmuxoutim(end-1),dataOutCom1reg1_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg1_re(end-1),dataOutCom2reg2_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg1_im(end-1),dataOutCom2reg2_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg2_re(end-1),dataOutCom3reg3_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg2_im(end-1),dataOutCom3reg3_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg3_re(end-1),dataOutCom4reg4_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg3_im(end-1),dataOutCom4reg4_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg4_re(end-1),dataOutCom5reg5_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg4_im(end-1),dataOutCom5reg5_im,ds_vout,internalReset,1);

    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg5_re(end-1),dataOutCom6reg6_re,ds_vout,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,dataOutcreg5_im(end-1),dataOutCom6reg6_im,ds_vout,internalReset,1);

    if blockInfo.DifferentialDelay==1
        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg5_re(i),dataOutComreg6_re],dataOutcreg6_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg5_im(i),dataOutComreg6_im],dataOutcreg6_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg6_rereg(i),dataOutcreg6_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg6_imreg(i),dataOutcreg6_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg5_re(i),dataOutcreg5_re(i-1)],dataOutcreg6_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg5_im(i),dataOutcreg5_im(i-1)],dataOutcreg6_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg6_rereg(i),dataOutcreg6_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg6_imreg(i),dataOutcreg6_im(i),'Floor','Wrap');
            end
        end
        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg4_re(i),dataOutComreg5_re],dataOutcreg5_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg4_im(i),dataOutComreg5_im],dataOutcreg5_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg5_rereg(i),dataOutcreg5_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg5_imreg(i),dataOutcreg5_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg4_re(i),dataOutcreg4_re(i-1)],dataOutcreg5_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg4_im(i),dataOutcreg4_im(i-1)],dataOutcreg5_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg5_rereg(i),dataOutcreg5_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg5_imreg(i),dataOutcreg5_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg3_re(i),dataOutComreg4_re],dataOutcreg4_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg3_im(i),dataOutComreg4_im],dataOutcreg4_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg4_rereg(i),dataOutcreg4_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg4_imreg(i),dataOutcreg4_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg3_re(i),dataOutcreg3_re(i-1)],dataOutcreg4_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg3_im(i),dataOutcreg3_im(i-1)],dataOutcreg4_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg4_rereg(i),dataOutcreg4_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg4_imreg(i),dataOutcreg4_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg2_re(i),dataOutComreg3_re],dataOutcreg3_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg2_im(i),dataOutComreg3_im],dataOutcreg3_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg3_rereg(i),dataOutcreg3_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg3_imreg(i),dataOutcreg3_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg2_re(i),dataOutcreg2_re(i-1)],dataOutcreg3_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg2_im(i),dataOutcreg2_im(i-1)],dataOutcreg3_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg3_rereg(i),dataOutcreg3_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg3_imreg(i),dataOutcreg3_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg1_re(i),dataOutComreg2_re],dataOutcreg2_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg1_im(i),dataOutComreg2_im],dataOutcreg2_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg2_rereg(i),dataOutcreg2_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg2_imreg(i),dataOutcreg2_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg1_re(i),dataOutcreg1_re(i-1)],dataOutcreg2_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg1_im(i),dataOutcreg1_im(i-1)],dataOutcreg2_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg2_rereg(i),dataOutcreg2_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg2_imreg(i),dataOutcreg2_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[inmuxoutre(i),dataOutComreg1_re],dataOutcreg1_rereg(i));
                pirelab.getSubComp(cSection,[inmuxoutim(i),dataOutComreg1_im],dataOutcreg1_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg1_rereg(i),dataOutcreg1_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg1_imreg(i),dataOutcreg1_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[inmuxoutre(i),inmuxoutre(i-1)],dataOutcreg1_rereg(i));
                pirelab.getSubComp(cSection,[inmuxoutim(i),inmuxoutim(i-1)],dataOutcreg1_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg1_rereg(i),dataOutcreg1_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg1_imreg(i),dataOutcreg1_im(i),'Floor','Wrap');
            end
        end
    else
        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg5_re(i),dataOutCom6reg6_re],dataOutcreg6_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg5_im(i),dataOutCom6reg6_im],dataOutcreg6_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg6_rereg(i),dataOutcreg6_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg6_imreg(i),dataOutcreg6_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[dataOutcreg5_re(i),dataOutComreg6_re],dataOutcreg6_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg5_im(i),dataOutComreg6_im],dataOutcreg6_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg6_rereg(i),dataOutcreg6_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg6_imreg(i),dataOutcreg6_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg5_re(i),dataOutcreg5_re(i-2)],dataOutcreg6_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg5_im(i),dataOutcreg5_im(i-2)],dataOutcreg6_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg6_rereg(i),dataOutcreg6_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg6_imreg(i),dataOutcreg6_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg4_re(i),dataOutCom5reg5_re],dataOutcreg5_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg4_im(i),dataOutCom5reg5_im],dataOutcreg5_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg5_rereg(i),dataOutcreg5_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg5_imreg(i),dataOutcreg5_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[dataOutcreg4_re(i),dataOutComreg5_re],dataOutcreg5_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg4_im(i),dataOutComreg5_im],dataOutcreg5_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg5_rereg(i),dataOutcreg5_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg5_imreg(i),dataOutcreg5_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg4_re(i),dataOutcreg4_re(i-2)],dataOutcreg5_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg4_im(i),dataOutcreg4_im(i-2)],dataOutcreg5_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg5_rereg(i),dataOutcreg5_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg5_imreg(i),dataOutcreg5_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg3_re(i),dataOutCom4reg4_re],dataOutcreg4_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg3_im(i),dataOutCom4reg4_im],dataOutcreg4_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg4_rereg(i),dataOutcreg4_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg4_imreg(i),dataOutcreg4_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[dataOutcreg3_re(i),dataOutComreg4_re],dataOutcreg4_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg3_im(i),dataOutComreg4_im],dataOutcreg4_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg4_rereg(i),dataOutcreg4_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg4_imreg(i),dataOutcreg4_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg3_re(i),dataOutcreg3_re(i-2)],dataOutcreg4_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg3_im(i),dataOutcreg3_im(i-2)],dataOutcreg4_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg4_rereg(i),dataOutcreg4_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg4_imreg(i),dataOutcreg4_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg2_re(i),dataOutCom3reg3_re],dataOutcreg3_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg2_im(i),dataOutCom3reg3_im],dataOutcreg3_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg3_rereg(i),dataOutcreg3_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg3_imreg(i),dataOutcreg3_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[dataOutcreg2_re(i),dataOutComreg3_re],dataOutcreg3_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg2_im(i),dataOutComreg3_im],dataOutcreg3_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg3_rereg(i),dataOutcreg3_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg3_imreg(i),dataOutcreg3_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg2_re(i),dataOutcreg2_re(i-2)],dataOutcreg3_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg2_im(i),dataOutcreg2_im(i-2)],dataOutcreg3_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg3_rereg(i),dataOutcreg3_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg3_imreg(i),dataOutcreg3_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[dataOutcreg1_re(i),dataOutCom2reg2_re],dataOutcreg2_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg1_im(i),dataOutCom2reg2_im],dataOutcreg2_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg2_rereg(i),dataOutcreg2_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg2_imreg(i),dataOutcreg2_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[dataOutcreg1_re(i),dataOutComreg2_re],dataOutcreg2_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg1_im(i),dataOutComreg2_im],dataOutcreg2_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg2_rereg(i),dataOutcreg2_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg2_imreg(i),dataOutcreg2_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[dataOutcreg1_re(i),dataOutcreg1_re(i-2)],dataOutcreg2_rereg(i));
                pirelab.getSubComp(cSection,[dataOutcreg1_im(i),dataOutcreg1_im(i-2)],dataOutcreg2_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg2_rereg(i),dataOutcreg2_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg2_imreg(i),dataOutcreg2_im(i),'Floor','Wrap');
            end
        end

        for i=1:blockInfo.numcombinputs
            if i==1
                pirelab.getSubComp(cSection,[inmuxoutre(i),dataOutCom1reg1_re],dataOutcreg1_rereg(i));
                pirelab.getSubComp(cSection,[inmuxoutim(i),dataOutCom1reg1_im],dataOutcreg1_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg1_rereg(i),dataOutcreg1_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg1_imreg(i),dataOutcreg1_im(i),'Floor','Wrap');
            elseif i==2
                pirelab.getSubComp(cSection,[inmuxoutre(i),dataOutComreg1_re],dataOutcreg1_rereg(i));
                pirelab.getSubComp(cSection,[inmuxoutim(i),dataOutComreg1_im],dataOutcreg1_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg1_rereg(i),dataOutcreg1_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg1_imreg(i),dataOutcreg1_im(i),'Floor','Wrap');
            else
                pirelab.getSubComp(cSection,[inmuxoutre(i),inmuxoutre(i-2)],dataOutcreg1_rereg(i));
                pirelab.getSubComp(cSection,[inmuxoutim(i),inmuxoutim(i-2)],dataOutcreg1_imreg(i));
                pirelab.getDTCComp(cSection,dataOutcreg1_rereg(i),dataOutcreg1_re(i),'Floor','Wrap');
                pirelab.getDTCComp(cSection,dataOutcreg1_imreg(i),dataOutcreg1_im(i),'Floor','Wrap');
            end
        end
    end
    switch blockInfo.NumSections
    case 1
        WL=stage2WL;
        FL=stage2FL;
        dout_re=dataOutcreg1_re;
        dout_im=dataOutcreg1_im;
    case 2
        WL=stage3WL;
        FL=stage3FL;
        dout_re=dataOutcreg2_re;
        dout_im=dataOutcreg2_im;
    case 3
        WL=stage4WL;
        FL=stage4FL;
        dout_re=dataOutcreg3_re;
        dout_im=dataOutcreg3_im;
    case 4
        WL=stage5WL;
        FL=stage5FL;
        dout_re=dataOutcreg4_re;
        dout_im=dataOutcreg4_im;
    case 5
        WL=stage6WL;
        FL=stage6FL;
        dout_re=dataOutcreg5_re;
        dout_im=dataOutcreg5_im;
    otherwise
        WL=stageNWL;
        FL=stageNFL;
        dout_re=dataOutcreg6_re;
        dout_im=dataOutcreg6_im;

    end
    for i=1:blockInfo.numcombinputs
        combOutreg_re(i)=cSection.addSignal(pir_sfixpt_t(WL,FL),['combOutreg_re',num2str(i)]);
        combOutreg_re(i).SimulinkRate=slRate;
        combOutreg_im(i)=cSection.addSignal(pir_sfixpt_t(WL,FL),['combOutreg_im',num2str(i)]);
        combOutreg_im(i).SimulinkRate=slRate;
        pirelab.getIntDelayEnabledResettableComp(cSection,dout_re(i),combOutreg_re(i),1,internalReset,blockInfo.NumSections);
        pirelab.getIntDelayEnabledResettableComp(cSection,dout_im(i),combOutreg_im(i),1,internalReset,blockInfo.NumSections);
    end
    pirelab.getIntDelayEnabledResettableComp(cSection,ds_vout,c_vout,1,internalReset,blockInfo.NumSections);
    pirelab.getMuxComp(cSection,combOutreg_re,combOut_re);
    pirelab.getMuxComp(cSection,combOutreg_im,combOut_im);
end