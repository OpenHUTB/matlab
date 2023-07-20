function[BlockCount,sps,Multimeter,Yu,dcvf,NewNode]=ThreeLevelSwitchBridge(nl,block,sps,Multimeter,Yu,dcvf,NewNode)







    SPSVerifyLinkStatus(block);
    DeviceIndice=1;
    BlockName=getfullname(block);
    BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');

    NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Three-Level Bridge');




    [Rs,Cs,DeviceType,Ron,ForwardVoltages]=getSPSmaskvalues(block,{'SnubberResistance','SbubberCapacitance','Device','Ron','ForwardVoltages'});%#ok

    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

        Ron=0;
    end

    if sps.PowerguiInfo.SPID==0


        if Ron==-999
            Ron=0;
        end
    end

    if Ron==0&&sps.PowerguiInfo.SPID==0
        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
        Erreur.message=['The internal resistance (Ron) of the Three-Level Bridge named ''',block,''' is set to zero . You need to specify Ron > 0.'];
        psberror(Erreur);
    end














    nodes=nl.block_nodes(block);

    AA=nodes(1);
    BB=nodes(2);
    CC=nodes(3);
    POSI=nodes(4);
    NEUT=nodes(5);
    NEGA=nodes(6);

    arm1=strcmp(get_param(block,'Arms'),'1');
    arm2=strcmp(get_param(block,'Arms'),'2');
    arm3=strcmp(get_param(block,'Arms'),'3');





    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableSnubbers

    else
        if(Rs==inf||Cs==0)

        else
            Css=Cs;
            if Cs==inf
                Css=0;
            end

            sps.rlc=[sps.rlc;
            POSI,AA,0,Rs,0,Css*1e6;
            AA,NEGA,0,Rs,0,Css*1e6;
            AA,NEUT,0,Rs,0,Css*1e6];

            sps.rlcnames{end+1}=['snubber_1_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_2_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_3_arm_1: ',BlockNom];

            if arm2||arm3
                sps.rlc=[sps.rlc;
                POSI,BB,0,Rs,0,Css*1e6;
                BB,NEGA,0,Rs,0,Css*1e6;
                BB,NEUT,0,Rs,0,Css*1e6];
                sps.rlcnames{end+1}=['snubber_1_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_2_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_3_arm_2: ',BlockNom];
            end

            if arm3
                sps.rlc=[sps.rlc;
                POSI,CC,0,Rs,0,Css*1e6;
                CC,NEGA,0,Rs,0,Css*1e6;
                CC,NEUT,0,Rs,0,Css*1e6];
                sps.rlcnames{end+1}=['snubber_1_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_2_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_3_arm_3: ',BlockNom];
            end
        end
    end



    if sps.PowerguiInfo.SPID


        if Ron>0

            RonNode1=NewNode;
            RonNode2=NewNode+1;
            RonNode3=NewNode+2;
            NewNode=NewNode+3;

            sps.rlc(end+1,1:6)=[POSI,RonNode1,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 1: ',BlockNom];
            sps.rlc(end+1,1:6)=[NEUT,RonNode2,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 2: ',BlockNom];
            sps.rlc(end+1,1:6)=[AA,RonNode3,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 3: ',BlockNom];

        else

            RonNode1=POSI;
            RonNode2=NEUT;
            RonNode3=AA;

        end


        sps.rlc(end+1,1:6)=[RonNode1,AA,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 1: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode2,AA,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 2: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode3,NEGA,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 3: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);


        sps.switches=[sps.switches;
        RonNode1,AA,0,Ron,0;
        RonNode2,AA,0,Ron,0;
        RonNode3,NEGA,0,Ron,0;
        ];

        sps.SwitchNames{end+1}=['1: ',BlockNom];
        sps.SwitchNames{end+1}=['2: ',BlockNom];
        sps.SwitchNames{end+1}=['3: ',BlockNom];

    else



        sps.source=[sps.source;
        POSI,AA,1,0,0,0,DeviceIndice;
        NEUT,AA,1,0,0,0,DeviceIndice;
        AA,NEGA,1,0,0,0,DeviceIndice;
        ];

        sps.srcstr{end+1}=['I_arm1_1: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_2: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_3: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_1: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_2: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_3: ',BlockNom];
        Yu=[Yu;
        POSI,AA;
        NEUT,AA;
        AA,NEGA;
        ];
        sps.sourcenames(end+1:end+3,1)=ones(3,1)*block;


        sps.switches=[sps.switches;
        POSI,AA,0,Ron,0;
        NEUT,AA,0,Ron,0;
        AA,NEGA,0,Ron,0;
        ];

        sps.SwitchNames{end+1}=['1: ',BlockNom];
        sps.SwitchNames{end+1}=['2: ',BlockNom];
        sps.SwitchNames{end+1}=['3: ',BlockNom];

    end

    if arm2||arm3

        if sps.PowerguiInfo.SPID


            if Ron>0

                RonNode4=NewNode;
                RonNode5=NewNode+1;
                RonNode6=NewNode+2;
                NewNode=NewNode+3;

                sps.rlc(end+1,1:6)=[POSI,RonNode4,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 4: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUT,RonNode5,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 5: ',BlockNom];
                sps.rlc(end+1,1:6)=[BB,RonNode6,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 6: ',BlockNom];

            else

                RonNode4=POSI;
                RonNode5=NEUT;
                RonNode6=BB;

            end


            sps.rlc(end+1,1:6)=[RonNode4,BB,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 4: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode5,BB,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 5: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode6,NEGA,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 6: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);


            sps.switches=[sps.switches;
            RonNode4,BB,0,Ron,0;
            RonNode5,BB,0,Ron,0;
            RonNode6,NEGA,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['4: ',BlockNom];
            sps.SwitchNames{end+1}=['5: ',BlockNom];
            sps.SwitchNames{end+1}=['6: ',BlockNom];

        else



            sps.source=[sps.source;
            POSI,BB,1,0,0,0,DeviceIndice;
            NEUT,BB,1,0,0,0,DeviceIndice;
            BB,NEGA,1,0,0,0,DeviceIndice;
            ];

            sps.srcstr{end+1}=['I_arm2_1: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_2: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_3: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_1: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_2: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_3: ',BlockNom];
            Yu=[Yu;
            POSI,BB;
            NEUT,BB;
            BB,NEGA;
            ];
            sps.sourcenames(end+1:end+3,1)=ones(3,1)*block;


            sps.switches=[sps.switches;
            POSI,BB,0,Ron,0;
            NEUT,BB,0,Ron,0;
            BB,NEGA,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['4: ',BlockNom];
            sps.SwitchNames{end+1}=['5: ',BlockNom];
            sps.SwitchNames{end+1}=['6: ',BlockNom];

        end

    end

    if arm3

        if sps.PowerguiInfo.SPID


            if Ron>0

                RonNode7=NewNode;
                RonNode8=NewNode+1;
                RonNode9=NewNode+2;
                NewNode=NewNode+3;


                sps.rlc(end+1,1:6)=[POSI,RonNode7,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 7: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUT,RonNode8,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 8: ',BlockNom];
                sps.rlc(end+1,1:6)=[CC,RonNode9,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 9: ',BlockNom];

            else

                RonNode7=POSI;
                RonNode8=NEUT;
                RonNode9=CC;

            end


            sps.rlc(end+1,1:6)=[RonNode7,CC,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 7: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode8,CC,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 8: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode9,NEGA,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 9: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);


            sps.switches=[sps.switches;
            RonNode7,CC,0,Ron,0;
            RonNode8,CC,0,Ron,0;
            RonNode9,NEGA,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['7: ',BlockNom];
            sps.SwitchNames{end+1}=['8: ',BlockNom];
            sps.SwitchNames{end+1}=['9: ',BlockNom];

        else



            sps.source=[sps.source;
            POSI,CC,1,0,0,0,DeviceIndice;
            NEUT,CC,1,0,0,0,DeviceIndice;
            CC,NEGA,1,0,0,0,DeviceIndice;
            ];

            sps.srcstr{end+1}=['I_arm3_1: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_2: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_3: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_1: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_2: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_3: ',BlockNom];
            Yu=[Yu;
            POSI,CC;
            NEUT,CC;
            CC,NEGA;
            ];
            sps.sourcenames(end+1:end+3,1)=ones(3,1)*block;


            sps.switches=[sps.switches;
            POSI,CC,0,Ron,0;
            NEUT,CC,0,Ron,0;
            CC,NEGA,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['7: ',BlockNom];
            sps.SwitchNames{end+1}=['8: ',BlockNom];
            sps.SwitchNames{end+1}=['9: ',BlockNom];

        end

    end

    bras=(arm1*1+arm2*2+arm3*3);
    NumberOfSwitches=3*bras;
    BlockCount=NumberOfSwitches;

    sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;

    sps.SwitchVf(1,end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
    sps.SwitchVf(2,end-NumberOfSwitches+1:end)=zeros(1,NumberOfSwitches);


    sps.modelnames{DeviceIndice}(end+1)=block;
    sps.modelnames{DeviceIndice}(end+1)=block;
    sps.modelnames{DeviceIndice}(end+1)=block;
    if arm2||arm3
        sps.modelnames{DeviceIndice}(end+1)=block;
        sps.modelnames{DeviceIndice}(end+1)=block;
        sps.modelnames{DeviceIndice}(end+1)=block;
    end
    if arm3
        sps.modelnames{DeviceIndice}(end+1)=block;
        sps.modelnames{DeviceIndice}(end+1)=block;
        sps.modelnames{DeviceIndice}(end+1)=block;
    end


    sps.SwitchType(end+1:end+NumberOfSwitches)=1*ones(1,NumberOfSwitches);
    sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
    sps.Status.Demux(end+1)=NumberOfSwitches;
    sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
    sps.Gates.Mux(end+1)=NumberOfSwitches;

    sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
    sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
    sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;

    if sps.PowerguiInfo.SPID

        sps.Status.Demux(end)=2*NumberOfSwitches;
    else
        sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
    end


    if sps.PowerguiInfo.SPID
        y=size(sps.rlc,1);
        T=1;
    else
        y=size(sps.source,1);
        T=2;
    end


    mesurerequest=get_param(block,'Measurements');
    AllCurrents=strcmp(mesurerequest,'All device currents');
    AllVoltages=strcmp(mesurerequest,'Phase-to-Neutral and DC voltages');
    AllVoltCurr=strcmp(mesurerequest,'All voltages and currents');

    if AllCurrents||AllVoltCurr

        if arm1
            Coffset=2;
            sps.y3LevelCurrents(end+1)=3;
        elseif arm2
            Coffset=5;
            sps.y3LevelCurrents(end+1)=6;
        else
            Coffset=8;
            sps.y3LevelCurrents(end+1)=9;
        end
        sps.y3LevelDevice(end+1)=1;

        if arm1||arm2||arm3

            Multimeter.I{end+1}=['ISw1a: ',BlockNom];
            Multimeter.I{end+1}=['ISw2a: ',BlockNom];
            Multimeter.I{end+1}=['ISw3a: ',BlockNom];


            Multimeter.Yi{end+1,T}=y-Coffset;
            Multimeter.Yi{end+1,T}=y-Coffset+1;
            Multimeter.Yi{end+1,T}=y-Coffset+2;
        end
        if(arm2||arm3)
            Multimeter.I{end+1}=['ISw1b: ',BlockNom];
            Multimeter.I{end+1}=['ISw2b: ',BlockNom];
            Multimeter.I{end+1}=['ISw3b: ',BlockNom];


            Multimeter.Yi{end+1,T}=y-Coffset+3;
            Multimeter.Yi{end+1,T}=y-Coffset+4;
            Multimeter.Yi{end+1,T}=y-Coffset+5;
        end
        if arm3
            Multimeter.I{end+1}=['ISw1c: ',BlockNom];
            Multimeter.I{end+1}=['ISw2c: ',BlockNom];
            Multimeter.I{end+1}=['ISw3c: ',BlockNom];


            Multimeter.Yi{end+1,T}=y-Coffset+6;
            Multimeter.Yi{end+1,T}=y-Coffset+7;
            Multimeter.Yi{end+1,T}=y-Coffset+8;
        end
    end

    if AllVoltages||AllVoltCurr

        if arm1||arm2||arm3
            Multimeter.Yu(end+1,1:2)=[AA,NEUT];
            Multimeter.V{end+1}=['Uan: ',BlockNom];
        end
        if arm2||arm3
            Multimeter.Yu(end+1,1:2)=[BB,NEUT];
            Multimeter.V{end+1}=['Ubn: ',BlockNom];
        end
        if arm3
            Multimeter.Yu(end+1,1:2)=[CC,NEUT];
            Multimeter.V{end+1}=['Ucn: ',BlockNom];
        end

        Multimeter.Yu(end+1,1:2)=[POSI,NEUT];
        Multimeter.V{end+1}=['Udc+: ',BlockNom];
        Multimeter.Yu(end+1,1:2)=[NEGA,NEUT];
        Multimeter.V{end+1}=['Udc-: ',BlockNom];
    end