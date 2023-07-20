function mmcNet=elabMinmetricCal(~,topNet,blockInfo,dataRate)





    ufix1Type=pir_ufixpt_t(1,0);

    smType=blockInfo.smType;
    if blockInfo.issigned
        stype=pir_sfixpt_t(blockInfo.stateMetWL,0);
        stmetType=pir_sfixpt_t(blockInfo.stateMetWL,0);
    else
        stype=pir_ufixpt_t(blockInfo.stateMetWL,0);
        stmetType=pir_sfixpt_t(blockInfo.stateMetWL,0);
    end

    idxType=pir_ufixpt_t(log2(blockInfo.numStates),0);


    mmcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MinimumMetricCal',...
    'Inportnames',{'stateMet','smValid'},...
    'InportTypes',[smType,ufix1Type],...
    'InportRates',[dataRate,dataRate],...
    'Outportnames',{'minIdx','minValid'},...
    'OutportTypes',[idxType,ufix1Type]...
    );

    stm_ip=mmcNet.PirInputSignals(1);
    valid=mmcNet.PirInputSignals(2);

    minindx=mmcNet.PirOutputSignals(1);
    minvalid=mmcNet.PirOutputSignals(2);


    mmcNet.addComment('state metrics deMuxing');
    dmuxout_tmp=[];
    for i=1:blockInfo.numStates
        dins(i)=mmcNet.addSignal(stype,['SMet',num2str(i)]);%#ok<*AGROW>
        dmuxout_tmp=[dmuxout_tmp,dins(i)];
    end
    pirelab.getDemuxComp(mmcNet,stm_ip,dmuxout_tmp);

    dmuxout=[];
    for i=1:blockInfo.numStates
        SMet_dtc(i)=mmcNet.addSignal(stmetType,['SMet_dtc',num2str(i)]);%#ok<*AGROW>
        pirelab.getDTCComp(mmcNet,dmuxout_tmp(i),SMet_dtc(i),'floor','wrap');
        dmuxout=[dmuxout,SMet_dtc(i)];
    end

    for i=1:blockInfo.numStates
        stateMet_int(i)=mmcNet.addSignal(stmetType,['stateMet_sub',num2str(i)]);
        if(i==1)
            SmO=mmcNet.addSignal(stmetType,'Sm0Sub');
            pirelab.getWireComp(mmcNet,dmuxout(i),SmO);
        end
        pirelab.getSubComp(mmcNet,[dmuxout(i),SmO],stateMet_int(i),'floor','wrap');
    end

    for i=1:blockInfo.numStates
        stm_temp(i)=mmcNet.addSignal(stmetType,['stateMet',num2str(i)]);
    end

    for i=1:blockInfo.numStates
        pirelab.getUnitDelayComp(mmcNet,stateMet_int(i),stm_temp(i),'',0);
    end

    minstate=mmcNet.addSignal(stmetType,'minState');


    pipeTree=true;

    tcomp=pirelab.getTreeArch(mmcNet,stm_temp,[minstate,minindx],'min','Floor',...
    'Wrap','MinimumTree','Zero',pipeTree);
    tcomp.addComment('Minimum index calculation');

    min_delay=blockInfo.ConstraintLength;
    dcomp=pirelab.getIntDelayComp(mmcNet,valid,minvalid,min_delay,'',0);
    dcomp.addComment('Minimum metric Delay added for the validIn');

end
