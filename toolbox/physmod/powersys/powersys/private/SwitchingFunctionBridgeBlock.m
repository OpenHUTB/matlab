function[sps,YuNonlinear,Multimeter,YiSwitchingFunction,NewNode]=SwitchingFunctionBridgeBlock(nl,sps,YuNonlinear,Multimeter,NewNode)





    sps.BridgeSrcV=[];



    YiSwitchingFunction.nodes=zeros(0,7);
    YiSwitchingFunction.expression=[];
    YiSwitchingFunction.nb=0;
    YiSwitchingFunction.CurrentMeasurement.Tags={};
    YiSwitchingFunction.CurrentMeasurement.Demux=[];

    idx=nl.filter_type('Universal Bridge');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');

        switch get_param(block,'device');

        case{'Switching-function based VSC','Average-model based VSC'}

            YiSwitchingFunction.nb=YiSwitchingFunction.nb+1;

            SPSVerifyLinkStatus(block);
            BlockName=getfullname(block);


            mesurerequest=get_param(block,'Measurements_2');

            VOLTAGES=strcmp(mesurerequest,'Voltages');
            CURRENTS=strcmp(mesurerequest,'Currents');
            AllM=strcmp(mesurerequest,'Voltages and Currents');

            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Universal Bridge');

            BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');









            nodes=nl.block_nodes(block);


            YiSwitchingFunction.nodes(end+1,1:2)=[nodes(1),NewNode];
            YiSwitchingFunction.expression{end+1}=['Ia: ',BlockNom];


            if CURRENTS||AllM
                Multimeter.I{end+1}=['Ia: ',BlockNom];


                Multimeter.Yi{end+1,1}=NaN;
                Multimeter.Yi{end,2}=size(YiSwitchingFunction.nodes,1);
            end


            YiSwitchingFunction.CurrentMeasurement.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
            YiSwitchingFunction.CurrentMeasurement.Demux(end+1)=1;



            sps.sourcenames(end+1,1)=block;
            sps.U.Tags{end+1}=get_param([BlockName,'/VF'],'GotoTag');
            sps.U.Mux(end+1)=1;


            switch get_param(block,'arms')

            case '1'

                NumberOfSwitches=2;
                CtrlSwitches=1;


                sps.source(end+1,1:7)=[NewNode,nodes(5),0,0,0,0,24];
                sps.srcstr{end+1}=['Ua_',BlockNom];

                MMv=[nodes(1),nodes(5)];
                MMs=['Ua: ',BlockNom];

            case '2'

                NumberOfSwitches=4;
                CtrlSwitches=[1,3];


                sps.source(end+1,1:7)=[NewNode,nodes(2),0,0,0,0,24];
                sps.srcstr{end+1}=['Uab_',BlockNom];


                MMv=[nodes(1),nodes(2)];
                MMs=['Uab: ',BlockNom];

            case '3'

                NumberOfSwitches=6;
                CtrlSwitches=[1,3;3,5];


                sps.source(end+1,1:7)=[NewNode,nodes(2),0,0,0,0,24];
                sps.srcstr{end+1}=['Uab_',BlockNom];

                C11=size(sps.source,1);


                MMv=[nodes(1),nodes(2)];
                MMs=['Uab: ',BlockNom];


                YiSwitchingFunction.nodes(end+1,1:2)=[nodes(3),NewNode+1];
                YiSwitchingFunction.expression{end+1}=['Ic: ',BlockNom];


                if CURRENTS||AllM




                    ii=size(YiSwitchingFunction.nodes,1);

                    Multimeter.I{end+1}=['Ib: ',BlockNom];
                    Multimeter.Yi{end+1,1}=NaN;
                    Multimeter.Yi{end,2}=-ii;

                    Multimeter.I{end+1}=['Ic: ',BlockNom];
                    Multimeter.Yi{end+1,1}=NaN;
                    Multimeter.Yi{end,2}=ii;

                end


                sps.source(end+1,1:7)=[nodes(2),NewNode+1,0,0,0,0,24];
                sps.srcstr{end+1}=['Ubc_',BlockNom];

                C12=size(sps.source,1);

                sps.sourcenames(end+1,1)=block;


                YiSwitchingFunction.CurrentMeasurement.Demux(end)=2;



                sps.U.Mux(end)=2;

            end


            if VOLTAGES||AllM
                Multimeter.Yu(end+1,1:2)=MMv;
                Multimeter.V{end+1}=MMs;
            end



            switch get_param(block,'arms')
            case '3'

                if VOLTAGES||AllM
                    Multimeter.Yu(end+1,1:2)=[nodes(2),nodes(3)];
                    Multimeter.V{end+1}=['Ubc: ',BlockNom];
                    Multimeter.Yu(end+1,1:2)=[nodes(3),nodes(1)];
                    Multimeter.V{end+1}=['Uca: ',BlockNom];
                end

            end

            NewNode=NewNode+2;







            sps.source(end+1,1:7)=[nodes(5),nodes(4),1,0,0,0,25];
            sps.srcstr{end+1}=['Idc_',BlockNom];
            sps.sourcenames(end+1,1)=block;
            sps.U.Tags{end+1}=get_param([BlockName,'/ISWITCH'],'GotoTag');
            sps.U.Mux(end+1)=1;


            YuNonlinear(end+1,1:2)=[nodes(4),nodes(5)];%#ok
            sps.outstr{end+1}=['Udc_',BlockNom];
            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;

            C212=size(sps.outstr,2);


            if CURRENTS||AllM
                Multimeter.I{end+1}=['Idc: ',BlockNom];
                Multimeter.Yi{end+1,2}=-size(sps.source,1);
            end
            if VOLTAGES||AllM
                Multimeter.Yu(end+1,1:2)=[nodes(4),nodes(5)];
                Multimeter.V{end+1}=['Udc: ',BlockNom];
            end


            switch get_param(block,'arms')

            case 1

                sps.BridgeSrcV(end+1,1:4)=[C11,C212,CtrlSwitches(1,1:2)+length(sps.SwitchType)];

            case 2

                sps.BridgeSrcV(end+1,1:4)=[C11,C212,CtrlSwitches(1,1:2)+length(sps.SwitchType)];

            case '3'

                sps.BridgeSrcV(end+1,1:4)=[C11,C212,(CtrlSwitches(1,1:2))+length(sps.SwitchType)];
                sps.BridgeSrcV(end+1,1:4)=[C12,C212,(CtrlSwitches(2,1:2))+length(sps.SwitchType)];

            end

            if sps.PowerguiInfo.Discrete&&sps.PowerguiInfo.Interpolate
                sps.SwitchType(end+1:end+NumberOfSwitches)=8*ones(1,NumberOfSwitches);
                sps.Rswitch(end+1:end+NumberOfSwitches,1)=zeros(1,NumberOfSwitches);
                sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
                sps.Gates.Tags{end+1}='Gates_SwFun';
                sps.Gates.Mux(end+1)=NumberOfSwitches;

                sps.Status.Tags{end+1}='';
                sps.Status.Demux(end+1)=NumberOfSwitches;
            end


        end
    end