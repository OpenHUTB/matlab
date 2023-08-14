function[sps,Multimeter,NewNode]=ThreePhaseMutualInductanceBlock(nl,sps,Multimeter,NewNode)





    idx=nl.filter_type('Three-Phase Mutual Inductance Z1-Z0');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        [RL1,RL0]=getSPSmaskvalues(block,{'PositiveSequence','ZeroSequence'});
        blocinit(block,{RL1,RL0});
        Rs=(2*RL1(1)+RL0(1))/3;
        Ls=(2*RL1(2)+RL0(2))/3;
        Ls=Ls*1e3;
        Rm=(RL0(1)-RL1(1))/3;
        Lm=(RL0(2)-RL1(2))/3;
        Lm=Lm*1e3;
        BranchType=3;
        if Rm==0&&Lm==0
            BranchType=0;
        end



        nodes=nl.block_nodes(block);

        sps.rlc(end+1,1:6)=[nodes(1),nodes(4),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['winding_1: ',BlockNom];

        sps.rlc(end+1,1:6)=[nodes(2),nodes(5),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['winding_2: ',BlockNom];

        sps.rlc(end+1,1:6)=[nodes(3),nodes(6),BranchType,Rs,Ls,0];
        sps.rlcnames{end+1}=['winding_3: ',BlockNom];

        if BranchType==3
            sps.rlc(end+1,1:6)=[NewNode,nodes(4),0,Rm,Lm,0];
            NewNode=NewNode+1;
            sps.rlcnames{end+1}=['mut: ',BlockNom];
        end

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Lines.r{end+1}=[RL1(1),RL0(1)];
            sps.UnbalancedLoadFlow.Lines.l{end+1}=[RL1(2),RL0(2)];
            sps.UnbalancedLoadFlow.Lines.c{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.long{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.freq{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=nodes(1:3);
            sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=nodes(4:6);
            sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.isPI{end+1}=0;
            sps.UnbalancedLoadFlow.Lines.BlockType{end+1}='Z1Z0';

        end

    end