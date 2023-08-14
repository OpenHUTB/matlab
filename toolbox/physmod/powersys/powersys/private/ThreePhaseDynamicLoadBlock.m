function[sps,YuNonlinear]=ThreePhaseDynamicLoadBlock(nl,sps,YuNonlinear)





    idx=nl.filter_type('Three-Phase Dynamic Load');
    sps.NbMachines=sps.NbMachines+length(idx);
    NbOut=length(sps.outstr);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        j=sqrt(-1);
        [NominalVoltage,ActiveReactivePowers,PositiveSequence]=getSPSmaskvalues(block,{'NominalVoltage','ActiveReactivePowers','PositiveSequence'});
        blocinit(block,{NominalVoltage,ActiveReactivePowers,PositiveSequence});

        Vnom=NominalVoltage(1);
        fnom=NominalVoltage(2);
        P0=ActiveReactivePowers(1);
        Q0=ActiveReactivePowers(2);
        Mag_V0=PositiveSequence(1);
        Pha_V0=PositiveSequence(2);
        V0_d=Mag_V0*cos(Pha_V0*pi/180);
        V0_q=Mag_V0*sin(Pha_V0*pi/180);
        Vbase=Vnom/sqrt(3)*sqrt(2);%#ok
        I1_init=(P0-j*Q0)/((V0_d-j*V0_q)*Vnom)/sqrt(3)*sqrt(2);
        Ia0=abs(I1_init);
        phiIa0=angle(I1_init)*180/pi;
        Ib0=Ia0;
        phiIb0=phiIa0-120;





        nodes=nl.block_nodes(block);

        sps.source=[sps.source;
        nodes(1),nodes(3),1,Ia0,phiIa0,fnom,21;
        nodes(2),nodes(3),1,Ib0,phiIb0,fnom,21];


        sps.srcstr{end+1}=['I_A: ',BlockNom];
        sps.srcstr{end+1}=['I_B: ',BlockNom];
        sps.outstr{end+1}=['U_AB: ',BlockNom];
        sps.outstr{end+1}=['U_BC: ',BlockNom];
        sps.sourcenames(end+1:end+2,1)=[block;block];
        YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3)];

        NbOut=NbOut+2;

        xc=size(sps.modelnames{21},2);
        sps.modelnames{21}(xc+1)=block;


        ysrc=size(sps.source,1)-1;
        sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];


        LoadFlowParameters=eval(get_param(getfullname(block),'LoadFlowParameters'));
        ymac=size(sps.machines,2)+1;

        if LoadFlowParameters(3)==0
            LoadFlowParameters(3)=Vnom;
        end

        MachineFullName=getfullname(block);
        sps.machines(ymac).name=MachineFullName(sps.syslength:end);
        sps.machines(ymac).nominal={0,NaN,Vnom,NaN,fnom};
        sps.machines(ymac).type=35;
        sps.machines(ymac).terminals=3;
        sps.machines(ymac).bustype=4;
        sps.machines(ymac).input=ysrc;
        sps.machines(ymac).output=NbOut-1;
        sps.machines(ymac).P=LoadFlowParameters(2);
        sps.machines(ymac).Q=LoadFlowParameters(5);
        sps.machines(ymac).Vt=LoadFlowParameters(3);
        sps.machines(ymac).Phase=LoadFlowParameters(4);
        sps.machines(ymac).Ef=NaN;
        sps.machines(ymac).Pmec=NaN;
        sps.machines(ymac).slip=NaN;
        sps.machines(ymac).torque=NaN;
        sps.machines(ymac).SourceBlock1={[],[],[],[]};
        sps.machines(ymac).SourceBlock2={[],[],[],[]};







        sps.LoadFlowParameters(end+1).name=BlockNom;
        sps.LoadFlowParameters(end).type='Three Phase Dynamic Load';


        sps.LoadFlowParameters(end).set.ActivePower=LoadFlowParameters(2);
        sps.LoadFlowParameters(end).set.ReactivePower=LoadFlowParameters(5);

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=2;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=2;


        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')

            if isfield(sps,'LoadFlow')
                LFTYPE='LoadFlow';
            else
                LFTYPE='UnbalancedLoadFlow';
            end


            Fields=fieldnames(sps.(LFTYPE).pqload);

            Values={'DYN load','PQ',P0,Q0,-inf,+inf,nodes,block};

            for k=1:length(Values)
                sps.(LFTYPE).pqload.(Fields{k}){i}=Values{k};
            end


            sps.(LFTYPE).pqload.S{i}=0;
            sps.(LFTYPE).pqload.Vt{i}=1;
            sps.(LFTYPE).pqload.I{i}=0;
            sps.(LFTYPE).pqload.vnom{i}=Vnom;

            sps.(LFTYPE).pqload.busNumber{i}=NaN;
        end

    end

    sps.nbmodels(21)=size(sps.modelnames{21},2);