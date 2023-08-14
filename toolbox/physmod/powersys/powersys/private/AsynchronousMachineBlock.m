function[sps,YuNonlinear]=AsynchronousMachineBlock(nl,sps,YuNonlinear)






    WantRshunt=1;

    MaskType='Asynchronous Machine';
    idx=nl.filter_type(MaskType);
    sps.NbMachines=sps.NbMachines+length(idx);
    NbOut=length(sps.outstr);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        [NominalParameters,Mechanical,InitialConditions,LoadFlowParameters,IM]=getSPSmaskvalues(block,{'NominalParameters','Mechanical','InitialConditions','LoadFlowParameters','IterativeDiscreteModel'});


        if(sps.PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(sps.PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        else
            LocallyWantDSS=0;
        end

        RotorType=get_param(block,'RotorType');

        [MechanicalLoad]=getSPSmaskvalues(block,{'MechanicalLoad'});

        Units=get_param(block,'Units');
        SlipMask=InitialConditions(1);

        switch MechanicalLoad
        case 'Torque Tm'
            if size(Mechanical,2)==3
                pairsofpoles=Mechanical(3);
            else
                pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});
            end
        case 'Speed w'
            pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});
        case 'Mechanical rotational port'
            if size(Mechanical,2)==3
                pairsofpoles=Mechanical(3);
            else
                pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});
            end

        end


        Pn=NominalParameters(1);
        Vn=NominalParameters(2);
        ibase=sqrt(2/3)*Pn/Vn;


        switch Units
        case 'pu'

            SImask=0;
            Ia0=InitialConditions(3)*ibase;
            Ib0=InitialConditions(4)*ibase;

        case 'SI'

            SImask=1;
            Ia0=InitialConditions(3);
            Ib0=InitialConditions(4);
        end

        phia0=InitialConditions(6);
        phib0=InitialConditions(7);


        if length(InitialConditions)==14


            switch Units
            case 'pu'
                Ia0r=InitialConditions(9)*ibase;
                Ib0r=InitialConditions(10)*ibase;
            case 'SI'
                Ia0r=InitialConditions(9);
                Ib0r=InitialConditions(10);
            end

            phia0r=InitialConditions(12);
            phib0r=InitialConditions(13);

        else

            Ia0r=0;
            phia0r=0;
            Ib0r=0;
            phib0r=0;

        end

        MachineFrequency=NominalParameters(3);

        xc=size(sps.modelnames{15},2);
        sps.modelnames{15}(xc+1)=block;

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS||sps.PowerguiInfo.DiscretePhasor


            sps.DSS.block(end+1).type=['Asynchronous Machine ',RotorType];
            sps.DSS.block(end).Blockname=BlockName;
        end






        nodes=nl.block_nodes(block);

        switch RotorType

        case 'Wound'

            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Asynchronous Machine Wound Rotor');

            sps.NonlinearDevices.Demux(end+1)=4;
            sps.U.Mux(end+1)=4;

            sps.source=[sps.source;
            nodes(4),nodes(6),1,Ia0r,phia0r,MachineFrequency,15.1;
            nodes(5),nodes(6),1,Ib0r,phib0r,MachineFrequency,15.1;
            nodes(1),nodes(3),1,Ia0,phia0,MachineFrequency,15.2
            nodes(2),nodes(3),1,Ib0,phib0,MachineFrequency,15.2];

            sps.srcstr{end+1}=['I_A_rotor: ',BlockNom];
            sps.srcstr{end+1}=['I_B_rotor: ',BlockNom];
            sps.srcstr{end+1}=['I_A_stator: ',BlockNom];
            sps.srcstr{end+1}=['I_B_stator: ',BlockNom];
            sps.outstr{end+1}=['U_AB_rotor: ',BlockNom];
            sps.outstr{end+1}=['U_BC_rotor: ',BlockNom];
            sps.outstr{end+1}=['U_AB_stator: ',BlockNom];
            sps.outstr{end+1}=['U_BC_stator: ',BlockNom];

            sps.sourcenames(end+1:end+4,1)=[block;block;block;block];
            YuNonlinear(end+1:end+4,1:2)=[nodes(4),nodes(5);nodes(5),nodes(6);nodes(1),nodes(2);nodes(2),nodes(3)];
            NbOut=NbOut+4;


            Nsrc=size(sps.source,1);
            sps.InputsNonZero(end+1:end+4)=[Nsrc-3,Nsrc-2,Nsrc-1,Nsrc];

            if sps.PowerguiInfo.DiscretePhasor

                sps.DSS.block(end).size=[4,4,4];
                sps.DSS.block(end).xInit=[];
                sps.DSS.block(end).yinit=[0,0,0,0];
                sps.DSS.block(end).iterate=0;
                sps.DSS.block(end).VI=[];
                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc,Nsrc-3,Nsrc-2];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut,NbOut-3,NbOut-2];
                sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
                sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

            else
                if sps.PowerguiInfo.WantDSS||LocallyWantDSS

                    sps.DSS.block(end).size=[4,4,4];
                    sps.DSS.block(end).xInit=[];
                    sps.DSS.block(end).yinit=[0,0,0,0];
                    sps.DSS.block(end).iterate=0;
                    sps.DSS.block(end).VI=[];
                    sps.DSS.block(end).inputs=[Nsrc-1,Nsrc,Nsrc-3,Nsrc-2];
                    sps.DSS.block(end).outputs=[NbOut-1,NbOut,NbOut-3,NbOut-2];
                    sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
                    sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

                end
            end

        case{'Squirrel-cage','Double squirrel-cage'}


            sps.NonlinearDevices.Demux(end+1)=2;
            sps.U.Mux(end+1)=2;

            sps.source=[sps.source;
            nodes(1),nodes(3),1,Ia0,phia0,MachineFrequency,15.2;
            nodes(2),nodes(3),1,Ib0,phib0,MachineFrequency,15.2];

            sps.srcstr{end+1}=['I_A_stator: ',BlockNom];
            sps.srcstr{end+1}=['I_B_stator: ',BlockNom];
            sps.outstr{end+1}=['U_AB: ',BlockNom];
            sps.outstr{end+1}=['U_BC: ',BlockNom];

            sps.sourcenames(end+1:end+2,1)=[block;block];

            YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3)];
            NbOut=NbOut+2;


            Nsrc=size(sps.source,1);
            sps.InputsNonZero(end+1:end+2)=[Nsrc-1,Nsrc];

            if sps.PowerguiInfo.DiscretePhasor

                sps.DSS.block(end).size=[4,2,2];
                sps.DSS.block(end).xInit=[];
                sps.DSS.block(end).yinit=[0,0];
                sps.DSS.block(end).iterate=0;
                sps.DSS.block(end).VI=[];
                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut];
                sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
                sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

            elseif sps.PowerguiInfo.WantDSS||LocallyWantDSS

                sps.DSS.block(end).size=[4,2,2];
                sps.DSS.block(end).xInit=[];
                sps.DSS.block(end).yinit=[0,0];
                sps.DSS.block(end).iterate=0;
                sps.DSS.block(end).VI=[];
                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut];
                sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
                sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

            end
        end


        if WantRshunt&&(sps.PowerguiInfo.WantDSS||LocallyWantDSS||sps.PowerguiInfo.DiscretePhasor)

            PercentPower=0.01/100;
            Rparasitic=3*Vn^2/(Pn*PercentPower);
            sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Rparasitic,0,0];
            sps.rlc(end+1,1:6)=[nodes(2),nodes(3),0,Rparasitic,0,0];
            sps.rlc(end+1,1:6)=[nodes(3),nodes(1),0,Rparasitic,0,0];
            sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
            sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
            sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];

        end

        if sps.PowerguiInfo.DiscretePhasor==0


            if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                sps.DSS.block(end).method=2;
            elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                sps.DSS.block(end).method=1;
            end
        end


        ports=get_param(block,'PortConnectivity');

        switch MechanicalLoad
        case{'Torque Tm','Speed w'}
            [sourceblk1,sourceport1]=BlockSearch(ports(1),block,1);
        otherwise
            sourceblk1=-1;
            sourceport1=1;
        end

        ymac=size(sps.machines,2)+1;
        sps.machines(ymac).SourceBlock1={[],[]};
        sps.machines(ymac).SourceBlock2={[],[]};

        if sourceblk1<0

            sps.machines(ymac).SourceBlock1={abs(sourceblk1),sourceport1};

        elseif strcmp('line',get_param(sourceblk1,'type'))


            sps.machines(ymac).SourceBlock1{1}=[];
            sps.machines(ymac).SourceBlock1{2}=[];

        else

            if strcmp(get_param(sourceblk1,'BlockType'),'Constant')
                sps.machines(ymac).SourceBlock1={abs(sourceblk1),'Value'};
            end

            if strcmp(get_param(sourceblk1,'BlockType'),'Step')
                sps.machines(ymac).SourceBlock1={abs(sourceblk1),'Before'};
            end

        end

        MachineFullName=getfullname(block);

        sps.machines(ymac).name=MachineFullName(sps.syslength:end);
        sps.machines(ymac).nominal={SImask,NominalParameters(1),NominalParameters(2),pairsofpoles,MachineFrequency};
        sps.machines(ymac).type=33;
        sps.machines(ymac).terminals=3;
        sps.machines(ymac).bustype=3;
        sps.machines(ymac).input=Nsrc-1;
        sps.machines(ymac).output=NbOut-1;
        sps.machines(ymac).P=[];
        sps.machines(ymac).Q=[];
        sps.machines(ymac).Vt=[];
        sps.machines(ymac).Phase=0;
        sps.machines(ymac).Ef=[];
        sps.machines(ymac).Pmec=LoadFlowParameters;
        sps.machines(ymac).slip=SlipMask;
        sps.machines(ymac).torque=120*MachineFrequency/(2*pairsofpoles);







        sps.LoadFlowParameters(end+1).name=MachineFullName(sps.syslength:end);
        sps.LoadFlowParameters(end).type='Asynchronous Machine';


        sps.LoadFlowParameters(end).set.MechanicalPower=LoadFlowParameters;

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');



        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')

            if isfield(sps,'LoadFlow')
                LFTYPE='LoadFlow';
            else
                LFTYPE='UnbalancedLoadFlow';
            end


            Fields=fieldnames(sps.(LFTYPE).asm);
            Values={'ASM','-',getSPSmaskvalues(block,{'Pmec'}),0,0,0,nodes(1:3),block};

            for k=1:length(Values)
                sps.(LFTYPE).asm.(Fields{k}){i}=Values{k};
            end



            sps.(LFTYPE).asm.vnom{i}=NominalParameters(2);
            sps.(LFTYPE).asm.pnom{i}=NominalParameters(1);
            sps.(LFTYPE).asm.pmec{i}=getSPSmaskvalues(block,{'Pmec'});

            SM=getSPSmaskvalues(block,{'SM'});
            sps.(LFTYPE).asm.r1{i}=SM.Rs;
            sps.(LFTYPE).asm.r2{i}=SM.Rr;
            sps.(LFTYPE).asm.x1{i}=SM.Lls;
            sps.(LFTYPE).asm.x2{i}=SM.Llr;
            sps.(LFTYPE).asm.xm{i}=SM.Lm;

            sps.(LFTYPE).asm.S{i}=0;
            sps.(LFTYPE).asm.I{i}=0;
            sps.(LFTYPE).asm.T{i}=0;
            sps.(LFTYPE).asm.slip{i}=0;

            sps.(LFTYPE).asm.freq{i}=MachineFrequency;
            sps.(LFTYPE).asm.Theta{i}=InitialConditions(2);
            sps.(LFTYPE).asm.Units{i}=Units;
            sps.(LFTYPE).asm.MechLoad{i}=MechanicalLoad;
            sps.(LFTYPE).asm.pole{i}=pairsofpoles;
            sps.(LFTYPE).asm.F{i}=Mechanical(2);
            sps.(LFTYPE).asm.Srcblk{i}=sps.machines(ymac).SourceBlock1{1};
            sps.(LFTYPE).asm.Srcparam{i}=sps.machines(ymac).SourceBlock1{2};

            sps.(LFTYPE).asm.busNumber{i}=NaN;

        end

        if sps.PowerguiInfo.Discrete
            switch get_param(block,'IterativeModel')
            case 'Forward Euler'

                Parent=get_param(block,'Parent');
                if isequal(Parent,getfullname(bdroot(block)))
                    Parent='';
                else
                    Parent=get_param(Parent,'MaskType');
                end

                switch Parent
                case{'Field-Oriented Control Induction Motor Drive'}
                otherwise

                    message=['The Discrete Solver Model parameter of the ''',BlockNom,'''  block is set to Forward Euler. Use a Trapezoidel model for better accuracy.',...
                    'When using electrical machines in discrete systems, you might have to add a  parasitic ',...
                    'resistive load at machine terminals to avoid numerical oscillations. The amount of parasitic load depends on the ',...
                    'sample time and on the integration method used to discretize the electrical machine.'];
                    warning('SpecializedPowerSystems:MachineBlocks:DiscreteSolverModel',message)
                end
            end
        end

    end

    sps.nbmodels(15)=size(sps.modelnames{15},2);