function[sps,YuNonlinear]=SynchronousMachineBlock(nl,sps,YuNonlinear)





    WantRshunt=1;

    MaskType='Synchronous Machine';
    idx=nl.filter_type(MaskType);
    sps.NbMachines=sps.NbMachines+length(idx);
    NbOut=length(sps.outstr);


    if isfield(sps,'LoadFlow')
        NV=length(sps.LoadFlow.sm.handle);
    end
    if isfield(sps,'UnbalancedLoadFlow')
        NV=length(sps.UnbalancedLoadFlow.sm.handle);
    end

    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        Units=get_param(block,'Units');
        LoadFlowParameters=getSPSmaskvalues(block,{'LoadFlowParameters'});

        [MechanicalLoad]=getSPSmaskvalues(block,{'MechanicalLoad'});
        [NominalParameters,Mechanical,InitialConditions,IM]=getSPSmaskvalues(block,{'NominalParameters','Mechanical','InitialConditions','IterativeDiscreteModel'});


        if(sps.PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(sps.PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        else
            LocallyWantDSS=0;
        end

        Stator=getSPSmaskvalues(block,{'Stator'});

        switch Units

        case 'per unit fundamental parameters'

            blocinit(block,{NominalParameters,Stator,Mechanical,InitialConditions});
            StatorResistance=Stator(1);

        case 'per unit standard parameters'

            StatorResistance=getSPSmaskvalues(block,{'StatorResistance'});
            blocinit(block,{NominalParameters,StatorResistance,Mechanical,InitialConditions});

        case 'SI fundamental parameters'

            blocinit(block,{NominalParameters,Stator,Mechanical,InitialConditions});
            StatorResistance=Stator(1);

        end

        if isequal('Speed w',get_param(block,'MechanicalLoad'))
            npp=getSPSmaskvalues(block,{'PolePairs'});
        else
            if size(Mechanical,2)==3
                npp=Mechanical(3);
            else
                npp=getSPSmaskvalues(block,{'PolePairs'});
            end
        end

        Pn=NominalParameters(1);
        Vn=NominalParameters(2);
        ibase=sqrt(2/3)*Pn/Vn;

        switch Units

        case{'per unit fundamental parameters','per unit standard parameters'}

            SIMask=0;
            Rstator=StatorResistance*Vn^2/Pn;
            Ia0=InitialConditions(3)*ibase;
            Ib0=InitialConditions(4)*ibase;

        otherwise

            SIMask=1;
            Rstator=StatorResistance;
            Ia0=InitialConditions(3);
            Ib0=InitialConditions(4);

        end

        VfMask=InitialConditions(end);
        phiIa0=InitialConditions(6);
        phiIb0=InitialConditions(7);

        MachineFrequency=NominalParameters(3);


        if sps.PowerguiInfo.WantDSS||LocallyWantDSS||sps.PowerguiInfo.DiscretePhasor
            sps.DSS.block(end+1).type='Synchronous Machine';
            sps.DSS.block(end).Blockname=BlockName;
        end





        nodes=nl.block_nodes(block);
        sps.source=[sps.source;
        nodes(3),nodes(1),1,Ia0,phiIa0,MachineFrequency,14;
        nodes(3),nodes(2),1,Ib0,phiIb0,MachineFrequency,14];

        Nsrc=size(sps.source,1);

        sps.srcstr{end+1}=['I_A: ',BlockNom];
        sps.srcstr{end+1}=['I_B: ',BlockNom];
        sps.outstr{end+1}=['U_AB: ',BlockNom];
        sps.outstr{end+1}=['U_BC: ',BlockNom];

        sps.sourcenames(end+1:end+2,1)=[block;block];

        sps.modelnames{14}(size(sps.modelnames{14},2)+1)=block;

        YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3)];
        NbOut=NbOut+2;


        ymac=size(sps.machines,2)+1;
        ysrc=size(sps.source,1)-1;

        if sps.PowerguiInfo.DiscretePhasor

            sps.DSS.block(end).size=[5,2,2];
            sps.DSS.block(end).xInit=[];
            sps.DSS.block(end).yinit=[0,0,0];
            sps.DSS.block(end).iterate=0;
            sps.DSS.block(end).VI=[];
            sps.DSS.block(end).method=1;
            sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
            sps.DSS.block(end).outputs=[NbOut-1,NbOut];
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

        else
            if sps.PowerguiInfo.WantDSS||LocallyWantDSS

                sps.DSS.block(end).size=[5,2,2];
                sps.DSS.block(end).xInit=[];
                sps.DSS.block(end).yinit=[0,0,0];
                sps.DSS.block(end).iterate=0;
                sps.DSS.block(end).VI=[];

                if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                    sps.DSS.block(end).method=2;
                elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                    sps.DSS.block(end).method=1;
                end

                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut];
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
        end


        sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];


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
        sps.machines(ymac).nominal={SIMask,Pn,Vn,npp,MachineFrequency};
        sps.machines(ymac).type=32;
        sps.machines(ymac).terminals=3;
        sps.machines(ymac).bustype=LoadFlowParameters(1);
        sps.machines(ymac).input=ysrc;
        sps.machines(ymac).output=NbOut-1;
        sps.machines(ymac).P=LoadFlowParameters(2);
        sps.machines(ymac).Q=LoadFlowParameters(5);
        sps.machines(ymac).Vt=LoadFlowParameters(3);
        sps.machines(ymac).Phase=LoadFlowParameters(4);
        sps.machines(ymac).Ef=VfMask;
        sps.machines(ymac).Pmec=Rstator;
        sps.machines(ymac).slip=[];
        sps.machines(ymac).torque=120*MachineFrequency/(2*npp);







        sps.LoadFlowParameters(end+1).name=BlockNom;
        sps.LoadFlowParameters(end).type='Synchronous Machine';


        switch LoadFlowParameters(1)
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
        sps.NonlinearDevices.Demux(end+1)=2;

        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=2;


        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')

            if isfield(sps,'LoadFlow')
                LFTYPE='LoadFlow';
            else
                LFTYPE='UnbalancedLoadFlow';
            end


            Fields=fieldnames(sps.(LFTYPE).sm);

            BusType=getSPSmaskvalues(block,{'BusType'});

            Values={'SM',BusType,getSPSmaskvalues(block,{'Pref'}),...
            getSPSmaskvalues(block,{'Qref'}),getSPSmaskvalues(block,{'Qmin'}),...
            getSPSmaskvalues(block,{'Qmax'}),nodes,block};

            for k=1:length(Values)
                sps.(LFTYPE).sm.(Fields{k}){i+NV}=Values{k};
            end



            sps.(LFTYPE).sm.vnom{i+NV}=NominalParameters(2);
            sps.(LFTYPE).sm.pnom{i+NV}=NominalParameters(1);

            SM=getSPSmaskvalues(block,{'SM'});
            sps.(LFTYPE).sm.rs{i+NV}=SM.Rs;
            sps.(LFTYPE).sm.xd{i+NV}=SM.Ll+SM.Lmd;
            sps.(LFTYPE).sm.xq{i+NV}=SM.Ll+SM.Lmq;


            sps.(LFTYPE).sm.prefpu{i+NV}=0;
            sps.(LFTYPE).sm.S{i+NV}=0;
            sps.(LFTYPE).sm.Vt{i+NV}=0;
            sps.(LFTYPE).sm.Vf{i+NV}=0;

            switch Units
            case 'SI fundamental parameters'
                sps.(LFTYPE).sm.Vfn{i+NV}=SM.vfn;
            otherwise
                sps.(LFTYPE).sm.Vfn{i+NV}=NaN;
            end

            sps.(LFTYPE).sm.pmec{i+NV}=0;
            sps.(LFTYPE).sm.I{i+NV}=0;
            sps.(LFTYPE).sm.th0deg{i+NV}=0;

            sps.(LFTYPE).sm.freq{i+NV}=MachineFrequency;
            sps.(LFTYPE).sm.Units{i+NV}=Units;
            sps.(LFTYPE).sm.MechLoad{i+NV}=MechanicalLoad;
            sps.(LFTYPE).sm.dw0{i+NV}=InitialConditions(1);
            sps.(LFTYPE).sm.pp{i+NV}=npp;
            sps.(LFTYPE).sm.srcblkPm{i+NV}=sps.machines(ymac).SourceBlock1{1};
            sps.(LFTYPE).sm.srcparamPm{i+NV}=sps.machines(ymac).SourceBlock1{2};
            sps.(LFTYPE).sm.srcblkVref{i+NV}=sps.machines(ymac).SourceBlock2{1};
            sps.(LFTYPE).sm.srcparamVref{i+NV}=sps.machines(ymac).SourceBlock2{2};
            sps.(LFTYPE).sm.srcblkSHTG{i+NV}=sps.machines(ymac).SourceBlock1{3};
            sps.(LFTYPE).sm.srcparamSHTG{i+NV}=sps.machines(ymac).SourceBlock1{4};
            sps.(LFTYPE).sm.srcblkExci{i+NV}=sps.machines(ymac).SourceBlock2{3};
            sps.(LFTYPE).sm.srcparamExci{i+NV}=sps.machines(ymac).SourceBlock2{4};

            sps.(LFTYPE).sm.busNumber{i+NV}=NaN;

            if isfield(sps,'UnbalancedLoadFlow')
                sps.UnbalancedLoadFlow.sm.Z2{i+NV}=SM.Rs+1i*SM.L2_pu;
            end

        end

        if sps.PowerguiInfo.Discrete
            switch get_param(block,'IterativeModel')
            case 'Forward Euler'
                message=['The Discrete Solver Model parameter of the ''',BlockNom,'''  block is set to Forward Euler. For better accuracy, it is recommended that you use a Trapezoidal model. ',...
                'When using electrical machines in discrete systems, you might have to add a  parasitic ',...
                'resistive load at machine terminals to avoid numerical oscillations. The amount of parasitic load depends on the ',...
                'sample time and on the integration method used to discretize the electrical machine.'];
                warning('SpecializedPowerSystems:MachineBlocks:DiscreteSolverModel',message)
            end
        end

    end

    sps.nbmodels(14)=size(sps.modelnames{14},2);
