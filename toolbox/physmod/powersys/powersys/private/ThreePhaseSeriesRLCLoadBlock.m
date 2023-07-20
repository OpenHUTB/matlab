function[sps,Multimeter,NewNode]=ThreePhaseSeriesRLCLoadBlock(nl,sps,Multimeter,NewNode)





    idx=nl.filter_type('Three-Phase Series RLC Load');

    if isfield(sps,'UnbalancedLoadFlow')
        Nloads=length(sps.UnbalancedLoadFlow.rlcload.P);
    end

    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));
    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');


        nodes=nl.block_nodes(block);

        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        Configuration=get_param(block,'Configuration');

        switch get_param(block,'UnbalancedPower');

        case 'on'
            switch Configuration
            case{'Y (grounded)','Y (floating)','Y (neutral)'}
                [Pabc,QLabc,QCabc]=getSPSmaskvalues(block,{'Pabc','QLabc','QCabc'});
                [Vabc,fn]=getSPSmaskvalues(block,{'Vabc','NominalFrequency'});
            case 'Delta'
                [Pabc,QLabc,QCabc]=getSPSmaskvalues(block,{'Pabcp','QLabcp','QCabcp'});
                [Vabc,fn]=getSPSmaskvalues(block,{'Vabcp','NominalFrequency'});
                Vabc=Vabc/sqrt(3);
            end
            Pna=Pabc(1);
            Qla=QLabc(1);
            Qca=QCabc(1);
            blocinit(block,{Vabc(1),fn,Pna,Qla,Qca});
            Iba=sqrt((Qla-Qca)^2+Pna^2)/Vabc(1);

            Pnb=Pabc(2);
            Qlb=QLabc(2);
            Qcb=QCabc(2);
            blocinit(block,{Vabc(2),fn,Pnb,Qlb,Qcb});
            Ibb=sqrt((Qlb-Qcb)^2+Pnb^2)/Vabc(2);
            Pnc=Pabc(3);
            Qlc=QLabc(3);
            Qcc=QCabc(3);
            blocinit(block,{Vabc(3),fn,Pnc,Qlc,Qcc});
            Ibc=sqrt((Qlc-Qcc)^2+Pnc^2)/Vabc(3);


            Pn=Pna+Pnb+Pnc;
            Vb=Vabc(1);
            Ql=Qla+Qlb+Qlc;
            Qc=Qca+Qcb+Qcc;

        case 'off'
            [Vb,fn]=getSPSmaskvalues(block,{'NominalVoltage','NominalFrequency'});
            Vb=Vb/sqrt(3);
            Vabc=[Vb,Vb,Vb];
            [Pn,Ql,Qc]=getSPSmaskvalues(block,{'ActivePower','InductivePower','CapacitivePower'});
            blocinit(block,{Vb,fn,Pn,Ql,Qc});
            Pna=Pn/3;
            Qla=Ql/3;
            Qca=Qc/3;
            Iba=sqrt((Qla-Qca)^2+Pna^2)/Vb;

            Pnb=Pna;
            Qlb=Qla;
            Qcb=Qca;
            Ibb=Iba;
            Pnc=Pna;
            Qlc=Qla;
            Qcc=Qca;
            Ibc=Iba;

        end


        if Qca==0
            Ca=0;
        else
            Ca=Iba*Iba/(2*pi*fn*Qca)*1e6;
        end
        if Qcb==0
            Cb=0;
        else
            Cb=Ibb*Ibb/(2*pi*fn*Qcb)*1e6;
        end
        if Qcc==0
            Cc=0;
        else
            Cc=Ibc*Ibc/(2*pi*fn*Qcc)*1e6;
        end


        switch Configuration

        case{'Y (grounded)','Y (floating)','Y (neutral)'}
            Ra=Pna/(Iba*Iba);
            La=Qla/(Iba*Iba*2*pi*fn)*1e3;
            Rb=Pnb/(Ibb*Ibb);
            Lb=Qlb/(Ibb*Ibb*2*pi*fn)*1e3;
            Rc=Pnc/(Ibc*Ibc);
            Lc=Qlc/(Ibc*Ibc*2*pi*fn)*1e3;

        case 'Delta'
            Ra=3*Pna/(Iba*Iba);
            La=3*Qla/(Iba*Iba*2*pi*fn)*1e3;
            Ca=Ca/3;
            Rb=3*Pnb/(Ibb*Ibb);
            Lb=3*Qlb/(Ibb*Ibb*2*pi*fn)*1e3;
            Cb=Cb/3;
            Rc=3*Pnc/(Ibc*Ibc);
            Lc=3*Qlc/(Ibc*Ibc*2*pi*fn)*1e3;
            Cc=Cc/3;

        end


        switch Configuration
        case 'Y (grounded)'
            Config='Yg';
            An=0;
            Bn=0;
            Cn=0;
            motA='g';
            motB='g';
            motC='g';
        case 'Y (floating)'
            Config='Yn';
            An=NewNode;
            Bn=NewNode;
            Cn=NewNode;
            NewNode=NewNode+1;
            motA='n';
            motB='n';
            motC='n';
        case 'Y (neutral)'
            Config='Yn';
            An=nodes(4);
            Bn=nodes(4);
            Cn=nodes(4);
            motA='n';
            motB='n';
            motC='n';
        case 'Delta'
            Config='D';
            An=nodes(2);
            Bn=nodes(3);
            Cn=nodes(1);
            motA='b';
            motB='c';
            motC='a';
        end


        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')
            LoadType=getSPSmaskvalues(block,{'LoadType'});
            if LoadType==1

                ADDRLC=1;
                BusType='Z';
            elseif LoadType==2

                ADDRLC=0;
                BusType='PQ';
            else

                ADDRLC=0;
                BusType='I';
            end
        else
            ADDRLC=1;
        end


        if ADDRLC
            sps.rlc(end+1:end+3,1:6)=[...
            nodes(1),An,0,Ra,La,Ca;
            nodes(2),Bn,0,Rb,Lb,Cb;
            nodes(3),Cn,0,Rc,Lc,Cc];
            if strcmp(Configuration,'Delta')
                sps.rlcnames{end+1}=['phase_AB: ',BlockNom];
                sps.rlcnames{end+1}=['phase_BC: ',BlockNom];
                sps.rlcnames{end+1}=['phase_CA: ',BlockNom];
            else
                sps.rlcnames{end+1}=['phase_A: ',BlockNom];
                sps.rlcnames{end+1}=['phase_B: ',BlockNom];
                sps.rlcnames{end+1}=['phase_C: ',BlockNom];
            end
            BrancheC=size(sps.rlc,1);
            BrancheB=BrancheC-1;
            BrancheA=BrancheB-1;
            Measurements=get_param(block,'Measurements');
            if strcmp(Measurements,'Branch voltages')||strcmp(Measurements,'Branch voltages and currents')
                Multimeter.Yu(end+1,1:2)=[nodes(1),An];
                Multimeter.V{end+1}=['Ua',motA,': ',BlockNom];
                Multimeter.Yu(end+1,1:2)=[nodes(2),Bn];
                Multimeter.V{end+1}=['Ub',motB,': ',BlockNom];
                Multimeter.Yu(end+1,1:2)=[nodes(3),Cn];
                Multimeter.V{end+1}=['Uc',motC,': ',BlockNom];
            end
            if strcmp(Measurements,'Branch currents')||strcmp(Measurements,'Branch voltages and currents')
                Multimeter.I{end+1}=['Ia',motA,': ',BlockNom];
                Multimeter.Yi{end+1,1}=BrancheA;
                Multimeter.I{end+1}=['Ib',motB,': ',BlockNom];
                Multimeter.Yi{end+1,1}=BrancheB;
                Multimeter.I{end+1}=['Ic',motC,': ',BlockNom];
                Multimeter.Yi{end+1,1}=BrancheC;
            end

        end

        if isfield(sps,'LoadFlow')


            Fields=fieldnames(sps.LoadFlow.rlcload);
            Values={'RLC load',BusType,Pn,(Ql-Qc),-inf,+inf,nodes(1:3),block};

            for k=1:length(Values)
                sps.LoadFlow.rlcload.(Fields{k}){i}=Values{k};
            end


            sps.LoadFlow.rlcload.S{i}=0;
            sps.LoadFlow.rlcload.Vt{i}=1;
            sps.LoadFlow.rlcload.I{i}=0;
            sps.LoadFlow.rlcload.vnom{i}=Vb*sqrt(3);

            sps.LoadFlow.rlcload.busNumber{i}=NaN;

            switch get_param(block,'UnbalancedPower');
            case 'on'
                Sentense1=['Invalid setting in ''',BlockNom,''' block. '];
                Sentense2='The positive-sequence Load Flow does not allow specifying individual PQ powers for each phase';
                message=sprintf([Sentense1,'\n\n',Sentense2]);

                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:Powerloadflow:BlockParameterError';
                psberror(Erreur);
            end

        end

        if isfield(sps,'UnbalancedLoadFlow')


            Fields={'blockType','busType','P','Q','Qmin','Qmax','nodes','handle'};
            Values={'RLC load',BusType,[Pna,Pnb,Pnc],[(Qla-Qca),(Qlb-Qcb),(Qlc-Qcc)],-inf,+inf,nodes(1:3),block};

            for k=1:length(Values)
                sps.UnbalancedLoadFlow.rlcload.(Fields{k}){i+Nloads}=Values{k};
            end


            sps.UnbalancedLoadFlow.rlcload.connection{i+Nloads}=Config;
            sps.UnbalancedLoadFlow.rlcload.S{i+Nloads}=0;
            sps.UnbalancedLoadFlow.rlcload.Vt{i+Nloads}=1;
            sps.UnbalancedLoadFlow.rlcload.I{i+Nloads}=0;
            sps.UnbalancedLoadFlow.rlcload.vnom{i+Nloads}=Vabc;
            sps.UnbalancedLoadFlow.rlcload.busNumber{i+Nloads}=NaN;

        end
    end