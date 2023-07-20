function[sps,YuNonlinear]=SinglePhaseAsynchronousMachineBlock(nl,sps,YuNonlinear)





    MaskType='Single Phase Asynchronous Machine';
    idx=nl.filter_type(MaskType);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,MaskType);
        [NominalParameters]=getSPSmaskvalues(block,{'NominalParameters'});

        IA0=0;
        phiA0=0;
        IB0=0;
        phiB0=0;
        freq=NominalParameters(3);


        nodes=nl.block_nodes(block);
        N1=nodes(1);
        N2=nodes(2);

        MachineType=get_param(block,'MachineType');
        switch MachineType
        case 'Main & auxiliary windings'
            N3=nodes(3);
            N4=nodes(4);
        otherwise
            N3=N1;
            N4=N2;
        end

        sps.source=[sps.source;
        N1,N2,1,IA0,phiA0,freq,NaN;
        N3,N4,1,IB0,phiB0,freq,NaN];
        YuNonlinear(end+1:end+2,1:2)=[N1,N2;N3,N4];

        sps.NonlinearDevices.Demux(end+1)=2;
        sps.U.Mux(end+1)=2;
        sps.srcstr{end+1}=['I_A: ',BlockNom];
        sps.srcstr{end+1}=['I_B: ',BlockNom];
        sps.outstr{end+1}=['U_A: ',BlockNom];
        sps.outstr{end+1}=['U_B: ',BlockNom];
        sps.sourcenames(end+1:end+2,1)=[block;block];


        ysrc=size(sps.source,1)-1;
        sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');

    end