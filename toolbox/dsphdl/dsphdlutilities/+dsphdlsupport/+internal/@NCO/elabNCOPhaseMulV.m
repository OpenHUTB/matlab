function waveNet=elabNCOPhaseMulV(this,topNet,blockInfo,dataRate,PInc,acc_enable,reset,phase_output)





    accWL=blockInfo.AccuWL;
    accType=pir_sfixpt_t(accWL,0);
    dim=phase_output.Type.getDimensions;
    inportnames={PInc.Name,acc_enable.Name,reset.Name};
    inporttypes=[PInc.Type,acc_enable.Type,reset.Type];
    inportrates=[dataRate;dataRate;dataRate];
    outportnames={phase_output.Name};
    outporttypes=phase_output.Type;


    waveNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PhaseMul',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );
    insignals=waveNet.PirInputSignals;
    outsignals=waveNet.PirOutputSignals;

    PInc=insignals(1);
    validIn=insignals(2);
    reset_acc=insignals(3);

    validIn_dly=waveNet.addSignal(acc_enable.Type,'valid_dly');
    validIn_dly.SimulinkRate=dataRate;

    reset_acc_dly=waveNet.addSignal(reset.Type,'reset_acc_dly');
    reset_acc_dly.SimulinkRate=dataRate;

    pirelab.getIntDelayComp(waveNet,validIn,validIn_dly,1,'delay_balance',0);
    pirelab.getIntDelayComp(waveNet,reset_acc,reset_acc_dly,1,'',0);
    phase_output=outsignals(1);

    if(dim==1)

        acc_reg=waveNet.addSignal(accType,'acc_reg');
        acc_reg.SimulinkRate=dataRate;
        acc_adder=waveNet.addSignal(accType,'acc_adder');
        acc_adder.SimulinkRate=dataRate;
        PInc_reg=waveNet.addSignal(accType,'output_reg');
        PInc_reg.SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,PInc,PInc_reg);
        pirelab.getAddComp(waveNet,[acc_reg,PInc_reg],acc_adder,'Floor','Wrap',[],[],'++');
        pirelab.getIntDelayEnabledResettableComp(waveNet,acc_adder,acc_reg,validIn_dly,reset_acc_dly,1,'acc',0);

        pirelab.getWireComp(waveNet,acc_reg,phase_output);
    else

        for i=0:3
            radix2_factor(i+1)=waveNet.addSignal(accType,['radix2_factor',num2str(i)]);%#ok<*AGROW>
            radix2_factor(i+1).SimulinkRate=dataRate;
            pirelab.getBitShiftComp(waveNet,PInc,radix2_factor(i+1),'sll',i+1);
        end

        base_factor(1)=waveNet.addSignal(accType,'base_factor1');
        base_factor(1).SimulinkRate=dataRate;
        base_factor(1)=PInc;

        base_factor(2)=waveNet.addSignal(accType,'base_factor2');
        base_factor(2).SimulinkRate=dataRate;
        base_factor(2)=radix2_factor(1);

        base_factor(3)=waveNet.addSignal(accType,'base_factor3');
        base_factor(3).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[PInc,radix2_factor(1)],base_factor(3),'Floor','Wrap');

        base_factor(4)=waveNet.addSignal(accType,'base_factor4');
        base_factor(4).SimulinkRate=dataRate;
        base_factor(4)=radix2_factor(2);

        base_factor(5)=waveNet.addSignal(accType,'base_factor5');
        base_factor(5).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[PInc,radix2_factor(2)],base_factor(5),'Floor','Wrap');

        base_factor(6)=waveNet.addSignal(accType,'base_factor6');
        base_factor(6).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[radix2_factor(1),radix2_factor(2)],base_factor(6),'Floor','Wrap',[],[],'++');

        base_factor(7)=waveNet.addSignal(accType,'base_factor7');
        base_factor(7).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[radix2_factor(3),PInc],base_factor(7),'Floor','Wrap',[],[],'+-');

        base_factor(8)=waveNet.addSignal(accType,'base_factor8');
        base_factor(8).SimulinkRate=dataRate;
        base_factor(8)=radix2_factor(3);

        base_factor(9)=waveNet.addSignal(accType,'base_factor9');
        base_factor(9).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[radix2_factor(3),PInc],base_factor(9),'Floor','Wrap',[],[],'++');

        base_factor(10)=waveNet.addSignal(accType,'base_factor10');
        base_factor(10).SimulinkRate=dataRate;
        pirelab.getAddComp(waveNet,[radix2_factor(3),radix2_factor(1)],base_factor(10),'Floor','Wrap',[],[],'++');



        for i=1:10
            base_factor_delay(i)=waveNet.addSignal(accType,'base_factor_delay');
            base_factor_delay(i).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(waveNet,base_factor(i),base_factor_delay(i),validIn,reset_acc,1,'delay',0);



        end

        vector_phase(1)=waveNet.addSignal(accType,'vector_phase(1)');
        vector_phase(1).SimulinkRate=dataRate;
        pirelab.getWireComp(waveNet,base_factor_delay(1),vector_phase(1));

        vector_phase(2)=waveNet.addSignal(accType,'vector_phase(2)');
        vector_phase(2).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(2),vector_phase(2));

        vector_phase(3)=waveNet.addSignal(accType,'vector_phase(3)');
        vector_phase(3).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(3),vector_phase(3));

        vector_phase(4)=waveNet.addSignal(accType,'vector_phase(4)');
        vector_phase(4).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(4),vector_phase(4));

        vector_phase(5)=waveNet.addSignal(accType,'vector_phase(5)');
        vector_phase(5).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(5),vector_phase(5));

        vector_phase(6)=waveNet.addSignal(accType,'vector_phase(6)');
        vector_phase(6).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(6),vector_phase(6));

        vector_phase(7)=waveNet.addSignal(accType,'vector_phase(7)');
        vector_phase(7).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(7),vector_phase(7));

        vector_phase(8)=waveNet.addSignal(accType,'vector_phase(8)');
        vector_phase(8).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(8),vector_phase(8));

        vector_phase(9)=waveNet.addSignal(accType,'vector_phase(9)');
        vector_phase(9).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(9),vector_phase(9));

        vector_phase(10)=waveNet.addSignal(accType,'vector_phase(10)');
        vector_phase(10).SimulinkRate=dataRate;

        pirelab.getWireComp(waveNet,base_factor_delay(10),vector_phase(10));

        vector_phase(11)=waveNet.addSignal(accType,'vector_phase(11)');
        vector_phase(11).SimulinkRate=dataRate;
        temp_shift_valueA_11=waveNet.addSignal(accType,'temp_shift_valueA_11');
        temp_shift_valueA_11.SimulinkRate=dataRate;
        temp_shift_valueA_11=base_factor_delay(3);
        temp_shift_valueB_11=waveNet.addSignal(accType,'temp_shift_valueB_11');
        temp_shift_valueB_11.SimulinkRate=dataRate;
        temp_shift_valueB_11=base_factor_delay(8);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_11,temp_shift_valueB_11],vector_phase(11),'Floor','Wrap',[],[],'++');

        vector_phase(12)=waveNet.addSignal(accType,'vector_phase(12)');
        vector_phase(12).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),vector_phase(12),'sll',1);

        vector_phase(13)=waveNet.addSignal(accType,'vector_phase(13)');
        vector_phase(13).SimulinkRate=dataRate;
        temp_shift_valueA_13=waveNet.addSignal(accType,'temp_shift_valueA_13');
        temp_shift_valueA_13.SimulinkRate=dataRate;
        temp_shift_valueA_13=base_factor_delay(9);
        temp_shift_valueB_13=waveNet.addSignal(accType,'temp_shift_valueB_13');
        temp_shift_valueB_13.SimulinkRate=dataRate;
        temp_shift_valueB_13=base_factor_delay(4);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_13,temp_shift_valueB_13],vector_phase(13),'Floor','Wrap',[],[],'++');

        vector_phase(14)=waveNet.addSignal(accType,'vector_phase(14)');
        vector_phase(14).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),vector_phase(14),'sll',1);

        vector_phase(15)=waveNet.addSignal(accType,'vector_phase(15)');
        vector_phase(15).SimulinkRate=dataRate;
        temp_shift_valueA_15=waveNet.addSignal(accType,'temp_shift_valueA_15');
        temp_shift_valueA_15.SimulinkRate=dataRate;
        temp_shift_valueA_15=base_factor_delay(5);
        temp_shift_valueB_15=waveNet.addSignal(accType,'temp_shift_valueB_15');
        temp_shift_valueB_15.SimulinkRate=dataRate;
        temp_shift_valueB_15=base_factor_delay(10);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_15,temp_shift_valueB_15],vector_phase(15),'Floor','Wrap',[],[],'++');

        vector_phase(16)=waveNet.addSignal(accType,'vector_phase(16)');
        vector_phase(16).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),vector_phase(16),'sll',1);

        vector_phase(17)=waveNet.addSignal(accType,'vector_phase(17)');
        vector_phase(17).SimulinkRate=dataRate;
        temp_shift_valueA_17=waveNet.addSignal(accType,'temp_shift_valueA_17');
        temp_shift_valueA_17.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueA_17,'sll',1);
        temp_shift_valueB_17=waveNet.addSignal(accType,'temp_shift_valueB_17');
        temp_shift_valueB_17.SimulinkRate=dataRate;
        temp_shift_valueB_17=base_factor_delay(1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_17,temp_shift_valueB_17],vector_phase(17),'Floor','Wrap',[],[],'++');

        vector_phase(18)=waveNet.addSignal(accType,'vector_phase(18)');
        vector_phase(18).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),vector_phase(18),'sll',1);

        vector_phase(19)=waveNet.addSignal(accType,'vector_phase(19)');
        vector_phase(19).SimulinkRate=dataRate;
        temp_shift_valueA_19=waveNet.addSignal(accType,'temp_shift_valueA_19');
        temp_shift_valueA_19.SimulinkRate=dataRate;
        temp_shift_valueA_19=base_factor_delay(9);
        temp_shift_valueB_19=waveNet.addSignal(accType,'temp_shift_valueB_19');
        temp_shift_valueB_19.SimulinkRate=dataRate;
        temp_shift_valueB_19=base_factor_delay(10);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_19,temp_shift_valueB_19],vector_phase(19),'Floor','Wrap',[],[],'++');

        vector_phase(20)=waveNet.addSignal(accType,'vector_phase(20)');
        vector_phase(20).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),vector_phase(20),'sll',1);

        vector_phase(21)=waveNet.addSignal(accType,'vector_phase(21)');
        vector_phase(21).SimulinkRate=dataRate;
        temp_shift_valueA_21=waveNet.addSignal(accType,'temp_shift_valueA_21');
        temp_shift_valueA_21.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueA_21,'sll',1);
        temp_shift_valueB_21=waveNet.addSignal(accType,'temp_shift_valueB_21');
        temp_shift_valueB_21.SimulinkRate=dataRate;
        temp_shift_valueB_21=base_factor_delay(3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_21,temp_shift_valueB_21],vector_phase(21),'Floor','Wrap',[],[],'++');

        vector_phase(22)=waveNet.addSignal(accType,'vector_phase(22)');
        vector_phase(22).SimulinkRate=dataRate;
        temp_shift_valueA_22=waveNet.addSignal(accType,'temp_shift_valueA_22');
        temp_shift_valueA_22.SimulinkRate=dataRate;
        temp_shift_valueA_22=base_factor_delay(2);
        temp_shift_valueB_22=waveNet.addSignal(accType,'temp_shift_valueB_22');
        temp_shift_valueB_22.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_22,'sll',1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_22,temp_shift_valueB_22],vector_phase(22),'Floor','Wrap',[],[],'++');

        vector_phase(23)=waveNet.addSignal(accType,'vector_phase(23)');
        vector_phase(23).SimulinkRate=dataRate;
        temp_shift_valueA_23=waveNet.addSignal(accType,'temp_shift_valueA_23');
        temp_shift_valueA_23.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueA_23,'sll',1);
        temp_shift_valueB_23=waveNet.addSignal(accType,'temp_shift_valueB_23');
        temp_shift_valueB_23.SimulinkRate=dataRate;
        temp_shift_valueB_23=base_factor_delay(5);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_23,temp_shift_valueB_23],vector_phase(23),'Floor','Wrap',[],[],'++');

        vector_phase(24)=waveNet.addSignal(accType,'vector_phase(24)');
        vector_phase(24).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),vector_phase(24),'sll',2);

        vector_phase(25)=waveNet.addSignal(accType,'vector_phase(25)');
        vector_phase(25).SimulinkRate=dataRate;
        temp_shift_valueA_25=waveNet.addSignal(accType,'temp_shift_valueA_25');
        temp_shift_valueA_25.SimulinkRate=dataRate;
        temp_shift_valueA_25=base_factor_delay(9);
        temp_shift_valueB_25=waveNet.addSignal(accType,'temp_shift_valueB_25');
        temp_shift_valueB_25.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueB_25,'sll',1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_25,temp_shift_valueB_25],vector_phase(25),'Floor','Wrap',[],[],'++');

        vector_phase(26)=waveNet.addSignal(accType,'vector_phase(26)');
        vector_phase(26).SimulinkRate=dataRate;
        temp_shift_valueA_26=waveNet.addSignal(accType,'temp_shift_valueA_26');
        temp_shift_valueA_26.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueA_26,'sll',1);
        temp_shift_valueB_26=waveNet.addSignal(accType,'temp_shift_valueB_26');
        temp_shift_valueB_26.SimulinkRate=dataRate;
        temp_shift_valueB_26=base_factor_delay(8);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_26,temp_shift_valueB_26],vector_phase(26),'Floor','Wrap',[],[],'++');

        vector_phase(27)=waveNet.addSignal(accType,'vector_phase(27)');
        vector_phase(27).SimulinkRate=dataRate;
        temp_shift_valueA_27=waveNet.addSignal(accType,'temp_shift_valueA_27');
        temp_shift_valueA_27.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueA_27,'sll',2);
        temp_shift_valueB_27=waveNet.addSignal(accType,'temp_shift_valueB_27');
        temp_shift_valueB_27.SimulinkRate=dataRate;
        temp_shift_valueB_27=base_factor_delay(3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_27,temp_shift_valueB_27],vector_phase(27),'Floor','Wrap',[],[],'++');

        vector_phase(28)=waveNet.addSignal(accType,'vector_phase(28)');
        vector_phase(28).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),vector_phase(28),'sll',2);

        vector_phase(29)=waveNet.addSignal(accType,'vector_phase(29)');
        vector_phase(29).SimulinkRate=dataRate;
        temp_shift_valueA_29=waveNet.addSignal(accType,'temp_shift_valueA_29');
        temp_shift_valueA_29.SimulinkRate=dataRate;
        temp_shift_valueA_29=base_factor_delay(9);
        temp_shift_valueB_29=waveNet.addSignal(accType,'temp_shift_valueB_29');
        temp_shift_valueB_29.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_29,'sll',1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_29,temp_shift_valueB_29],vector_phase(29),'Floor','Wrap',[],[],'++');

        vector_phase(30)=waveNet.addSignal(accType,'vector_phase(30)');
        vector_phase(30).SimulinkRate=dataRate;
        temp_shift_valueA_30=waveNet.addSignal(accType,'temp_shift_valueA_30');
        temp_shift_valueA_30.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueA_30,'sll',2);
        temp_shift_valueB_30=waveNet.addSignal(accType,'temp_shift_valueB_30');
        temp_shift_valueB_30.SimulinkRate=dataRate;
        temp_shift_valueB_30=base_factor_delay(6);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_30,temp_shift_valueB_30],vector_phase(30),'Floor','Wrap',[],[],'++');

        vector_phase(31)=waveNet.addSignal(accType,'vector_phase(31)');
        vector_phase(31).SimulinkRate=dataRate;
        temp_shift_valueA_31=waveNet.addSignal(accType,'temp_shift_valueA_31');
        temp_shift_valueA_31.SimulinkRate=dataRate;
        temp_shift_valueA_31=base_factor_delay(3);
        temp_shift_valueB_31=waveNet.addSignal(accType,'temp_shift_valueB_31');
        temp_shift_valueB_31.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueB_31,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_31,temp_shift_valueB_31],vector_phase(31),'Floor','Wrap',[],[],'++');

        vector_phase(32)=waveNet.addSignal(accType,'vector_phase(32)');
        vector_phase(32).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),vector_phase(32),'sll',2);

        vector_phase(33)=waveNet.addSignal(accType,'vector_phase(33)');
        vector_phase(33).SimulinkRate=dataRate;
        temp_shift_valueA_33=waveNet.addSignal(accType,'temp_shift_valueA_33');
        temp_shift_valueA_33.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueA_33,'sll',2);
        temp_shift_valueB_33=waveNet.addSignal(accType,'temp_shift_valueB_33');
        temp_shift_valueB_33.SimulinkRate=dataRate;
        temp_shift_valueB_33=base_factor_delay(1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_33,temp_shift_valueB_33],vector_phase(33),'Floor','Wrap',[],[],'++');

        vector_phase(34)=waveNet.addSignal(accType,'vector_phase(34)');
        vector_phase(34).SimulinkRate=dataRate;
        temp_shift_valueA_34=waveNet.addSignal(accType,'temp_shift_valueA_34');
        temp_shift_valueA_34.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueA_34,'sll',1);
        temp_shift_valueB_34=waveNet.addSignal(accType,'temp_shift_valueB_34');
        temp_shift_valueB_34.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueB_34,'sll',1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_34,temp_shift_valueB_34],vector_phase(34),'Floor','Wrap',[],[],'++');

        vector_phase(35)=waveNet.addSignal(accType,'vector_phase(35)');
        vector_phase(35).SimulinkRate=dataRate;
        temp_shift_valueA_35=waveNet.addSignal(accType,'temp_shift_valueA_35');
        temp_shift_valueA_35.SimulinkRate=dataRate;
        temp_shift_valueA_35=base_factor_delay(3);
        temp_shift_valueB_35=waveNet.addSignal(accType,'temp_shift_valueB_35');
        temp_shift_valueB_35.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueB_35,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_35,temp_shift_valueB_35],vector_phase(35),'Floor','Wrap',[],[],'++');

        vector_phase(36)=waveNet.addSignal(accType,'vector_phase(36)');
        vector_phase(36).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),vector_phase(36),'sll',2);

        vector_phase(37)=waveNet.addSignal(accType,'vector_phase(37)');
        vector_phase(37).SimulinkRate=dataRate;
        temp_shift_valueA_37=waveNet.addSignal(accType,'temp_shift_valueA_37');
        temp_shift_valueA_37.SimulinkRate=dataRate;
        temp_shift_valueA_37=base_factor_delay(5);
        temp_shift_valueB_37=waveNet.addSignal(accType,'temp_shift_valueB_37');
        temp_shift_valueB_37.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueB_37,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_37,temp_shift_valueB_37],vector_phase(37),'Floor','Wrap',[],[],'++');

        vector_phase(38)=waveNet.addSignal(accType,'vector_phase(38)');
        vector_phase(38).SimulinkRate=dataRate;
        temp_shift_valueA_38=waveNet.addSignal(accType,'temp_shift_valueA_38');
        temp_shift_valueA_38.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueA_38,'sll',2);
        temp_shift_valueB_38=waveNet.addSignal(accType,'temp_shift_valueB_38');
        temp_shift_valueB_38.SimulinkRate=dataRate;
        temp_shift_valueB_38=base_factor_delay(6);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_38,temp_shift_valueB_38],vector_phase(38),'Floor','Wrap',[],[],'++');

        vector_phase(39)=waveNet.addSignal(accType,'vector_phase(39)');
        vector_phase(39).SimulinkRate=dataRate;
        temp_shift_valueA_39=waveNet.addSignal(accType,'temp_shift_valueA_39');
        temp_shift_valueA_39.SimulinkRate=dataRate;
        temp_shift_valueA_39=base_factor_delay(3);
        temp_shift_valueB_39=waveNet.addSignal(accType,'temp_shift_valueB_39');
        temp_shift_valueB_39.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueB_39,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_39,temp_shift_valueB_39],vector_phase(39),'Floor','Wrap',[],[],'++');

        vector_phase(40)=waveNet.addSignal(accType,'vector_phase(40)');
        vector_phase(40).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),vector_phase(40),'sll',2);

        vector_phase(41)=waveNet.addSignal(accType,'vector_phase(41)');
        vector_phase(41).SimulinkRate=dataRate;
        temp_shift_valueA_41=waveNet.addSignal(accType,'temp_shift_valueA_41');
        temp_shift_valueA_41.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueA_41,'sll',2);
        temp_shift_valueB_41=waveNet.addSignal(accType,'temp_shift_valueB_41');
        temp_shift_valueB_41.SimulinkRate=dataRate;
        temp_shift_valueB_41=base_factor_delay(9);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_41,temp_shift_valueB_41],vector_phase(41),'Floor','Wrap',[],[],'++');

        vector_phase(42)=waveNet.addSignal(accType,'vector_phase(42)');
        vector_phase(42).SimulinkRate=dataRate;
        temp_shift_valueA_42=waveNet.addSignal(accType,'temp_shift_valueA_42');
        temp_shift_valueA_42.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueA_42,'sll',2);
        temp_shift_valueB_42=waveNet.addSignal(accType,'temp_shift_valueB_42');
        temp_shift_valueB_42.SimulinkRate=dataRate;
        temp_shift_valueB_42=base_factor_delay(10);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_42,temp_shift_valueB_42],vector_phase(42),'Floor','Wrap',[],[],'++');

        vector_phase(43)=waveNet.addSignal(accType,'vector_phase(43)');
        vector_phase(43).SimulinkRate=dataRate;
        temp_shift_valueA_43=waveNet.addSignal(accType,'temp_shift_valueA_43');
        temp_shift_valueA_43.SimulinkRate=dataRate;
        temp_shift_valueA_43=base_factor_delay(3);
        temp_shift_valueB_43=waveNet.addSignal(accType,'temp_shift_valueB_43');
        temp_shift_valueB_43.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_43,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_43,temp_shift_valueB_43],vector_phase(43),'Floor','Wrap',[],[],'++');

        vector_phase(44)=waveNet.addSignal(accType,'vector_phase(44)');
        vector_phase(44).SimulinkRate=dataRate;
        temp_shift_valueA_44=waveNet.addSignal(accType,'temp_shift_valueA_44');
        temp_shift_valueA_44.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueA_44,'sll',1);
        temp_shift_valueB_44=waveNet.addSignal(accType,'temp_shift_valueB_44');
        temp_shift_valueB_44.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueB_44,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_44,temp_shift_valueB_44],vector_phase(44),'Floor','Wrap',[],[],'++');

        vector_phase(45)=waveNet.addSignal(accType,'vector_phase(45)');
        vector_phase(45).SimulinkRate=dataRate;
        temp_shift_valueA_45=waveNet.addSignal(accType,'temp_shift_valueA_45');
        temp_shift_valueA_45.SimulinkRate=dataRate;
        temp_shift_valueA_45=base_factor_delay(5);
        temp_shift_valueB_45=waveNet.addSignal(accType,'temp_shift_valueB_45');
        temp_shift_valueB_45.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_45,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_45,temp_shift_valueB_45],vector_phase(45),'Floor','Wrap',[],[],'++');

        vector_phase(46)=waveNet.addSignal(accType,'vector_phase(46)');
        vector_phase(46).SimulinkRate=dataRate;
        temp_shift_valueA_46=waveNet.addSignal(accType,'temp_shift_valueA_46');
        temp_shift_valueA_46.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueA_46,'sll',1);
        temp_shift_valueB_46=waveNet.addSignal(accType,'temp_shift_valueB_46');
        temp_shift_valueB_46.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueB_46,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_46,temp_shift_valueB_46],vector_phase(46),'Floor','Wrap',[],[],'++');

        vector_phase(47)=waveNet.addSignal(accType,'vector_phase(47)');
        vector_phase(47).SimulinkRate=dataRate;
        temp_shift_valueA_47=waveNet.addSignal(accType,'temp_shift_valueA_47');
        temp_shift_valueA_47.SimulinkRate=dataRate;
        temp_shift_valueA_47=base_factor_delay(7);
        temp_shift_valueB_47=waveNet.addSignal(accType,'temp_shift_valueB_47');
        temp_shift_valueB_47.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_47,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_47,temp_shift_valueB_47],vector_phase(47),'Floor','Wrap',[],[],'++');

        vector_phase(48)=waveNet.addSignal(accType,'vector_phase(48)');
        vector_phase(48).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),vector_phase(48),'sll',3);

        vector_phase(49)=waveNet.addSignal(accType,'vector_phase(49)');
        vector_phase(49).SimulinkRate=dataRate;
        temp_shift_valueA_49=waveNet.addSignal(accType,'temp_shift_valueA_49');
        temp_shift_valueA_49.SimulinkRate=dataRate;
        temp_shift_valueA_49=base_factor_delay(1);
        temp_shift_valueB_49=waveNet.addSignal(accType,'temp_shift_valueB_49');
        temp_shift_valueB_49.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueB_49,'sll',3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_49,temp_shift_valueB_49],vector_phase(49),'Floor','Wrap',[],[],'++');

        vector_phase(50)=waveNet.addSignal(accType,'vector_phase(50)');
        vector_phase(50).SimulinkRate=dataRate;
        temp_shift_valueA_50=waveNet.addSignal(accType,'temp_shift_valueA_50');
        temp_shift_valueA_50.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueA_50,'sll',2);
        temp_shift_valueB_50=waveNet.addSignal(accType,'temp_shift_valueB_50');
        temp_shift_valueB_50.SimulinkRate=dataRate;
        temp_shift_valueB_50=base_factor_delay(10);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_50,temp_shift_valueB_50],vector_phase(50),'Floor','Wrap',[],[],'++');

        vector_phase(51)=waveNet.addSignal(accType,'vector_phase(51)');
        vector_phase(51).SimulinkRate=dataRate;
        temp_shift_valueA_51=waveNet.addSignal(accType,'temp_shift_valueA_51');
        temp_shift_valueA_51.SimulinkRate=dataRate;
        temp_shift_valueA_51=base_factor_delay(3);
        temp_shift_valueB_51=waveNet.addSignal(accType,'temp_shift_valueB_51');
        temp_shift_valueB_51.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueB_51,'sll',3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_51,temp_shift_valueB_51],vector_phase(51),'Floor','Wrap',[],[],'++');

        vector_phase(52)=waveNet.addSignal(accType,'vector_phase(52)');
        vector_phase(52).SimulinkRate=dataRate;
        temp_shift_valueA_52=waveNet.addSignal(accType,'temp_shift_valueA_52');
        temp_shift_valueA_52.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueA_52,'sll',1);
        temp_shift_valueB_52=waveNet.addSignal(accType,'temp_shift_valueB_52');
        temp_shift_valueB_52.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(10),temp_shift_valueB_52,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_52,temp_shift_valueB_52],vector_phase(52),'Floor','Wrap',[],[],'++');

        vector_phase(53)=waveNet.addSignal(accType,'vector_phase(53)');
        vector_phase(53).SimulinkRate=dataRate;
        temp_shift_valueA_53=waveNet.addSignal(accType,'temp_shift_valueA_53');
        temp_shift_valueA_53.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueA_53,'sll',3);
        temp_shift_valueB_53=waveNet.addSignal(accType,'temp_shift_valueB_53');
        temp_shift_valueB_53.SimulinkRate=dataRate;
        temp_shift_valueB_53=base_factor_delay(5);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_53,temp_shift_valueB_53],vector_phase(53),'Floor','Wrap',[],[],'++');

        vector_phase(54)=waveNet.addSignal(accType,'vector_phase(54)');
        vector_phase(54).SimulinkRate=dataRate;
        temp_shift_valueA_54=waveNet.addSignal(accType,'temp_shift_valueA_54');
        temp_shift_valueA_54.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueA_54,'sll',1);
        temp_shift_valueB_54=waveNet.addSignal(accType,'temp_shift_valueB_54');
        temp_shift_valueB_54.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(9),temp_shift_valueB_54,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_54,temp_shift_valueB_54],vector_phase(54),'Floor','Wrap',[],[],'++');

        vector_phase(55)=waveNet.addSignal(accType,'vector_phase(55)');
        vector_phase(55).SimulinkRate=dataRate;
        temp_shift_valueA_55=waveNet.addSignal(accType,'temp_shift_valueA_55');
        temp_shift_valueA_55.SimulinkRate=dataRate;
        temp_shift_valueA_55=base_factor_delay(7);
        temp_shift_valueB_55=waveNet.addSignal(accType,'temp_shift_valueB_55');
        temp_shift_valueB_55.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueB_55,'sll',3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_55,temp_shift_valueB_55],vector_phase(55),'Floor','Wrap',[],[],'++');

        vector_phase(56)=waveNet.addSignal(accType,'vector_phase(56)');
        vector_phase(56).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),vector_phase(56),'sll',3);

        vector_phase(57)=waveNet.addSignal(accType,'vector_phase(57)');
        vector_phase(57).SimulinkRate=dataRate;
        temp_shift_valueA_57=waveNet.addSignal(accType,'temp_shift_valueA_57');
        temp_shift_valueA_57.SimulinkRate=dataRate;
        temp_shift_valueA_57=base_factor_delay(9);
        temp_shift_valueB_57=waveNet.addSignal(accType,'temp_shift_valueB_57');
        temp_shift_valueB_57.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueB_57,'sll',3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_57,temp_shift_valueB_57],vector_phase(57),'Floor','Wrap',[],[],'++');

        vector_phase(58)=waveNet.addSignal(accType,'vector_phase(58)');
        vector_phase(58).SimulinkRate=dataRate;
        temp_shift_valueA_58=waveNet.addSignal(accType,'temp_shift_valueA_58');
        temp_shift_valueA_58.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueA_58,'sll',3);
        temp_shift_valueB_58=waveNet.addSignal(accType,'temp_shift_valueB_58');
        temp_shift_valueB_58.SimulinkRate=dataRate;
        temp_shift_valueB_58=base_factor_delay(2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_58,temp_shift_valueB_58],vector_phase(58),'Floor','Wrap',[],[],'++');

        vector_phase(59)=waveNet.addSignal(accType,'vector_phase(59)');
        vector_phase(59).SimulinkRate=dataRate;
        temp_shift_valueA_59=waveNet.addSignal(accType,'temp_shift_valueA_59');
        temp_shift_valueA_59.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueA_59,'sll',3);
        temp_shift_valueB_59=waveNet.addSignal(accType,'temp_shift_valueB_59');
        temp_shift_valueB_59.SimulinkRate=dataRate;
        temp_shift_valueB_59=base_factor_delay(3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_59,temp_shift_valueB_59],vector_phase(59),'Floor','Wrap',[],[],'++');

        vector_phase(60)=waveNet.addSignal(accType,'vector_phase(60)');
        vector_phase(60).SimulinkRate=dataRate;
        temp_shift_valueA_60=waveNet.addSignal(accType,'temp_shift_valueA_60');
        temp_shift_valueA_60.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueA_60,'sll',2);
        temp_shift_valueB_60=waveNet.addSignal(accType,'temp_shift_valueB_60');
        temp_shift_valueB_60.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),temp_shift_valueB_60,'sll',2);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_60,temp_shift_valueB_60],vector_phase(60),'Floor','Wrap',[],[],'++');

        vector_phase(61)=waveNet.addSignal(accType,'vector_phase(61)');
        vector_phase(61).SimulinkRate=dataRate;
        temp_shift_valueA_61=waveNet.addSignal(accType,'temp_shift_valueA_61');
        temp_shift_valueA_61.SimulinkRate=dataRate;
        temp_shift_valueA_61=base_factor_delay(5);
        temp_shift_valueB_61=waveNet.addSignal(accType,'temp_shift_valueB_61');
        temp_shift_valueB_61.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueB_61,'sll',3);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_61,temp_shift_valueB_61],vector_phase(61),'Floor','Wrap',[],[],'++');

        vector_phase(62)=waveNet.addSignal(accType,'vector_phase(62)');
        vector_phase(62).SimulinkRate=dataRate;
        temp_shift_valueA_62=waveNet.addSignal(accType,'temp_shift_valueA_62');
        temp_shift_valueA_62.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(6),temp_shift_valueA_62,'sll',3);
        temp_shift_valueB_62=waveNet.addSignal(accType,'temp_shift_valueB_62');
        temp_shift_valueB_62.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueB_62,'sll',1);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_62,temp_shift_valueB_62],vector_phase(62),'Floor','Wrap',[],[],'++');

        vector_phase(63)=waveNet.addSignal(accType,'vector_phase(63)');
        vector_phase(63).SimulinkRate=dataRate;
        temp_shift_valueA_63=waveNet.addSignal(accType,'temp_shift_valueA_63');
        temp_shift_valueA_63.SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(7),temp_shift_valueA_63,'sll',3);
        temp_shift_valueB_63=waveNet.addSignal(accType,'temp_shift_valueB_63');
        temp_shift_valueB_63.SimulinkRate=dataRate;
        temp_shift_valueB_63=base_factor_delay(7);
        pirelab.getAddComp(waveNet,[temp_shift_valueA_63,temp_shift_valueB_63],vector_phase(63),'Floor','Wrap',[],[],'++');

        vector_phase(64)=waveNet.addSignal(accType,'vector_phase(64)');
        vector_phase(64).SimulinkRate=dataRate;
        pirelab.getBitShiftComp(waveNet,base_factor_delay(8),vector_phase(64),'sll',3);

        ZERO=waveNet.addSignal(accType,'ZERO');
        pirelab.getConstComp(waveNet,ZERO,0);
        vector_phase_delay(1)=waveNet.addSignal(accType,'base_factor_delay');
        vector_phase_delay(1).SimulinkRate=dataRate;
        sel=waveNet.addSignal(pir_boolean_t,'sel');
        sel.SimulinkRate=dataRate;
        pirelab.getSwitchComp(waveNet,[ZERO,vector_phase(1)],vector_phase_delay(1),sel,'Switch','==',0);

        for i=2:dim
            vector_phase_delay(i)=waveNet.addSignal(accType,'base_factor_delay');
            vector_phase_delay(i).SimulinkRate=dataRate;




            pirelab.getSwitchComp(waveNet,[vector_phase(i-1),vector_phase(i)],vector_phase_delay(i),sel,'Switch','==',0);

        end

        acc_reg=waveNet.addSignal(accType,'acc_reg');
        acc_reg.SimulinkRate=dataRate;
        acc_adder=waveNet.addSignal(accType,'acc_adder');
        acc_adder.SimulinkRate=dataRate;




        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
        '+dsphdlsupport','+internal','@NCO','cgireml','accInit.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='accInit';

        accInit=waveNet.addComponent2(...
        'kind','cgireml',...
        'Name','accInit',...
        'InputSignals',[vector_phase(dim-1),vector_phase(dim),validIn_dly,reset_acc],...
        'OutputSignals',[sel,acc_reg],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','accInit',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{accWL},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);
        accInit.runConcurrencyMaximizer(0);


        for i=1:dim-1
            output_reg(i)=waveNet.addSignal(accType,'output_reg');
            output_reg(i).SimulinkRate=dataRate;
            phase_adder(i)=waveNet.addSignal(accType,'phase_adder');
            phase_adder(i).SimulinkRate=dataRate;
            pirelab.getAddComp(waveNet,[acc_reg,vector_phase_delay(i)],phase_adder(i),'Floor','Wrap',[],[],'++');
            pirelab.getUnitDelayComp(waveNet,phase_adder(i),output_reg(i),'delay',0);
        end
        output_reg(dim)=waveNet.addSignal(accType,'output_reg');
        output_reg(dim).SimulinkRate=dataRate;
        pirelab.getWireComp(waveNet,acc_reg,output_reg(dim));

        pirelab.getMuxComp(waveNet,output_reg,phase_output);
    end
end

