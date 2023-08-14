function[sps,Multimeter,NewNode]=ThreePhaseParallelRLCLoadBlock(nl,sps,Multimeter,NewNode)





    idx=nl.filter_type('Three-Phase Parallel RLC Load');

    if isfield(sps,'LoadFlow')
        Nloads=length(sps.LoadFlow.rlcload.P);
    end
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
            end
            Pna=Pabc(1);
            Qla=QLabc(1);
            Qca=QCabc(1);
            Vba=Vabc(1);
            blocinit(block,{Vba,fn,Pna,Qla,Qca});
            Pnb=Pabc(2);
            Qlb=QLabc(2);
            Qcb=QCabc(2);
            Vbb=Vabc(2);
            blocinit(block,{Vbb,fn,Pnb,Qlb,Qcb});
            Pnc=Pabc(3);
            Qlc=QLabc(3);
            Qcc=QCabc(3);
            Vbc=Vabc(3);
            blocinit(block,{Vbc,fn,Pnc,Qlc,Qcc});


            Pn=Pna+Pnb+Pnc;
            Vb=Vabc(1);
            Ql=Qla+Qlb+Qlc;
            Qc=Qca+Qcb+Qcc;

        case 'off'
            [Vb,fn]=getSPSmaskvalues(block,{'NominalVoltage','NominalFrequency'});
            Vba=Vb/sqrt(3);
            Vbb=Vba;
            Vbc=Vba;
            [Pn,Ql,Qc]=getSPSmaskvalues(block,{'ActivePower','InductivePower','CapacitivePower'});
            blocinit(block,{Vb,fn,Pn,Ql,Qc});
            Pna=Pn/3;
            Qla=Ql/3;
            Qca=Qc/3;
            Pnb=Pn/3;
            Qlb=Ql/3;
            Qcb=Qc/3;
            Pnc=Pn/3;
            Qlc=Ql/3;
            Qcc=Qc/3;
        end


        if Pna==0
            Ra=0;
        else
            Ra=Vba*Vba/Pna;
        end
        if Pnb==0
            Rb=0;
        else
            Rb=Vbb*Vbb/Pnb;
        end
        if Pnc==0
            Rc=0;
        else
            Rc=Vbc*Vbc/Pnc;
        end


        if Qla==0
            La=0;
        else
            La=Vba*Vba/(2*pi*fn*Qla)*1e3;
        end
        if Qlb==0
            Lb=0;
        else
            Lb=Vbb*Vbb/(2*pi*fn*Qlb)*1e3;
        end
        if Qlc==0
            Lc=0;
        else
            Lc=Vbc*Vbc/(2*pi*fn*Qlc)*1e3;
        end


        Ca=Qca/(2*pi*fn*Vba*Vba)*1e6;
        Cb=Qcb/(2*pi*fn*Vbb*Vbb)*1e6;
        Cc=Qcc/(2*pi*fn*Vbc*Vbc)*1e6;

        switch Configuration
        case 'Y (grounded)'
            An=0;Bn=0;Cn=0;
            motA='g';motB='g';motC='g';
            Config='Yg';
        case 'Y (floating)'
            An=NewNode;Bn=NewNode;Cn=NewNode;
            NewNode=NewNode+1;
            motA='n';motB='n';motC='n';
            Config='Yn';
        case 'Y (neutral)'
            An=nodes(4);Bn=nodes(4);Cn=nodes(4);
            motA='n';motB='n';motC='n';
            Config='Yn';
        case 'Delta'
            An=nodes(2);Bn=nodes(3);Cn=nodes(1);
            switch get_param(block,'UnbalancedPower');
            case 'off'
                Ra=3*Ra;
                La=3*La;
                Ca=Ca/3;
                Rb=3*Rb;
                Lb=3*Lb;
                Cb=Cb/3;
                Rc=3*Rc;
                Lc=3*Lc;
                Cc=Cc/3;
            end
            motA='b';motB='c';motC='a';
            Config='D';
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
            nodes(1),An,1,Ra,La,Ca;
            nodes(2),Bn,1,Rb,Lb,Cb;
            nodes(3),Cn,1,Rc,Lc,Cc];
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
                sps.LoadFlow.rlcload.(Fields{k}){i+Nloads}=Values{k};
            end


            sps.LoadFlow.rlcload.S{i+Nloads}=0;
            sps.LoadFlow.rlcload.Vt{i+Nloads}=1;
            sps.LoadFlow.rlcload.I{i+Nloads}=0;
            sps.LoadFlow.rlcload.vnom{i+Nloads}=Vb;

            sps.LoadFlow.rlcload.busNumber{i+Nloads}=NaN;

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
            sps.UnbalancedLoadFlow.rlcload.vnom{i+Nloads}=[Vba,Vbb,Vbc];
            sps.UnbalancedLoadFlow.rlcload.busNumber{i+Nloads}=NaN;

        end
    end