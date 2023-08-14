function[sps,YuNonlinear]=SwitchedReluctanceMotorBlock(nl,sps,YuNonlinear)






    MaskType='Switched Reluctance Motor';
    idx=nl.filter_type(MaskType);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,MaskType);


        nodes=nl.block_nodes(block);


        sps.source=[sps.source;
        nodes(1),nodes(2),1,0,0,0,NaN;
        nodes(3),nodes(4),1,0,0,0,NaN;
        nodes(5),nodes(6),1,0,0,0,NaN];

        sps.srcstr{end+1}=['I_A1A2: ',BlockNom];
        sps.srcstr{end+1}=['I_B1B2: ',BlockNom];
        sps.srcstr{end+1}=['I_C1C2: ',BlockNom];
        sps.outstr{end+1}=['U_A1A2: ',BlockNom];
        sps.outstr{end+1}=['U_B1B2: ',BlockNom];
        sps.outstr{end+1}=['U_C1C2: ',BlockNom];

        sps.sourcenames(end+1:end+3,1)=[block;block;block];
        YuNonlinear(end+1:end+3,1:2)=[nodes(1),nodes(2);nodes(3),nodes(4);nodes(5),nodes(6)];


        MachineType=get_param(block,'MachineType');
        switch MachineType

        case{'6/4','6/4  (60 kw preset model)'}


            sps.NonlinearDevices.Demux(end+1)=3;
            sps.U.Mux(end+1)=3;

        case{'8/6','8/6  (75 kw preset model)'}


            sps.source=[sps.source;
            nodes(7),nodes(8),1,0,0,0,NaN];

            sps.srcstr{end+1}=['I_D1D2: ',BlockNom];
            sps.outstr{end+1}=['U_D1D2: ',BlockNom];

            sps.sourcenames(end+1,1)=block;
            YuNonlinear(end+1,1:2)=[nodes(7),nodes(8)];
            sps.NonlinearDevices.Demux(end+1)=4;
            sps.U.Mux(end+1)=4;

        case{'10/8','10/8  (10 kw preset model)'}


            sps.source=[sps.source;
            nodes(7),nodes(8),1,0,0,0,NaN;
            nodes(9),nodes(10),1,0,0,0,NaN];

            sps.srcstr{end+1}=['I_D1D2: ',BlockNom];
            sps.srcstr{end+1}=['I_E1E2: ',BlockNom];
            sps.outstr{end+1}=['U_D1D2: ',BlockNom];
            sps.outstr{end+1}=['U_E1E2: ',BlockNom];

            sps.sourcenames(end+1:end+2,1)=[block;block];
            YuNonlinear(end+1:end+2,1:2)=[nodes(7),nodes(8);nodes(9),nodes(10)];
            sps.NonlinearDevices.Demux(end+1)=5;
            sps.U.Mux(end+1)=5;

        end


        ysrc=size(sps.source,1)-1;
        sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');

    end