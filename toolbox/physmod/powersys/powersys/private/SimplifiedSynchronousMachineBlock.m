function[sps,YuNonlinear]=SimplifiedSynchronousMachineBlock(nl,sps,YuNonlinear)





    WantRshunt=1;

    MaskType='Simplified Synchronous Machine';
    idx=nl.filter_type(MaskType);
    sps.NbMachines=sps.NbMachines+length(idx);
    NbOut=length(sps.outstr);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        [MechanicalLoad]=getSPSmaskvalues(block,{'MechanicalLoad'});

        [NominalParameters,Mechanical,InternalRL,InitialConditions,IM]=getSPSmaskvalues(block,{'NominalParameters','Mechanical','InternalRL','InitialConditions','IterativeDiscreteModel'});

        if(sps.PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(sps.PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        else
            LocallyWantDSS=0;
        end

        if sps.PowerguiInfo.DiscretePhasor
            LocallyWantDSS=1;
        end


        ConnectionType=get_param(block,'ConnectionType');
        blocinit(block,{ConnectionType,NominalParameters,Mechanical,InternalRL,InitialConditions});
        Units=getSPSmaskvalues(block,{'Units'})';
        threewires=strcmp(ConnectionType,'3-wire Y');
        LoadFlowParameters=getSPSmaskvalues(block,{'LoadFlowParameters'});



        Pn=NominalParameters(1);
        Vn=NominalParameters(2);
        ibase=sqrt(2/3)*Pn/Vn;
        Ia0=InitialConditions(3)*ibase;
        Ib0=InitialConditions(4)*ibase;
        Ic0=InitialConditions(5)*ibase;
        Rstator=InternalRL(1)*Vn^2/Pn;


        phiIa0=InitialConditions(6);
        phiIb0=InitialConditions(7);
        phiIc0=InitialConditions(8);
        MachineFrequency=NominalParameters(3);


        if sps.PowerguiInfo.WantDSS||LocallyWantDSS
            sps.DSS.block(end+1).type='Simplified Synchronous Machine';
            sps.DSS.block(end).Blockname=BlockName;
        end






        nodes=nl.block_nodes(block);

        if threewires

            nStates=2;
            nInputs=2;
            nOutputs=2;

            sps.NonlinearDevices.Demux(end+1)=2;
            sps.U.Mux(end+1)=2;

            sps.source(end+1:end+2,1:7)=[...
            nodes(4),nodes(2),1,Ia0,phiIa0,MachineFrequency,13;
            nodes(4),nodes(3),1,Ib0,phiIb0,MachineFrequency,13];

            sps.srcstr{end+1}=['I_A: ',BlockNom];
            sps.srcstr{end+1}=['I_B: ',BlockNom];
            sps.outstr{end+1}=['U_AB: ',BlockNom];
            sps.outstr{end+1}=['U_BC: ',BlockNom];
            sps.sourcenames(end+1:end+2,1)=[block;block];


            YuNonlinear(end+1:end+2,1:2)=[nodes(2),nodes(3);nodes(3),nodes(4)];
            NbOut=NbOut+2;
            loadflowoutref=1;


            ysrc=size(sps.source,1)-1;
            sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];

        else

            nStates=3;
            nInputs=3;
            nOutputs=3;

            sps.NonlinearDevices.Demux(end+1)=3;
            sps.U.Mux(end+1)=3;



            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor,BlockName,'4-Wire Simplified synchronous Machine');

            sps.source(end+1:end+3,1:7)=[...
            nodes(1),nodes(2),1,Ia0,phiIa0,MachineFrequency,13;
            nodes(1),nodes(3),1,Ib0,phiIb0,MachineFrequency,13;
            nodes(1),nodes(4),1,Ic0,phiIc0,MachineFrequency,13];

            sps.srcstr{end+1}=['I_A: ',BlockNom];
            sps.srcstr{end+1}=['I_B: ',BlockNom];
            sps.srcstr{end+1}=['I_C: ',BlockNom];
            sps.outstr{end+1}=['U_A: ',BlockNom];
            sps.outstr{end+1}=['U_B: ',BlockNom];
            sps.outstr{end+1}=['U_C: ',BlockNom];
            sps.sourcenames(end+1:end+3,1)=[block,block,block];



            YuNonlinear(end+1:end+3,1:2)=[nodes(2),nodes(1);nodes(3),nodes(1);nodes(4),nodes(1)];

            NbOut=NbOut+3;

            loadflowoutref=2;


            ysrc=size(sps.source,1)-2;
            sps.InputsNonZero(end+1:end+3)=[ysrc,ysrc+1,ysrc+2];

        end

        xc=size(sps.modelnames{13},2);
        sps.modelnames{13}(xc+1)=block;


        ymac=size(sps.machines,2)+1;

        Nsrc=size(sps.source,1);

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS

            sps.DSS.block(end).size=[nStates,nInputs,nOutputs];
            sps.DSS.block(end).xInit=[];
            sps.DSS.block(end).yinit=[0,0,0];
            sps.DSS.block(end).iterate=0;
            sps.DSS.block(end).VI=[];

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                sps.DSS.block(end).method=2;
            elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                sps.DSS.block(end).method=1;
            end

            if threewires

                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut];

            else
                sps.DSS.block(end).inputs=[Nsrc-2,Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-2,NbOut-1,NbOut];
            end


            sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
            sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

            if WantRshunt


                PercentPower=0.01/100;
                Rparasitic=3*Vn^2/(Pn*PercentPower);
                sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Rparasitic,0,0];
                sps.rlc(end+1,1:6)=[nodes(2),nodes(3),0,Rparasitic,0,0];
                sps.rlc(end+1,1:6)=[nodes(3),nodes(1),0,Rparasitic,0,0];
                sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];

            end

        end



        ports=get_param(block,'PortConnectivity');

        switch MechanicalLoad
        case 'Mechanical rotational port'

            sourceblk1=-1;
            sourceport1=1;
            sourcetype1='';
            [sourceblk2,sourceport2,sourcetype2]=BlockSearch(ports(1),block,1);
        otherwise
            [sourceblk1,sourceport1,sourcetype1]=BlockSearch(ports(1),block,1);
            [sourceblk2,sourceport2,sourcetype2]=BlockSearch(ports(2),block,2);

        end

        sps.machines(ymac).SourceBlock1={[],[],[],[]};
        sps.machines(ymac).SourceBlock2={[],[],[],[]};

        if sourceblk1<0
            sps.machines(ymac).SourceBlock1{1}=abs(sourceblk1);
            sps.machines(ymac).SourceBlock1{2}=sourceport1;
        elseif strcmp('line',get_param(sourceblk1,'type'))

            sps.machines(ymac).SourceBlock1{1}=[];
            sps.machines(ymac).SourceBlock1{2}=[];
        else
            if strcmp(get_param(sourceblk1,'BlockType'),'Constant')
                sps.machines(ymac).SourceBlock1{1}=abs(sourceblk1);
                sps.machines(ymac).SourceBlock1{2}='Value';
            end
            if strcmp(get_param(sourceblk1,'BlockType'),'Step')
                sps.machines(ymac).SourceBlock1{1}=abs(sourceblk1);
                sps.machines(ymac).SourceBlock1{2}='Before';
            end
        end

        if sourceblk2<0
            sps.machines(ymac).SourceBlock2{1}=abs(sourceblk2);
            sps.machines(ymac).SourceBlock2{2}=sourceport2;
        elseif strcmp('line',get_param(sourceblk2,'type'))

            sps.machines(ymac).SourceBlock2{1}=[];
            sps.machines(ymac).SourceBlock2{2}=[];
        else
            if strcmp(get_param(sourceblk2,'BlockType'),'Constant')
                sps.machines(ymac).SourceBlock2{1}=abs(sourceblk2);
                sps.machines(ymac).SourceBlock2{2}='Value';
            end
            if strcmp(get_param(sourceblk2,'BlockType'),'Step')
                sps.machines(ymac).SourceBlock2{1}=abs(sourceblk2);
                sps.machines(ymac).SourceBlock2{2}='Before';
            end
        end



        if~isempty(sourcetype1)
            portsHTGSTG=get_param(abs(sourceblk1),'PortConnectivity');
            sourceHTGSTG=BlockSearch(portsHTGSTG(2),abs(sourceblk1),2);
            if sourceHTGSTG>0
                if strcmp('line',get_param(sourceHTGSTG,'type'))

                    sps.machines(ymac).SourceBlock1{3}=[];
                    sps.machines(ymac).SourceBlock1{4}='NotAbleToSet';
                elseif strcmp(get_param(sourceHTGSTG,'BlockType'),'Constant')
                    sps.machines(ymac).SourceBlock1{3}=abs(sourceHTGSTG);
                    sps.machines(ymac).SourceBlock1{4}='Value';
                elseif strcmp(get_param(sourceHTGSTG,'BlockType'),'Step')
                    sps.machines(ymac).SourceBlock1{3}=abs(sourceHTGSTG);
                    sps.machines(ymac).SourceBlock1{4}='Before';
                end
            end
        end



        if~isempty(sourcetype2)
            portsEXCIT=get_param(abs(sourceblk2),'PortConnectivity');
            sourceEXCIT=BlockSearch(portsEXCIT(1),abs(sourceblk2),1);
            if sourceEXCIT>0
                if strcmp('line',get_param(sourceEXCIT,'type'))

                    sps.machines(ymac).SourceBlock2{3}=[];
                    sps.machines(ymac).SourceBlock2{4}='NotAbleToSet';
                elseif strcmp(get_param(sourceEXCIT,'BlockType'),'Constant')
                    sps.machines(ymac).SourceBlock2{3}=abs(sourceEXCIT);
                    sps.machines(ymac).SourceBlock2{4}='Value';
                elseif strcmp(get_param(sourceEXCIT,'BlockType'),'Step')
                    sps.machines(ymac).SourceBlock2{3}=abs(sourceEXCIT);
                    sps.machines(ymac).SourceBlock2{4}='Before';
                end
            end
        end


        if length(LoadFlowParameters)<5
            LoadFlowParameters(5)=0;
        end
        if LoadFlowParameters(3)==0
            LoadFlowParameters(3)=Vn;
        end

        sps.machines(ymac).name=BlockNom;
        sps.machines(ymac).nominal={Units,Pn,Vn,Mechanical(3),MachineFrequency};
        sps.machines(ymac).type=31;
        sps.machines(ymac).terminals=4-threewires;
        sps.machines(ymac).bustype=LoadFlowParameters(1);
        sps.machines(ymac).input=ysrc;
        sps.machines(ymac).output=NbOut-loadflowoutref;
        sps.machines(ymac).P=LoadFlowParameters(2);
        sps.machines(ymac).Q=LoadFlowParameters(5);
        sps.machines(ymac).Vt=LoadFlowParameters(3);
        sps.machines(ymac).Phase=LoadFlowParameters(4);
        sps.machines(ymac).Ef=[];
        sps.machines(ymac).Pmec=Rstator;
        sps.machines(ymac).slip=[];
        sps.machines(ymac).torque=120*MachineFrequency/(2*Mechanical(3));







        sps.LoadFlowParameters(end+1).name=BlockNom;
        sps.LoadFlowParameters(end).type='Simplified Synchronous Machine';


        switch LoadFlowParameters(1);
        case 1
            BusType='P & V generator';
        case 2
            BusType='Swing bus';
        case 4
            BusType='P & Q generator';
        end
        sps.LoadFlowParameters(end).set.BusType=BusType;
        sps.LoadFlowParameters(end).set.TerminalVoltage=LoadFlowParameters(3);
        sps.LoadFlowParameters(end).set.ActivePower=LoadFlowParameters(2);
        sps.LoadFlowParameters(end).set.ReactivePower=LoadFlowParameters(5);
        sps.LoadFlowParameters(end).set.PhaseUan=LoadFlowParameters(4);


        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');


        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')

            if isfield(sps,'LoadFlow')
                LFTYPE='LoadFlow';
            else
                LFTYPE='UnbalancedLoadFlow';
            end


            Fields=fieldnames(sps.LoadFlow.sm);

            BusType=getSPSmaskvalues(block,{'BusType'});

            Values={'SMsimple',BusType,getSPSmaskvalues(block,{'Pref'}),...
            getSPSmaskvalues(block,{'Qref'}),getSPSmaskvalues(block,{'Qmin'}),...
            getSPSmaskvalues(block,{'Qmax'}),nodes(2:4),block};

            for k=1:length(Values)
                sps.(LFTYPE).sm.(Fields{k}){i}=Values{k};
            end



            sps.(LFTYPE).sm.vnom{i}=NominalParameters(2);
            sps.(LFTYPE).sm.pnom{i}=NominalParameters(1);

            SM=getSPSmaskvalues(block,{'SSM'});
            sps.(LFTYPE).sm.rs{i}=SM.R;
            sps.(LFTYPE).sm.xd{i}=SM.L;
            sps.(LFTYPE).sm.xq{i}=SM.L;


            sps.(LFTYPE).sm.prefpu{i}=0;
            sps.(LFTYPE).sm.S{i}=0;
            sps.(LFTYPE).sm.Vt{i}=0;
            sps.(LFTYPE).sm.Vf{i}=0;
            sps.(LFTYPE).sm.pmec{i}=0;
            sps.(LFTYPE).sm.I{i}=0;
            sps.(LFTYPE).sm.th0deg{i}=0;

            sps.(LFTYPE).sm.freq{i}=MachineFrequency;
            sps.(LFTYPE).sm.Units{i}=Units;
            sps.(LFTYPE).sm.MechLoad{i}=MechanicalLoad;
            sps.(LFTYPE).sm.dw0{i}=InitialConditions(1);
            sps.(LFTYPE).sm.pp{i}=Mechanical(3);
            sps.(LFTYPE).sm.Vfn{i}=Vn;
            sps.(LFTYPE).sm.srcblkPm{i}=sps.machines(ymac).SourceBlock1{1};
            sps.(LFTYPE).sm.srcparamPm{i}=sps.machines(ymac).SourceBlock1{2};
            sps.(LFTYPE).sm.srcblkVref{i}=sps.machines(ymac).SourceBlock2{1};
            sps.(LFTYPE).sm.srcparamVref{i}=sps.machines(ymac).SourceBlock2{2};
            sps.(LFTYPE).sm.srcblkSHTG{i}=sps.machines(ymac).SourceBlock1{3};
            sps.(LFTYPE).sm.srcparamSHTG{i}=sps.machines(ymac).SourceBlock1{4};
            sps.(LFTYPE).sm.srcblkExci{i}=sps.machines(ymac).SourceBlock2{3};
            sps.(LFTYPE).sm.srcparamExci{i}=sps.machines(ymac).SourceBlock2{4};

            sps.(LFTYPE).sm.busNumber{i}=NaN;

            if isfield(sps,'UnbalancedLoadFlow')
                sps.UnbalancedLoadFlow.sm.Z2{i}=NaN;
            end

        end


    end

    sps.nbmodels(13)=size(sps.modelnames{13},2);