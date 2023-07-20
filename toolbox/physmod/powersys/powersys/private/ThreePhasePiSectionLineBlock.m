function[sps,Multimeter,NewNode]=ThreePhasePiSectionLineBlock(nl,sps,Multimeter,NewNode)





    idx=nl.filter_type('Three-Phase PI Section Line');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        [f,R10,L10,C10,long]=getSPSmaskvalues(block,{'Frequency','Resistances','Inductances','Capacitances','Length'});
        blocinit(block,{f,R10,L10,C10,long});

        blmodlin(3,f,R10,L10,C10,BlockNom);
        w=2*pi*f;
        [z_ser1,y_sh1]=etazline(long,R10(1),L10(1)*w,C10(1)*w);
        [z_ser0,y_sh0]=etazline(long,R10(2),L10(2)*w,C10(2)*w);
        R1=real(z_ser1);
        L1=imag(z_ser1)/w;
        C1=imag(y_sh1)/w;
        R0=real(z_ser0);
        L0=imag(z_ser0)/w;
        C0=imag(y_sh0)/w;
        Rs=(2*R1+R0)/3;
        Ls=((2*L1+L0)/3)*1e3;
        Rm=(R0-R1)/3;
        Lm=((L0-L1)/3)*1e3;
        Cp=C1*1e6;
        Cn=(3*C1*C0/(C1-C0))*1e6;



        nodes=nl.block_nodes(block);
        BranchType=3;
        if Rm==0&&Lm==0
            BranchType=0;
        end

        sps.rlc(end+1,1:6)=[nodes(1),nodes(4),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['phase_A: ',BlockNom];

        sps.rlc(end+1,1:6)=[nodes(2),nodes(5),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['phase_B: ',BlockNom];

        sps.rlc(end+1,1:6)=[nodes(3),nodes(6),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['phase_C: ',BlockNom];

        if BranchType==3
            sps.rlc(end+1,1:6)=[NewNode,nodes(4),0,Rm,Lm,0];
            NewNode=NewNode+1;
            sps.rlcnames{end+1}=['mutual: ',BlockNom];
        end

        sps.rlc(end+1:end+4,1:6)=[...
        nodes(1),NewNode,0,0,0,Cp;...
        nodes(2),NewNode,0,0,0,Cp;...
        nodes(3),NewNode,0,0,0,Cp;...
        NewNode,0,0,0,0,Cn];
        NewNode=NewNode+1;
        sps.rlc(end+1:end+4,1:6)=[...
        nodes(4),NewNode,0,0,0,Cp;...
        nodes(5),NewNode,0,0,0,Cp;...
        nodes(6),NewNode,0,0,0,Cp;...
        NewNode,0,0,0,0,Cn];
        NewNode=NewNode+1;
        sps.rlcnames{end+1}=['Cp_in_A: ',BlockNom];
        sps.rlcnames{end+1}=['Cp_in_B: ',BlockNom];
        sps.rlcnames{end+1}=['Cp_in_C: ',BlockNom];
        sps.rlcnames{end+1}=['Cgnd_in: ',BlockNom];
        sps.rlcnames{end+1}=['Cp_out_A: ',BlockNom];
        sps.rlcnames{end+1}=['Cp_out_B: ',BlockNom];
        sps.rlcnames{end+1}=['Cp_out_C: ',BlockNom];
        sps.rlcnames{end+1}=['Cgnd_out: ',BlockNom];

        if isfield(sps,'LoadFlow')
            sps.LoadFlow.Lines.handle{end+1}=block;
            sps.LoadFlow.Lines.r{end+1}=R10(1);
            sps.LoadFlow.Lines.l{end+1}=L10(1);
            sps.LoadFlow.Lines.c{end+1}=C10(1);
            sps.LoadFlow.Lines.long{end+1}=long;
            sps.LoadFlow.Lines.freq{end+1}=f;
            sps.LoadFlow.Lines.leftnodes{end+1}=nodes(1:3);
            sps.LoadFlow.Lines.rightnodes{end+1}=nodes(4:6);
            sps.LoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.LoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.LoadFlow.Lines.isPI{end+1}=1;
        end

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Lines.r{end+1}=R10;
            sps.UnbalancedLoadFlow.Lines.l{end+1}=L10;
            sps.UnbalancedLoadFlow.Lines.c{end+1}=C10;
            sps.UnbalancedLoadFlow.Lines.long{end+1}=long;
            sps.UnbalancedLoadFlow.Lines.freq{end+1}=f;
            sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=nodes(1:3);
            sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=nodes(4:6);
            sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.isPI{end+1}=1;
            sps.UnbalancedLoadFlow.Lines.BlockType{end+1}='PI';

        end

    end