function slpidwrapperMSFunc5w(blk)






    values=get_param(blk,'MaskWSVariables');
    blkWSVarNames={values.Name};
    TimeDomain=values(strcmp(blkWSVarNames,'TimeDomain')).Value;
    typeidx=values(strcmp(blkWSVarNames,'PIDType')).Value;
    formidx=values(strcmp(blkWSVarNames,'PIDForm')).Value;
    IFidx=values(strcmp(blkWSVarNames,'IntegratorFormula')).Value;
    DFidx=values(strcmp(blkWSVarNames,'FilterFormula')).Value;
    HasIntegrator=(values(strcmp(blkWSVarNames,'PlantType')).Value==2);
    if values(strcmp(blkWSVarNames,'PlantSign')).Value==1
        LoopSign=1;
    else
        LoopSign=-1;
    end
    NotDeployTuningModule=values(strcmp(blkWSVarNames,'NotDeployTuningModule')).Value;
    ExperimentModeIdx=values(strcmp(blkWSVarNames,'ExperimentMode')).Value;

    rto=get_param([blk,'/GainTs'],'RuntimeObject');
    Ts=rto.OutputPort(1).Data;

    rto=get_param([blk,'/GainWC'],'RuntimeObject');
    targetBandwidth=rto.OutputPort(1).Data(3);

    rto=get_param([blk,'/GainPM'],'RuntimeObject');
    targetPM=rto.OutputPort(1).Data;

    switch ExperimentModeIdx
    case 1
        rto=get_param([blk,'/Frequency Response Estimator/Sinestream/CA/Assemble'],'RuntimeObject');
    case 2
        rto=get_param([blk,'/Frequency Response Estimator/Superimposed/Response Estimation'],'RuntimeObject');
    end
    hG5=rto.OutputPort(1).Data;

    rto=get_param([blk,'/New Nominal Detector/Enabled Delay U'],'RuntimeObject');
    u0=rto.OutputPort(1).Data;
    rto=get_param([blk,'/New Nominal Detector/Enabled Delay Y'],'RuntimeObject');
    y0=rto.OutputPort(1).Data;
    nominal=[u0;y0];

    w5=targetBandwidth*[1/10;1/3;1;3;10];
    if TimeDomain==1

        [P,I,D,N,achievedPM]=slpidfivepoint(typeidx,formidx,w5,hG5,targetPM,HasIntegrator,LoopSign,Ts,IFidx,DFidx);
    else

        [P,I,D,N,achievedPM]=slpidfivepoint(typeidx,formidx,w5,hG5,targetPM,HasIntegrator,LoopSign,0,IFidx,DFidx);
    end

    data=struct('P',P,'I',I,'D',D,'N',N,'nominal',nominal);
    data.plant=frd(hG5,w5,'Ts',Ts);
    data.achievedPM=achievedPM;
    data.targetBandwidth=targetBandwidth;
    data.targetPM=targetPM;
    data.typeidx=typeidx;
    data.formidx=formidx;
    data.TimeDomain=TimeDomain;
    data.Ts=Ts;
    data.IFidx=IFidx;
    data.DFidx=DFidx;
    data.EstimateDCGain=0;
    set_param([blk,'/Frequency Response Estimator'],'UserData',data);

    if NotDeployTuningModule
        if strcmp(get_param(bdroot(blk),'InlineParameters'),'off')||~strcmp(get_param(bdroot(blk),'SimulationMode'),'external')
            set_param(blk,'tunedP',num2str(P),'tunedI',num2str(I),'tunedD',num2str(D),'tunedN',num2str(N),'tunedPM',num2str(achievedPM));
        end
    end