function[sps,YuNonlinear]=StepperMotorBlock(nl,sps,YuNonlinear)






    MaskType='Stepper Motor';
    idx=nl.filter_type(MaskType);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');

        SPSVerifyLinkStatus(block);

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,MaskType);


        nodes=nl.block_nodes(block);

        switch getSPSmaskvalues(block,{'MotorType'});

        case 'Permanent-magnet / Hybrid'

            NumberOfPhases=get_param(block,'NumberOfPhases_1');

            switch NumberOfPhases

            case '2'

                sps.source=[sps.source;
                nodes(1),nodes(2),1,0,0,0,NaN;
                nodes(3),nodes(4),1,0,0,0,NaN];

                sps.srcstr{end+1}=['I_A: ',BlockNom];
                sps.srcstr{end+1}=['I_B: ',BlockNom];

                sps.outstr{end+1}=['U_A: ',BlockNom];
                sps.outstr{end+1}=['U_B: ',BlockNom];

                sps.sourcenames(end+1:end+2,1)=[block;block];

                YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(3),nodes(4)];

                sps.NonlinearDevices.Demux(end+1)=2;
                sps.U.Mux(end+1)=2;


                ysrc=size(sps.source,1)-1;
                sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];


            case '4'






                sps.source=[sps.source;
                nodes(1),nodes(2),1,0,0,0,NaN;
                nodes(2),nodes(3),1,0,0,0,NaN;
                nodes(4),nodes(5),1,0,0,0,NaN;
                nodes(5),nodes(6),1,0,0,0,NaN];

                sps.srcstr{end+1}=['I_A+: ',BlockNom];
                sps.srcstr{end+1}=['I_A-: ',BlockNom];
                sps.srcstr{end+1}=['I_B+: ',BlockNom];
                sps.srcstr{end+1}=['I_B-: ',BlockNom];

                sps.outstr{end+1}=['U_A+: ',BlockNom];
                sps.outstr{end+1}=['U_A-: ',BlockNom];
                sps.outstr{end+1}=['U_B+: ',BlockNom];
                sps.outstr{end+1}=['U_B-: ',BlockNom];

                sps.sourcenames(end+1:end+4,1)=[block;block;block;block];


                YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3)];
                YuNonlinear(end+1:end+2,1:2)=[nodes(4),nodes(5);nodes(5),nodes(6)];

                sps.NonlinearDevices.Demux(end+1)=4;
                sps.U.Mux(end+1)=4;


                ysrc=size(sps.source,1)-3;
                sps.InputsNonZero(end+1:end+4)=[ysrc,ysrc+1,ysrc+2,ysrc+3];

            end

        case 'Variable reluctance'

            NumberOfPhases=get_param(block,'NumberOfPhases_2');

            switch NumberOfPhases

            case '3'

                sps.source=[sps.source;
                nodes(1),nodes(2),1,0,0,0,NaN;
                nodes(3),nodes(4),1,0,0,0,NaN;
                nodes(5),nodes(6),1,0,0,0,NaN];

                sps.srcstr{end+1}=['I_A: ',BlockNom];
                sps.srcstr{end+1}=['I_B: ',BlockNom];
                sps.srcstr{end+1}=['I_C: ',BlockNom];

                sps.outstr{end+1}=['U_A: ',BlockNom];
                sps.outstr{end+1}=['U_B: ',BlockNom];
                sps.outstr{end+1}=['U_C: ',BlockNom];

                sps.sourcenames(end+1:end+3,1)=[block;block;block];
                YuNonlinear(end+1:end+3,1:2)=[nodes(1),nodes(2);nodes(3),nodes(4);nodes(5),nodes(6)];

                sps.NonlinearDevices.Demux(end+1)=3;
                sps.U.Mux(end+1)=3;


                ysrc=size(sps.source,1)-2;
                sps.InputsNonZero(end+1:end+3)=[ysrc,ysrc+1,ysrc+2];

            case '4'

                sps.source=[sps.source;
                nodes(1),nodes(2),1,0,0,0,NaN;
                nodes(3),nodes(4),1,0,0,0,NaN;
                nodes(5),nodes(6),1,0,0,0,NaN;
                nodes(7),nodes(8),1,0,0,0,NaN];

                sps.srcstr{end+1}=['I_A: ',BlockNom];
                sps.srcstr{end+1}=['I_B: ',BlockNom];
                sps.srcstr{end+1}=['I_C: ',BlockNom];
                sps.srcstr{end+1}=['I_D: ',BlockNom];

                sps.outstr{end+1}=['U_A: ',BlockNom];
                sps.outstr{end+1}=['U_B: ',BlockNom];
                sps.outstr{end+1}=['U_C: ',BlockNom];
                sps.outstr{end+1}=['U_D: ',BlockNom];

                sps.sourcenames(end+1:end+4,1)=[block;block;block;block];
                YuNonlinear(end+1:end+4,1:2)=[nodes(1),nodes(2);nodes(3),nodes(4);nodes(5),nodes(6);nodes(7),nodes(8)];

                sps.NonlinearDevices.Demux(end+1)=4;
                sps.U.Mux(end+1)=4;


                ysrc=size(sps.source,1)-3;
                sps.InputsNonZero(end+1:end+4)=[ysrc,ysrc+1,ysrc+2,ysrc+3];

            case '5'

                sps.source=[sps.source;
                nodes(1),nodes(2),1,0,0,0,NaN;
                nodes(3),nodes(4),1,0,0,0,NaN;
                nodes(5),nodes(6),1,0,0,0,NaN;
                nodes(7),nodes(8),1,0,0,0,NaN;
                nodes(9),nodes(10),1,0,0,0,NaN];

                sps.srcstr{end+1}=['I_A: ',BlockNom];
                sps.srcstr{end+1}=['I_B: ',BlockNom];
                sps.srcstr{end+1}=['I_C: ',BlockNom];
                sps.srcstr{end+1}=['I_D: ',BlockNom];
                sps.srcstr{end+1}=['I_E: ',BlockNom];

                sps.outstr{end+1}=['U_A: ',BlockNom];
                sps.outstr{end+1}=['U_B: ',BlockNom];
                sps.outstr{end+1}=['U_C: ',BlockNom];
                sps.outstr{end+1}=['U_D: ',BlockNom];
                sps.outstr{end+1}=['U_E: ',BlockNom];

                sps.sourcenames(end+1:end+5,1)=[block;block;block;block;block];
                YuNonlinear(end+1:end+5,1:2)=[nodes(1),nodes(2);nodes(3),nodes(4);nodes(5),nodes(6);nodes(7),nodes(8);nodes(9),nodes(10)];

                sps.NonlinearDevices.Demux(end+1)=5;
                sps.U.Mux(end+1)=5;


                ysrc=size(sps.source,1)-4;
                sps.InputsNonZero(end+1:end+5)=[ysrc,ysrc+1,ysrc+2,ysrc+3,ysrc+4];
            end

        end
        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
    end