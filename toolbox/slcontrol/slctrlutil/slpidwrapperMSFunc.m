function slpidwrapperMSFunc(blk)






    values=get_param(blk,'MaskWSVariables');
    blkWSVarNames={values.Name};
    TimeDomain=values(strcmp(blkWSVarNames,'TimeDomain')).Value;
    typeidx=values(strcmp(blkWSVarNames,'PIDType')).Value;
    formidx=values(strcmp(blkWSVarNames,'PIDForm')).Value;
    IFidx=values(strcmp(blkWSVarNames,'IntegratorFormula')).Value;
    DFidx=values(strcmp(blkWSVarNames,'FilterFormula')).Value;
    EstimateDCGain=values(strcmp(blkWSVarNames,'EstimateDCGain')).Value;
    NotDeployTuningModule=values(strcmp(blkWSVarNames,'NotDeployTuningModule')).Value;

    rto=get_param([blk,'/GainTs'],'RuntimeObject');
    Ts=rto.OutputPort(1).Data;

    rto=get_param([blk,'/GainWC'],'RuntimeObject');
    targetBandwidth=rto.OutputPort(1).Data(2);

    rto=get_param([blk,'/GainPM'],'RuntimeObject');
    targetPM=rto.OutputPort(1).Data;

    rto=get_param([blk,'/Frequency Response Estimator/Response Estimation'],'RuntimeObject');
    hG4=rto.OutputPort(1).Data;
    K0=rto.OutputPort(2).Data;

    rto=get_param([blk,'/Frequency Response Estimator/New Nominal Detector/Enabled Delay U'],'RuntimeObject');
    u0=rto.OutputPort(1).Data;
    rto=get_param([blk,'/Frequency Response Estimator/New Nominal Detector/Enabled Delay Y'],'RuntimeObject');
    y0=rto.OutputPort(1).Data;
    nominal=[u0;y0];

    w4=targetBandwidth*[1/3;1;3;10];
    if TimeDomain==1

        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,w4,hG4,targetPM,K0,Ts,IFidx,DFidx);
    else

        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,w4,hG4,targetPM,K0,0,IFidx,DFidx);
    end

    data=struct('P',P,'I',I,'D',D,'N',N,'nominal',nominal);
    data.plant=frd(hG4,w4,'Ts',Ts);
    data.dcgain=K0;
    data.achievedPM=achievedPM;
    data.targetBandwidth=targetBandwidth;
    data.targetPM=targetPM;
    data.typeidx=typeidx;
    data.formidx=formidx;
    data.TimeDomain=TimeDomain;
    data.Ts=Ts;
    data.IFidx=IFidx;
    data.DFidx=DFidx;
    data.EstimateDCGain=EstimateDCGain;
    set_param([blk,'/Frequency Response Estimator'],'UserData',data);

    if NotDeployTuningModule
        if strcmp(get_param(bdroot(blk),'InlineParameters'),'off')||~strcmp(get_param(bdroot(blk),'SimulationMode'),'external')
            set_param(blk,'tunedP',num2str(P),'tunedI',num2str(I),'tunedD',num2str(D),'tunedN',num2str(N),'tunedPM',num2str(achievedPM));
        end
    end