function[sps,Multimeter,NewNode]=ThreePhaseHarmonicFilterBlock(nl,sps,Multimeter,NewNode)






    idx=nl.filter_type('Three-Phase Harmonic Filter');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        Measurements=get_param(block,'Measurements');

        [FilterType,FilterConnection,ParNom,Qc,Fr,Frd,Q]=getSPSmaskvalues(block,{'FilterType','FilterConnection','ParNom','Qc','Fr','Frd','Q'});
        blocinit(block,{ParNom,Qc,Fr,Frd,Q});

        Vn=ParNom(1);
        Fn=ParNom(2);
        wn=2*pi*Fn;




        nodes=nl.block_nodes(block);

        switch FilterConnection
        case 1
            YA=0;
            YB=0;
            YC=0;
            motA='g';
            motB='g';
            motC='g';
        case 2
            YA=NewNode;
            YB=NewNode;
            YC=NewNode;
            motA='n';
            motB='n';
            motC='n';
            NewNode=NewNode+1;
        case 3
            YA=nodes(4);
            YB=nodes(4);
            YC=nodes(4);
            motA='n';
            motB='n';
            motC='n';
        case 4
            Qc=Qc/3;
            YA=nodes(2);
            YB=nodes(3);
            YC=nodes(1);
            motA='b';
            motB='c';
            motC='a';
        end
        switch FilterType
        case 1,
            wr1=2*pi*Fr;
            R1=0;
            L1=-Vn^2*wn/(Qc*(wn^2-wr1^2));
            C1=1/(wr1^2*L1);
            R2=wr1*L1/Q;
            L2=0;
            C2=0;
        case 2,
            wr1=2*pi*Frd(1);
            wr2=2*pi*Frd(2);
            La=-Vn^2*wn/(Qc/2*(wn^2-wr1^2));
            Ca=1/(wr1^2*La);

            Lb=-Vn^2*wn/(Qc/2*(wn^2-wr2^2));
            Cb=1/(wr2^2*Lb);

            R1=0;
            L1=La*Lb/(La+Lb);
            C1=Ca+Cb;
            R2=0;
            L2=(La*Ca-Lb*Cb)^2/(Ca+Cb)^2/(La+Lb);
            C2=Ca*Cb*(Ca+Cb)*(La+Lb)^2/(La*Ca-Lb*Cb)^2;
            R3=Q*sqrt(L2/C2);
            L3=0;
            C3=0;
        case 3,
            wr1=2*pi*Fr;
            R1=0;
            L1=0;
            R2=0;
            C2=0;
            L2=-Vn^2*wn/(Qc*(wn^2-wr1^2));
            C1=1/(wr1^2*L2);
            R3=wr1*L2*Q;
            L3=0;
            C3=0;
        case 4,
            wr1=2*pi*Fr;
            L1=0;
            L2=0;
            L3=-Vn^2*wn/(Qc*(wn^2-wr1^2));
            C1=Qc/(Vn^2*wn);
            C2=0;
            C3=1/L3/wn^2;
            R1=0;
            R2=wr1*L3*Q;
            R3=0;
        end
        XA=NewNode;
        XB=NewNode+1;
        XC=NewNode+2;
        NewNode=NewNode+3;

        sps.rlc(end+1,1:6)=[nodes(1),XA,0,R1,L1*1e3,C1*1e6];
        sps.rlc(end+1,1:6)=[nodes(2),XB,0,R1,L1*1e3,C1*1e6];
        sps.rlc(end+1,1:6)=[nodes(3),XC,0,R1,L1*1e3,C1*1e6];
        sps.rlcnames{end+1}=['phase_A1: ',BlockNom];
        sps.rlcnames{end+1}=['phase_B1: ',BlockNom];
        sps.rlcnames{end+1}=['phase_C1: ',BlockNom];
        BrancheC=size(sps.rlc,1);
        BrancheB=BrancheC-1;
        BrancheA=BrancheB-1;

        sps.rlc(end+1,1:6)=[XA,YA,1,R2,L2*1e3,C2*1e6];
        sps.rlc(end+1,1:6)=[XB,YB,1,R2,L2*1e3,C2*1e6];
        sps.rlc(end+1,1:6)=[XC,YC,1,R2,L2*1e3,C2*1e6];
        sps.rlcnames{end+1}=['phase_A2: ',BlockNom];
        sps.rlcnames{end+1}=['phase_B2: ',BlockNom];
        sps.rlcnames{end+1}=['phase_C2: ',BlockNom];

        if FilterType~=1
            sps.rlc(end+1,1:6)=[XA,YA,0,R3,L3*1e3,C3*1e6];
            sps.rlc(end+1,1:6)=[XB,YB,0,R3,L3*1e3,C3*1e6];
            sps.rlc(end+1,1:6)=[XC,YC,0,R3,L3*1e3,C3*1e6];
            sps.rlcnames{end+1}=['phase_A3: ',BlockNom];
            sps.rlcnames{end+1}=['phase_B3: ',BlockNom];
            sps.rlcnames{end+1}=['phase_C3: ',BlockNom];
        end

        if strcmp(Measurements,'Branch voltages')||strcmp(Measurements,'Branch voltages and currents')
            Multimeter.Yu(end+1,1:2)=[nodes(1),YA];
            Multimeter.V{end+1}=['Ua',motA,': ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(2),YB];
            Multimeter.V{end+1}=['Ub',motB,': ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(3),YC];
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