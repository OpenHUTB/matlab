function[BlockCount,sps,Multimeter,Yu,dcvf,NewNode]=ThreeLevelBridge(nl,block,sps,Multimeter,Yu,dcvf,NewNode)






    SPSVerifyLinkStatus(block);


    BlockName=getfullname(block);
    BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');


    NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Three-Level Bridge');



    [Rs,Cs,DeviceType,Ron,ForwardVoltages]=getSPSmaskvalues(block,{'SnubberResistance','SbubberCapacitance','Device','Ron','ForwardVoltages'});

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
        Erreur.message=['The Ron parameter of ''',BlockNom,''' block cannot be set to zero.',newline,'You can set Ron = 0 only when the ''Continuous'' Simulation type in the Solver tab of the Powergui is selected and the ''Disable ideal switching'' option in the Preferences tab of powergui is not selected.'];
        psberror(Erreur);
    end

    Vfdevice=ForwardVoltages(1);
    Vfdiode=ForwardVoltages(2);

    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableVf

        Vfdevice=0;
        Vfdiode=0;
    end

    if DeviceType==2

        Vfdevice=0;
        Vfdiode=0;
    end


















    nodes=nl.block_nodes(block);
    AA=nodes(1);
    BB=nodes(2);
    CC=nodes(3);
    POSI=nodes(4);
    NEUT=nodes(5);
    NEGA=nodes(6);


    AAPLUS=NewNode;
    BBPLUS=NewNode+1;
    CCPLUS=NewNode+2;
    AAMOIN=NewNode+3;
    BBMOIN=NewNode+4;
    CCMOIN=NewNode+5;
    NewNode=NewNode+6;

    arm1=strcmp(get_param(block,'Arms'),'1');
    arm2=strcmp(get_param(block,'Arms'),'2');
    arm3=strcmp(get_param(block,'Arms'),'3');




    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableSnubbers

    else
        if(Rs==0&&Cs==Inf)
            Erreur.message=['In the mask of ''',BlockNom,''' block:',newline,'Snubber parameters are not set correctly (short-circuit). Specify  Rs=Inf or Cs=0 to disconnect the snubber. You can avoid the use of snubber by selecting the ''Continuous'' Simulation type in the Solver tab of the Powergui and deselecting the ''Disable ideal switching'' option in the Preferences tab of Powergui block.'];
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if(Rs==inf||Cs==0)

        else
            Css=Cs;
            if Cs==inf
                Css=0;
            end

            sps.rlc=[sps.rlc;
            POSI,AAPLUS,0,Rs,0,Css*1e6;
            AAPLUS,AA,0,Rs,0,Css*1e6;
            AA,AAMOIN,0,Rs,0,Css*1e6;
            AAMOIN,NEGA,0,Rs,0,Css*1e6;
            NEUT,AAPLUS,0,Rs,0,Css*1e6;
            AAMOIN,NEUT,0,Rs,0,Css*1e6;
            ];

            sps.rlcnames{end+1}=['snubber_1_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_2_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_3_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_4_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_5_arm_1: ',BlockNom];
            sps.rlcnames{end+1}=['snubber_6_arm_1: ',BlockNom];

            if arm2||arm3
                sps.rlc=[sps.rlc;
                POSI,BBPLUS,0,Rs,0,Css*1e6;
                BBPLUS,BB,0,Rs,0,Css*1e6;
                BB,BBMOIN,0,Rs,0,Css*1e6;
                BBMOIN,NEGA,0,Rs,0,Css*1e6;
                NEUT,BBPLUS,0,Rs,0,Css*1e6;
                BBMOIN,NEUT,0,Rs,0,Css*1e6;
                ];

                sps.rlcnames{end+1}=['snubber_1_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_2_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_3_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_4_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_5_arm_2: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_6_arm_2: ',BlockNom];
            end

            if arm3
                sps.rlc=[sps.rlc;
                POSI,CCPLUS,0,Rs,0,Css*1e6;
                CCPLUS,CC,0,Rs,0,Css*1e6;
                CC,CCMOIN,0,Rs,0,Css*1e6;
                CCMOIN,NEGA,0,Rs,0,Css*1e6;
                NEUT,CCPLUS,0,Rs,0,Css*1e6;
                CCMOIN,NEUT,0,Rs,0,Css*1e6;
                ];

                sps.rlcnames{end+1}=['snubber_1_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_2_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_3_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_4_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_5_arm_3: ',BlockNom];
                sps.rlcnames{end+1}=['snubber_6_arm_3: ',BlockNom];
            end
        end
    end





    bras=(arm1*1+arm2*2+arm3*3);
    NumberOfSwitches=4*bras+2*bras;
    BlockCount=NumberOfSwitches;

    if Vfdevice||Vfdiode


        AAPLUSVF=NewNode;
        BBPLUSVF=NewNode+1;
        CCPLUSVF=NewNode+2;
        AAVF=NewNode+3;
        BBVF=NewNode+4;
        CCVF=NewNode+5;
        AAMOINVF=NewNode+6;
        BBMOINVF=NewNode+7;
        CCMOINVF=NewNode+8;
        NEGAAVF=NewNode+9;
        NEGABVF=NewNode+10;
        NEGACVF=NewNode+11;
        NEUTAAPLUSVF=NewNode+12;
        NEUTAAMOINVF=NewNode+13;
        NEUTBBPLUSVF=NewNode+14;
        NEUTBBMOINVF=NewNode+15;
        NEUTCCPLUSVF=NewNode+16;
        NEUTCCMOINVF=NewNode+17;
        NewNode=NewNode+18;

        dcvf.source=[dcvf.source;
        AAPLUSVF,AAPLUS,0,Vfdevice,0,0,21;
        AAVF,AA,0,Vfdevice,0,0,21;
        AAMOINVF,AAMOIN,0,Vfdevice,0,0,21;
        NEGAAVF,NEGA,0,Vfdevice,0,0,21;
        NEUT,NEUTAAPLUSVF,0,Vfdevice,0,0,21;
        AAMOIN,NEUTAAMOINVF,0,Vfdevice,0,0,21;
        ];

        dcvf.srcstr{end+1}=['U_Vf_1: ',BlockNom];
        dcvf.srcstr{end+1}=['U_Vf_2: ',BlockNom];
        dcvf.srcstr{end+1}=['U_Vf_3: ',BlockNom];
        dcvf.srcstr{end+1}=['U_Vf_4: ',BlockNom];
        dcvf.srcstr{end+1}=['U_Vf_5: ',BlockNom];
        dcvf.srcstr{end+1}=['U_Vf_6: ',BlockNom];
        dcvf.sourcenames(end+1:end+6,1)=ones(6,1)*block;

        if arm2||arm3

            dcvf.source=[dcvf.source;
            BBPLUSVF,BBPLUS,0,Vfdevice,0,0,21;
            BBVF,BB,0,Vfdevice,0,0,21;
            BBMOINVF,BBMOIN,0,Vfdevice,0,0,21;
            NEGABVF,NEGA,0,Vfdevice,0,0,21;
            NEUT,NEUTBBPLUSVF,0,Vfdevice,0,0,21;
            BBMOIN,NEUTBBMOINVF,0,Vfdevice,0,0,21;
            ];

            dcvf.srcstr{end+1}=['U_Vf_7: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_8: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_9: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_10: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_11: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_12: ',BlockNom];
            dcvf.sourcenames(end+1:end+6,1)=ones(6,1)*block;

        end

        if arm3

            dcvf.source=[dcvf.source;
            CCPLUSVF,CCPLUS,0,Vfdevice,0,0,21;
            CCVF,CC,0,Vfdevice,0,0,21;
            CCMOINVF,CCMOIN,0,Vfdevice,0,0,21;
            NEGACVF,NEGA,0,Vfdevice,0,0,21;
            NEUT,NEUTCCPLUSVF,0,Vfdevice,0,0,21;
            CCMOIN,NEUTCCMOINVF,0,Vfdevice,0,0,21;
            ];

            dcvf.srcstr{end+1}=['U_Vf_13: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_14: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_15: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_16: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_17: ',BlockNom];
            dcvf.srcstr{end+1}=['U_Vf_18: ',BlockNom];
            dcvf.sourcenames(end+1:end+6,1)=ones(6,1)*block;

        end


        sps.VF.Tags{end+1}=get_param([BlockName,'/VF'],'GotoTag');
        sps.VF.Mux(end+1)=NumberOfSwitches;

    else
        AAPLUSVF=AAPLUS;
        BBPLUSVF=BBPLUS;
        CCPLUSVF=CCPLUS;
        AAVF=AA;
        BBVF=BB;
        CCVF=CC;
        AAMOINVF=AAMOIN;
        BBMOINVF=BBMOIN;
        CCMOINVF=CCMOIN;
        NEGAAVF=NEGA;
        NEGABVF=NEGA;
        NEGACVF=NEGA;
        NEUTAAPLUSVF=NEUT;
        NEUTAAMOINVF=AAMOIN;
        NEUTBBPLUSVF=NEUT;
        NEUTBBMOINVF=BBMOIN;
        NEUTCCPLUSVF=NEUT;
        NEUTCCMOINVF=CCMOIN;
    end


    DeviceIndice=6;

    if sps.PowerguiInfo.SPID


        if Ron>0

            RonNode1=NewNode;
            RonNode2=NewNode+1;
            RonNode3=NewNode+2;
            RonNode4=NewNode+3;
            RonNode5=NewNode+4;
            RonNode6=NewNode+5;
            NewNode=NewNode+6;

            sps.rlc(end+1,1:6)=[POSI,RonNode1,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 1: ',BlockNom];
            sps.rlc(end+1,1:6)=[AAPLUS,RonNode2,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 2: ',BlockNom];
            sps.rlc(end+1,1:6)=[AA,RonNode3,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 3: ',BlockNom];
            sps.rlc(end+1,1:6)=[AAMOIN,RonNode4,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 4: ',BlockNom];
            sps.rlc(end+1,1:6)=[NEUTAAPLUSVF,RonNode5,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 5: ',BlockNom];
            sps.rlc(end+1,1:6)=[NEUTAAMOINVF,RonNode6,0,Ron,0,0];
            sps.rlcnames{end+1}=['Ron switch 6: ',BlockNom];

        else

            RonNode1=POSI;
            RonNode2=AAPLUS;
            RonNode3=AA;
            RonNode4=AAMOIN;
            RonNode5=NEUTAAPLUSVF;
            RonNode6=NEUTAAMOINVF;

        end


        sps.rlc(end+1,1:6)=[RonNode1,AAPLUSVF,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 1: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode2,AAVF,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 2: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode3,AAMOINVF,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 3: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode4,NEGAAVF,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 4: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode5,AAPLUS,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 5: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);
        sps.rlc(end+1,1:6)=[RonNode6,NEUT,0,1,0,0];
        sps.rlcnames{end+1}=['SPID 6: ',BlockNom];
        sps.SPIDresistors(end+1)=size(sps.rlc,1);

        T=1;
        REFMAT=size(sps.rlc,1);

        sps.switches=[sps.switches;
        RonNode1,AAPLUSVF,0,Ron,0;
        RonNode2,AAVF,0,Ron,0;
        RonNode3,AAMOINVF,0,Ron,0;
        RonNode4,NEGAAVF,0,Ron,0;
        RonNode5,AAPLUS,0,Ron,0;
        RonNode6,NEUT,0,Ron,0;
        ];

        sps.SwitchNames{end+1}=['1: ',BlockNom];
        sps.SwitchNames{end+1}=['2: ',BlockNom];
        sps.SwitchNames{end+1}=['3: ',BlockNom];
        sps.SwitchNames{end+1}=['4: ',BlockNom];
        sps.SwitchNames{end+1}=['5: ',BlockNom];
        sps.SwitchNames{end+1}=['6: ',BlockNom];

    else


        sps.source=[sps.source;
        POSI,AAPLUSVF,1,0,0,0,DeviceIndice;
        AAPLUS,AAVF,1,0,0,0,DeviceIndice;
        AA,AAMOINVF,1,0,0,0,DeviceIndice;
        AAMOIN,NEGAAVF,1,0,0,0,DeviceIndice;
        NEUTAAPLUSVF,AAPLUS,1,0,0,0,DeviceIndice;
        NEUTAAMOINVF,NEUT,1,0,0,0,DeviceIndice;
        ];

        T=2;
        REFMAT=size(sps.source,1);


        sps.srcstr{end+1}=['I_arm1_1: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_2: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_3: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_4: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_5: ',BlockNom];
        sps.srcstr{end+1}=['I_arm1_6: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_1: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_2: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_3: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_4: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_5: ',BlockNom];
        sps.outstr{end+1}=['U_arm1_6: ',BlockNom];

        Yu=[Yu;
        POSI,AAPLUSVF;
        AAPLUS,AAVF;
        AA,AAMOINVF;
        AAMOIN,NEGAAVF;
        NEUTAAPLUSVF,AAPLUS;
        NEUTAAMOINVF,NEUT;
        ];

        sps.sourcenames(end+1:end+6,1)=ones(6,1)*block;

        sps.switches=[sps.switches;
        POSI,AAPLUSVF,0,Ron,0;
        AAPLUS,AAVF,0,Ron,0;
        AA,AAMOINVF,0,Ron,0;
        AAMOIN,NEGAAVF,0,Ron,0;
        NEUTAAPLUSVF,AAPLUS,0,Ron,0;
        NEUTAAMOINVF,NEUT,0,Ron,0;
        ];

        sps.SwitchNames{end+1}=['1: ',BlockNom];
        sps.SwitchNames{end+1}=['2: ',BlockNom];
        sps.SwitchNames{end+1}=['3: ',BlockNom];
        sps.SwitchNames{end+1}=['4: ',BlockNom];
        sps.SwitchNames{end+1}=['5: ',BlockNom];
        sps.SwitchNames{end+1}=['6: ',BlockNom];

    end


    sps.SwitchType(end+1:end+6)=[7,7,7,7,3,3];




    mesurerequest=get_param(block,'Measurements');

    AllCurrents=strcmp(mesurerequest,'All device currents');
    AllVoltages=strcmp(mesurerequest,'Phase-to-Neutral and DC voltages');
    AllVoltCurr=strcmp(mesurerequest,'All voltages and currents');

    if AllCurrents||AllVoltCurr


        y=REFMAT;
        LengthI=length(Multimeter.I);
        for s=1:4
            Multimeter.I{end+1}=['IQ',num2str(s),'a: ',BlockNom];
            Multimeter.Yi{end+1,T}=y-6+s;
            Multimeter.Q1Q4(end+1)=LengthI+s;
        end
        for s=1:4
            Multimeter.I{end+1}=['ID',num2str(s),'a: ',BlockNom];
            Multimeter.Yi{end+1,T}=y-6+s;
            Multimeter.D1D4(end+1)=LengthI+4+s;
        end
        for s=5:6
            Multimeter.I{end+1}=['ID',num2str(s),'a: ',BlockNom];
            Multimeter.Yi{end+1,T}=y-6+s;
            Multimeter.D5D6(end+1)=LengthI+4+s;
        end
    end

    if AllVoltages||AllVoltCurr
        Multimeter.Yu(end+1,1:2)=[AA,NEUT];
        Multimeter.V{end+1}=['Uan: ',BlockNom];
        Multimeter.Yu(end+1,1:2)=[POSI,NEUT];
        Multimeter.V{end+1}=['Udc+: ',BlockNom];
        Multimeter.Yu(end+1,1:2)=[NEGA,NEUT];
        Multimeter.V{end+1}=['Udc-: ',BlockNom];
    end



    if arm2||arm3

        if sps.PowerguiInfo.SPID


            if Ron>0

                RonNode7=NewNode;
                RonNode8=NewNode+1;
                RonNode9=NewNode+2;
                RonNode10=NewNode+3;
                RonNode11=NewNode+4;
                RonNode12=NewNode+5;
                NewNode=NewNode+6;

                sps.rlc(end+1,1:6)=[POSI,RonNode7,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 7: ',BlockNom];
                sps.rlc(end+1,1:6)=[BBPLUS,RonNode8,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 8: ',BlockNom];
                sps.rlc(end+1,1:6)=[BB,RonNode9,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 9: ',BlockNom];
                sps.rlc(end+1,1:6)=[BBMOIN,RonNode10,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 10: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUTBBPLUSVF,RonNode11,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 11: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUTBBMOINVF,RonNode12,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 12: ',BlockNom];

            else

                RonNode7=POSI;
                RonNode8=BBPLUS;
                RonNode9=BB;
                RonNode10=BBMOIN;
                RonNode11=NEUTBBPLUSVF;
                RonNode12=NEUTBBMOINVF;

            end


            sps.rlc(end+1,1:6)=[RonNode7,BBPLUSVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 7: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode8,BBVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 8: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode9,BBMOINVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 9: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode10,NEGABVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 10: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode11,BBPLUS,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 11: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode12,NEUT,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 12: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);

            T=1;
            REFMAT=size(sps.rlc,1);


            sps.switches=[sps.switches;
            RonNode7,BBPLUSVF,0,Ron,0;
            RonNode8,BBVF,0,Ron,0;
            RonNode9,BBMOINVF,0,Ron,0;
            RonNode10,NEGABVF,0,Ron,0;
            RonNode11,BBPLUS,0,Ron,0;
            RonNode12,NEUT,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['7: ',BlockNom];
            sps.SwitchNames{end+1}=['8: ',BlockNom];
            sps.SwitchNames{end+1}=['9: ',BlockNom];
            sps.SwitchNames{end+1}=['10: ',BlockNom];
            sps.SwitchNames{end+1}=['11: ',BlockNom];
            sps.SwitchNames{end+1}=['12: ',BlockNom];

        else


            sps.source=[sps.source;
            POSI,BBPLUSVF,1,0,0,0,DeviceIndice;
            BBPLUS,BBVF,1,0,0,0,DeviceIndice;
            BB,BBMOINVF,1,0,0,0,DeviceIndice;
            BBMOIN,NEGABVF,1,0,0,0,DeviceIndice;
            NEUTBBPLUSVF,BBPLUS,1,0,0,0,DeviceIndice;
            NEUTBBMOINVF,NEUT,1,0,0,0,DeviceIndice;
            ];

            T=2;
            REFMAT=size(sps.source,1);


            sps.srcstr{end+1}=['I_arm2_1: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_2: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_3: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_4: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_5: ',BlockNom];
            sps.srcstr{end+1}=['I_arm2_6: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_1: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_2: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_3: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_4: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_5: ',BlockNom];
            sps.outstr{end+1}=['U_arm2_6: ',BlockNom];

            Yu=[Yu;
            POSI,BBPLUSVF;
            BBPLUS,BBVF;
            BB,BBMOINVF;
            BBMOIN,NEGABVF;
            NEUTBBPLUSVF,BBPLUS;
            NEUTBBMOINVF,NEUT;
            ];
            sps.sourcenames(end+1:end+6,1)=ones(6,1)*block;


            sps.switches=[sps.switches;
            POSI,BBPLUSVF,0,Ron,0;
            BBPLUS,BBVF,0,Ron,0;
            BB,BBMOINVF,0,Ron,0;
            BBMOIN,NEGABVF,0,Ron,0;
            NEUTBBPLUSVF,BBPLUS,0,Ron,0;
            NEUTBBMOINVF,NEUT,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['7: ',BlockNom];
            sps.SwitchNames{end+1}=['8: ',BlockNom];
            sps.SwitchNames{end+1}=['9: ',BlockNom];
            sps.SwitchNames{end+1}=['10: ',BlockNom];
            sps.SwitchNames{end+1}=['11: ',BlockNom];
            sps.SwitchNames{end+1}=['12: ',BlockNom];

        end


        sps.SwitchType(end+1:end+6)=[7,7,7,7,3,3];

        if AllCurrents||AllVoltCurr
            y=REFMAT;
            LengthI=length(Multimeter.I);
            for s=1:4
                Multimeter.I{end+1}=['IQ',num2str(s),'b: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.Q1Q4(end+1)=LengthI+s;
            end
            for s=1:4
                Multimeter.I{end+1}=['ID',num2str(s),'b: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.D1D4(end+1)=LengthI+4+s;
            end
            for s=5:6
                Multimeter.I{end+1}=['ID',num2str(s),'b: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.D5D6(end+1)=LengthI+4+s;
            end
        end

        if AllVoltages||AllVoltCurr
            Multimeter.Yu(end+1,1:2)=[BB,NEUT];
            Multimeter.V{end+1}=['Ubn: ',BlockNom];
        end

    end

    if arm3

        if sps.PowerguiInfo.SPID


            if Ron>0

                RonNode13=NewNode;
                RonNode14=NewNode+1;
                RonNode15=NewNode+2;
                RonNode16=NewNode+3;
                RonNode17=NewNode+4;
                RonNode18=NewNode+5;
                NewNode=NewNode+6;

                sps.rlc(end+1,1:6)=[POSI,RonNode13,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 13: ',BlockNom];
                sps.rlc(end+1,1:6)=[CCPLUS,RonNode14,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 14: ',BlockNom];
                sps.rlc(end+1,1:6)=[CC,RonNode15,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 15: ',BlockNom];
                sps.rlc(end+1,1:6)=[CCMOIN,RonNode16,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 16: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUTCCPLUSVF,RonNode17,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 17: ',BlockNom];
                sps.rlc(end+1,1:6)=[NEUTCCMOINVF,RonNode18,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch 18: ',BlockNom];

            else

                RonNode13=POSI;
                RonNode14=CCPLUS;
                RonNode15=CC;
                RonNode16=CCMOIN;
                RonNode17=NEUTCCPLUSVF;
                RonNode18=NEUTCCMOINVF;

            end


            sps.rlc(end+1,1:6)=[RonNode13,CCPLUSVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 13: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode14,CCVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 14: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode15,CCMOINVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 15: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode16,NEGACVF,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 16: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode17,CCPLUS,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 17: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);
            sps.rlc(end+1,1:6)=[RonNode18,NEUT,0,1,0,0];
            sps.rlcnames{end+1}=['SPID 18: ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);

            T=1;
            REFMAT=size(sps.rlc,1);


            sps.switches=[sps.switches;
            RonNode13,CCPLUSVF,0,Ron,0;
            RonNode14,CCVF,0,Ron,0;
            RonNode15,CCMOINVF,0,Ron,0;
            RonNode16,NEGACVF,0,Ron,0;
            RonNode17,CCPLUS,0,Ron,0;
            RonNode18,NEUT,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['13: ',BlockNom];
            sps.SwitchNames{end+1}=['14: ',BlockNom];
            sps.SwitchNames{end+1}=['15: ',BlockNom];
            sps.SwitchNames{end+1}=['16: ',BlockNom];
            sps.SwitchNames{end+1}=['17: ',BlockNom];
            sps.SwitchNames{end+1}=['18: ',BlockNom];

        else


            sps.source=[sps.source;
            POSI,CCPLUSVF,1,0,0,0,DeviceIndice;
            CCPLUS,CCVF,1,0,0,0,DeviceIndice;
            CC,CCMOINVF,1,0,0,0,DeviceIndice;
            CCMOIN,NEGACVF,1,0,0,0,DeviceIndice;
            NEUTCCPLUSVF,CCPLUS,1,0,0,0,DeviceIndice;
            NEUTCCMOINVF,NEUT,1,0,0,0,DeviceIndice;
            ];

            T=2;
            REFMAT=size(sps.source,1);


            sps.srcstr{end+1}=['I_arm3_1: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_2: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_3: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_4: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_5: ',BlockNom];
            sps.srcstr{end+1}=['I_arm3_6: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_1: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_2: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_3: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_4: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_5: ',BlockNom];
            sps.outstr{end+1}=['U_arm3_6: ',BlockNom];

            Yu=[Yu;
            POSI,CCPLUSVF;
            CCPLUS,CCVF;
            CC,CCMOINVF;
            CCMOIN,NEGACVF;
            NEUTCCPLUSVF,CCPLUS;
            NEUTCCMOINVF,NEUT;
            ];
            sps.sourcenames(end+1:end+6,1)=ones(6,1)*block;


            sps.switches=[sps.switches;
            POSI,CCPLUSVF,0,Ron,0;
            CCPLUS,CCVF,0,Ron,0;
            CC,CCMOINVF,0,Ron,0;
            CCMOIN,NEGACVF,0,Ron,0;
            NEUTCCPLUSVF,CCPLUS,0,Ron,0;
            NEUTCCMOINVF,NEUT,0,Ron,0;
            ];

            sps.SwitchNames{end+1}=['13: ',BlockNom];
            sps.SwitchNames{end+1}=['14: ',BlockNom];
            sps.SwitchNames{end+1}=['15: ',BlockNom];
            sps.SwitchNames{end+1}=['16: ',BlockNom];
            sps.SwitchNames{end+1}=['17: ',BlockNom];
            sps.SwitchNames{end+1}=['18: ',BlockNom];

        end


        sps.SwitchType(end+1:end+6)=[7,7,7,7,3,3];

        if AllCurrents||AllVoltCurr
            y=REFMAT;
            LengthI=length(Multimeter.I);
            for s=1:4
                Multimeter.I{end+1}=['IQ',num2str(s),'c: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.Q1Q4(end+1)=LengthI+s;
            end
            for s=1:4
                Multimeter.I{end+1}=['ID',num2str(s),'c: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.D1D4(end+1)=LengthI+4+s;
            end
            for s=5:6
                Multimeter.I{end+1}=['ID',num2str(s),'c: ',BlockNom];
                Multimeter.Yi{end+1,T}=y-6+s;
                Multimeter.D5D6(end+1)=LengthI+4+s;
            end
        end

        if AllVoltages||AllVoltCurr
            Multimeter.Yu(end+1,1:2)=[CC,NEUT];
            Multimeter.V{end+1}=['Ucn: ',BlockNom];
        end

    end

    sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;

    nSwD=find(sps.SwitchType(end-NumberOfSwitches+1:end)==7);
    nD=find(sps.SwitchType(end-NumberOfSwitches+1:end)==3);
    VfOn(nSwD)=ones(1,length(nSwD))*Vfdevice;
    VfOn(nD)=ones(1,length(nD))*Vfdiode;
    VfOff(nSwD)=-ones(1,length(nSwD))*Vfdiode;
    VfOff(nD)=ones(1,length(nD))*Vfdiode;
    sps.SwitchVf(1,end+1:end+NumberOfSwitches)=VfOn;
    sps.SwitchVf(2,end-NumberOfSwitches+1:end)=VfOff;


    sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
    sps.Status.Demux(end+1)=NumberOfSwitches;
    sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
    sps.Gates.Mux(end+1)=NumberOfSwitches;
    if sps.PowerguiInfo.SPID==0
        sps.ITAIL.Tags{end+1}=get_param([BlockName,'/ITAIL'],'GotoTag');
        sps.ITAIL.Mux(end+1)=NumberOfSwitches;
        sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
    end
    sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
    sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
    sps.SwitchDevices.total=sps.SwitchDevices.total+NumberOfSwitches;

    if sps.PowerguiInfo.SPID

        sps.Status.Demux(end)=2*NumberOfSwitches;
    end