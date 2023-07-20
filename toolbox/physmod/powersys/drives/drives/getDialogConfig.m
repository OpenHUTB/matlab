function config=getDialogConfig(drive)



























































































    RECTIFIER='Rectifier';
    INVERTER='Inverter';

    switch drive
    case 'AC1'


        config(1)=getAsyncMachine;


        config(1).title='Six-Step VSI Induction Motor Drive';


        config(2).maskType='Universal Bridge';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1];
        config(2).matlabCell=2*ones(1,4);
        config(2).matlabIdx=[3,4,1,2];
        config(2).javaTab=2*ones(1,4);
        config(2).javaIdx=[3,4,1,2];
        config(2).loadIdx=2*ones(1,4);
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1];


        config(3).maskType='DC Bus';
        config(3).handle=[];
        config(3).smlnkVarNames={'Rbrake','frequency','inductance','capacitance'};
        config(3).smlnkIdx=[1,1,1,1];
        config(3).matlabCell=3*ones(1,4);
        config(3).matlabIdx=[3,4,1,2];
        config(3).javaTab=2*ones(1,4);
        config(3).javaIdx=[7,8,5,6];
        config(3).loadIdx=2*ones(1,4);
        config(3).MasksmlnkVarNames={'Rbrake','fbrake','ind_bus','cap_bus'};
        config(3).MasksmlnkIdx=[1,1,1,1];


        config(4).maskType='Inverter (Three-phase)';
        config(4).tag=INVERTER;
        config(4).handle=[];
        config(4).smlnkVarNames=getInverterVarNames(drive);
        config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1];
        config(4).matlabCell=4*ones(1,10);
        config(4).matlabIdx=1:10;
        config(4).javaTab=2*ones(1,10);
        config(4).javaIdx=[9,10,11,12,13,14,15,16,17,18];
        config(4).loadIdx=2*ones(1,10);
        config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1];


        config(5).maskType='Bridge Firing Unit (AC)';
        config(5).handle=[];
        config(5).smlnkVarNames={'net_f'};
        config(5).smlnkIdx=1;
        config(5).matlabCell=5;
        config(5).matlabIdx=2;
        config(5).javaTab=3;
        config(5).javaIdx=2;
        config(5).loadIdx=3;
        config(5).MasksmlnkVarNames={'network_freq'};
        config(5).MasksmlnkIdx=1;


        config(6).maskType='Voltage Controller (DC Bus)';
        config(6).handle=[];
        config(6).smlnkVarNames={'ki','kp','fc'};
        config(6).smlnkIdx=[1,1,1];
        config(6).matlabCell=5*ones(1,3);
        config(6).matlabIdx=[6,5,1];
        config(6).javaTab=3*ones(1,3);
        config(6).javaIdx=[6,5,1];
        config(6).loadIdx=3*ones(1,3);
        config(6).MasksmlnkVarNames={'ki_busc','kp_busc','fc_busc'};
        config(6).MasksmlnkIdx=[1,1,1];


        config(7).maskType='Six-Step Generator';
        config(7).handle=[];
        config(7).smlnkVarNames={'p','pos_dv','neg_dv','accel_ramp',...
        'decel_ramp','minof','maxof','minbv','maxbv','vbhr','zc_time'};
        config(7).smlnkIdx=[1,1,1,1,1,1,1,1,1,1,1];
        config(7).matlabCell=5*ones(1,11);
        config(7).matlabIdx=[15,3,4,9,10,11,12,7,8,13,14];

        config(7).javaTab=[1,3,3,3,3,3,3,3,3,3,3];
        config(7).javaIdx=[18,3,4,9,10,11,12,7,8,13,14];
        config(7).loadIdx=3*ones(1,10);
        config(7).MasksmlnkVarNames={'p','bus_dev_pos','bus_dev_neg','Acc',...
        'Dec','outfreq_min','outfreq_max','busVolt_min','busVolt_max','vh_ratio','zc_time'};
        config(7).MasksmlnkIdx=[-1,1,1,1,1,1,1,1,1,1,1];

    case 'AC2'

        config(1)=getAsyncMachine;


        config(1).title='Space Vector PWM VSI Induction Motor Drive';


        config(2).maskType='Universal Bridge';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1];
        config(2).matlabCell=2*ones(1,4);
        config(2).matlabIdx=[1,2,3,4];
        config(2).javaTab=2*ones(1,4);
        config(2).javaIdx=[1,2,3,4];
        config(2).loadIdx=2*ones(1,4);
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1];


        config(3).maskType='DC Bus';
        config(3).handle=[];
        config(3).smlnkVarNames={'capacitance','Rbrake','frequency','activationVoltage','shutdownVoltage'};
        config(3).smlnkIdx=[1,1,1,1,1];
        config(3).matlabCell=3*ones(1,5);
        config(3).matlabIdx=[1,2,3,4,5];
        config(3).javaTab=2*ones(1,5);
        config(3).javaIdx=[5,6,7,8,9];
        config(3).loadIdx=2*ones(1,5);
        config(3).MasksmlnkVarNames={'cap_bus','Rbrake','fbrake','activationVoltage','shutdownVoltage'};
        config(3).MasksmlnkIdx=[1,1,1,1,1];


        config(4).maskType='Inverter (Three-phase)';
        config(4).tag=INVERTER;
        config(4).handle=[];
        config(4).smlnkVarNames=getInverterVarNames(drive);
        config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1];
        config(4).matlabCell=4*ones(1,10);
        config(4).matlabIdx=1:10;
        config(4).javaTab=2*ones(1,10);
        config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19];
        config(4).loadIdx=2*ones(1,10);
        config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1];


        config(5).maskType='Speed Controller (Scalar Control)';
        config(5).handle=[];
        config(5).smlnkVarNames={'p','ramp','ramp','kp','ki','Tsc','fc',...
        'ctrl_sat','ctrl_sat','ctrl_freq','ctrl_freq','ctrl_volt',...
        'ctrl_volt','vbhr','zc_time'};
        config(5).smlnkIdx=[1,2,1,1,1,1,1,1,2,1,2,1,2,1,1];
        config(5).matlabCell=[-1,5*ones(1,14)];
        config(5).matlabIdx=[18,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
        config(5).javaTab=[1,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
        config(5).javaIdx=[18,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
        config(5).loadIdx=3*ones(1,14);
        config(5).MasksmlnkVarNames={'p','Acc','Dec','kp_sc','ki_sc','Tsc','fc_sc',...
        'ctrl_sat_min','ctrl_sat_max','ctrl_f_min','ctrl_f_max','ctrl_v_min',...
        'ctrl_v_max','vh_ratio','zc_time'};
        config(5).MasksmlnkIdx=[-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

        config(6).maskType='Space Vector Modulator';
        config(6).handle=[];
        config(6).smlnkVarNames={'car_freq','fc_bus','TsMLIV'};
        config(6).smlnkIdx=[1,1,1];
        config(6).matlabCell=[5,5,5];
        config(6).matlabIdx=[15,16,17];
        config(6).javaTab=[3,3,3];
        config(6).javaIdx=[15,16,17];
        config(6).loadIdx=[3,3,3];
        config(6).MasksmlnkVarNames={'car_freq','fc_bus','Tvect'};
        config(6).MasksmlnkIdx=[1,1,1];

    case 'AC3'

        config(1)=getAsyncMachine;


        config(1).title='Field-Oriented Control Induction Motor Drive';


        config(2).maskType='Universal Bridge';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1];
        config(2).matlabCell=2*ones(1,4);
        config(2).matlabIdx=[1,2,3,4];
        config(2).javaTab=2*ones(1,4);
        config(2).javaIdx=[1,2,3,4];
        config(2).loadIdx=2*ones(1,4);
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1];


        config(3).maskType='DC Bus';
        config(3).handle=[];
        config(3).smlnkVarNames={'capacitance','Rbrake','frequency','activationVoltage','shutdownVoltage'};
        config(3).smlnkIdx=[1,1,1,1,1];
        config(3).matlabCell=3*ones(1,5);
        config(3).matlabIdx=[1,2,3,4,5];
        config(3).javaTab=2*ones(1,5);
        config(3).javaIdx=[5,6,7,8,9];
        config(3).loadIdx=2*ones(1,5);
        config(3).MasksmlnkVarNames={'cap_bus','Rbrake','fbrake','activationVoltage','shutdownVoltage'};
        config(3).MasksmlnkIdx=[1,1,1,1,1];


        config(4).maskType='Inverter (Three-phase)';
        config(4).tag=INVERTER;
        config(4).handle=[];
        config(4).smlnkVarNames=getInverterVarNames(drive);
        config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1,1,1,2,1,2,1,1,1];
        config(4).matlabCell=[4,4,4,4,4,4,4,4,4,4,4,-1,-1,-1,-1,-1,-1,-1];
        config(4).matlabIdx=[1,2,3,4,5,6,7,8,9,10,11,6,7,8,9,5,18,1];
        config(4).javaTab=[2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1];
        config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19,20,6,7,8,9,5,18,1];
        config(4).loadIdx=[2,2,2,2,2,2,2,2,2,2,2];
        config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1];


        config(5).maskType='Speed Controller (AC)';
        config(5).handle=[];
        config(5).smlnkVarNames={'nf','ramp','ramp','Tsc','kp','ki','ctrl_sat',...
        'ctrl_sat','p','SwK','fc','fn'};
        config(5).smlnkIdx=[1,2,1,1,1,1,1,2,1,1,1,1];
        config(5).matlabCell=[5,5,5,5,5,5,5,5,-1,5,5,-1];
        config(5).matlabIdx=[2,3,4,6,7,8,9,10,18,19,5,4];
        config(5).javaTab=[3,3,3,3,3,3,3,3,1,3,3,1];
        config(5).javaIdx=[2,3,4,6,7,8,9,10,18,19,5,4];
        config(5).loadIdx=3*ones(1,10);
        config(5).MasksmlnkVarNames={'nf','Acc','Dec','Tsc','kp_sc','ki_sc','Tmin',...
        'Tmax','p','regulationType','fc_sc','fn'};
        config(5).MasksmlnkIdx=[1,1,1,1,1,1,1,1,-1,1,1,-1];


        config(6).maskType='Field-Oriented Controller';
        config(6).handle=[];

        config(6).smlnkVarNames={'kp','ki','csat','csat','h','freq_max',...
        'fc','Tvect','p','Rr','Lm','Llr','in_flux','fc_bus','car_freq',...
        'kp_Id','ki_Id','kp_Iq','ki_Iq','modulationType'};
        config(6).smlnkIdx=[1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        config(6).matlabCell=[5,5,5,5,5,5,5,5,-1,-1,-1,-1,5,...
        5,5,5,5,5,5,5];
        config(6).matlabIdx=[11,12,13,14,15,16,17,18,18,8,5,9,1,20,21,...
        22,23,24,25,26];
        config(6).javaTab=[3,3,3,3,3,3,3,3,1,1,1,1,3,3,3,3,3,3,3,3];
        config(6).javaIdx=[11,12,13,14,15,16,17,18,18,8,5,9,1,20,21,...
        22,23,24,25,26];
        config(6).loadIdx=3*ones(1,16);
        config(6).MasksmlnkVarNames={'kp_fc','ki_fc','fluxmin','fluxmax','h','freq_max',...
        'freqc_fc','Tvect','p','Rr','Lms','Llr','in_flux','fc_bus','car_freq',...
        'kp_Id','ki_Id','kp_Iq','ki_Iq','modulationType'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,1,1,1,1];


    case 'AC4'

        config(1)=getAsyncMachine;


        config(1).title='DTC Induction Motor Drive';


        config(2).maskType='Universal Bridge';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1];
        config(2).matlabCell=2*ones(1,4);
        config(2).matlabIdx=[3,4,1,2];
        config(2).javaTab=2*ones(1,4);
        config(2).javaIdx=[3,4,1,2];
        config(2).loadIdx=2*ones(1,4);
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1];



        config(3).maskType='DC Bus';
        config(3).handle=[];
        config(3).smlnkVarNames={'capacitance','Rbrake','frequency','activationVoltage','shutdownVoltage'};
        config(3).smlnkIdx=[1,1,1,1,1];
        config(3).matlabCell=3*ones(1,5);
        config(3).matlabIdx=[1,2,3,4,5];
        config(3).javaTab=2*ones(1,5);
        config(3).javaIdx=[5,6,7,8,9];
        config(3).loadIdx=2*ones(1,5);
        config(3).MasksmlnkVarNames={'cap_bus','Rbrake','fbrake','activationVoltage','shutdownVoltage'};
        config(3).MasksmlnkIdx=[1,1,1,1,1];



        config(4).maskType='Inverter (Three-phase)';
        config(4).tag=INVERTER;
        config(4).handle=[];
        config(4).smlnkVarNames=getInverterVarNames(drive);
        config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1];
        config(4).matlabCell=4*ones(1,10);
        config(4).matlabIdx=1:10;
        config(4).javaTab=2*ones(1,10);
        config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19];
        config(4).loadIdx=2*ones(1,10);
        config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1];


        config(5).maskType='Speed Controller (AC)';
        config(5).handle=[];
        config(5).smlnkVarNames={'p','ramp','ramp','fc','Tsc','kp','ki',...
        'ctrl_sat','ctrl_sat','SwK','nf','fn'};
        config(5).smlnkIdx=[1,1,2,1,1,1,1,1,2,1,1,1];
        config(5).matlabCell=[-1,5,5,5,5,5,5,5,5,5,5,-1];
        config(5).matlabIdx=[18,2,1,3,4,5,6,7,8,14,11,4];
        config(5).javaTab=[1,3,3,3,3,3,3,3,3,3,3,1];
        config(5).javaIdx=[18,2,1,3,4,5,6,7,8,14,11,4];
        config(5).loadIdx=3*ones(1,9);
        config(5).MasksmlnkVarNames={'p','Dec','Acc','fc_sc','Tsc','kp_sc','ki_sc',...
        'Tmin','Tmax','regulationType','nf','fn'};
        config(5).MasksmlnkIdx=[-1,1,1,1,1,1,1,1,1,1,1,-1];


        config(6).maskType='Direct Torque Controller';
        config(6).handle=[];
        config(6).smlnkVarNames={'T_bw','F_bw','in_flux','freq_max',...
        'Ts_DTFC','Rss','p','fc_bus','car_freq','kp_Te','ki_Te',...
        'kp_Flux','ki_Flux','modulationType'};
        config(6).smlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        config(6).matlabCell=[5,5,5,5,5,-1,-1,5,5,5,5,5,5,5];
        config(6).matlabIdx=[9,10,11,12,13,6,18,15,16,17,18,19,20,21];
        config(6).javaTab=[3,3,3,3,3,1,1,3,3,3,3,3,3,3];
        config(6).javaIdx=[9,10,11,12,13,6,18,15,16,17,18,19,20,21];
        config(6).loadIdx=3*ones(1,12);
        config(6).MasksmlnkVarNames={'T_bw','F_bw','in_flux','freq_max',...
        'Tvect','Rs','p','fc_bus','car_freq','kp_Te','ki_Te',...
        'kp_flux','ki_flux','modulationType'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,-1,-1,1,1,1,1,1,1,1];

    case 'AC5'


        config(1).title='Self-Controlled Synchronous Motor Drive';


        config(1).maskType='Synchronous Machine';
        config(1).handle=[];
        config(1).smlnkVarNames={'NominalParameters','NominalParameters',...
        'NominalParameters','NominalParameters','Stator','Stator',...
        'Stator','Stator','Field','Field','Dampers1','Dampers1',...
        'Dampers1','Dampers1','Mechanical','Mechanical',...
        'Mechanical','InitialConditions','InitialConditions',...
        'InitialConditions','InitialConditions',...
        'InitialConditions','InitialConditions','InitialConditions',...
        'InitialConditions','InitialConditions','PolePairs'};
        config(1).smlnkIdx=[1,2,3,4,1,2,3,4,1,2,1,2,3,4,1,2,3,1,2,3,4,5,6,7,8,9,1];
        config(1).matlabCell=ones(1,27);
        config(1).matlabIdx=[1,2,3,4,5,6,13,14,7,8,9,10,11,12,22,23,24,25,26,15,16,17,18,19,20,21,24];
        config(1).javaTab=ones(1,27);
        config(1).javaIdx=[1,2,3,4,5,6,13,14,7,8,9,10,11,12,22,23,24,25,26,15,16,17,18,19,20,21,24];
        config(1).loadIdx=ones(1,26);
        config(1).MasksmlnkVarNames={'Pn','Vn',...
        'fn','ifn','Rs','Lls',...
        'Lmd','Lmq','Rf','Llf','Rd','Lld',...
        'Rq','Llq','J','Friction',...
        'p','slip','thdeg',...
        'ia','ib',...
        'ic','pha','phb',...
        'phc','vf0','p'};
        config(1).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1];


        config(2).maskType='Active Rectifier';
        config(2).handle=[];
        config(2).smlnkVarNames={'Vgains','Vgains','fc','ctrl_sat',...
        'ctrl_sat','Tsc','h','choke','choke','cap','Snubber',...
        'Snubber','Device','Ron','ForwardVoltages','ForwardVoltages',...
        'GTOparameters','GTOparameters','IGBTparameters',...
        'IGBTparameters','Vs','SourceFrequency'};

        config(2).smlnkIdx=[1,2,1,1,2,1,1,1,2,1,1,2,1,1,1,2,1,2,1,2,1,1];
        config(2).matlabCell=[6,6,6,6,6,6,6,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2];
        config(2).matlabIdx=[1,2,5,3,4,7,6,2,3,1,9,10,1,2,3,4,5,6,7,8,11,12];
        config(2).javaTab=[3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
        config(2).javaIdx=[9,10,13,11,12,15,14,14,15,13,9,10,1,2,3,4,5,6,7,8,11,12];
        config(2).loadIdx=[3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
        config(2).MasksmlnkVarNames={'kp_busc','ki_busc','fc_busc','Isatmin',...
        'Isatmax','Tbusc','h','Rbrake','Lbrake','cap_bus','Rsnb_rec',...
        'Csnb_rec','deviceType_rec','Ron_rec','Vf_rec','Vfd_rec',...
        'Tf_GTO_rec','Tt_GTO_rec','Tf_rec',...
        'Tt_rec','sourceVoltage','sourceFrequency'};

        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];


        config(3).maskType='Inverter (Three-phase)';
        config(3).tag=INVERTER;
        config(3).handle=[];
        config(3).smlnkVarNames=getInverterVarNames(drive);
        config(3).smlnkIdx=[1,1,1,2,1,2,1,2,1,1,1,1,2,3,4,1];
        config(3).matlabCell=[4,4,4,4,4,4,4,4,4,4,2,-1,-1,-1,-1,-1];
        config(3).matlabIdx=[1,2,3,4,5,6,7,8,9,10,12,5,6,13,14,24];
        config(3).javaTab=[2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1];
        config(3).javaIdx=[16,17,18,19,20,21,22,23,24,25,12,5,6,13,14,24];
        config(3).loadIdx=2*ones(1,10);
        config(3).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(3).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1];


        config(4).maskType='Speed Controller (AC)';
        config(4).handle=[];
        config(4).smlnkVarNames={'ramp','ramp','kp','ki','fc',...
        'Tsc','ctrl_sat','ctrl_sat','SwK','p','nf',...
        'fn'};
        config(4).smlnkIdx=[2,1,1,1,1,1,1,2,1,1,1,1];
        config(4).matlabCell=[5,5,5,5,5,5,5,5,7,-1,7,-1];
        config(4).matlabIdx=[1,2,3,4,7,8,5,6,14,24,12,3];
        config(4).javaTab=[3,3,3,3,3,3,3,3,3,1,3,1];
        config(4).javaIdx=[1,2,3,4,7,8,5,6,29,24,27,3];
        config(4).loadIdx=3*ones(1,10);
        config(4).MasksmlnkVarNames={'Acc','Dec','kp_sc','ki_sc','fc_sc',...
        'Tsc','Tmin','Tmax','regulationType','p','nf',...
        'fn'};
        config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,-1,1,-1];


        config(5).maskType='Vector Controller (WFSM)';
        config(5).handle=[];
        config(5).smlnkVarNames={'h','kpfl','kifl','flc_lpf',...
        'flc_sat','flc_sat','mag_v','mag_hvt','fnv','daf',...
        'Tvect','Rs','mag_tot','p'};
        config(5).smlnkIdx=[1,1,1,1,1,2,1,1,1,1,1,1,1,1];
        config(5).matlabCell=[7,7,7,7,7,7,7,7,7,-1,7,-1,7,-1];
        config(5).matlabIdx=[9,1,2,5,3,4,6,7,8,10,11,5,13,24];
        config(5).javaTab=[3,3,3,3,3,3,3,3,3,3,3,1,3,1];
        config(5).javaIdx=[24,16,17,20,18,19,21,22,23,25,26,5,28,24];
        config(5).loadIdx=3*ones(1,12);
        config(5).MasksmlnkVarNames={'h','kp_fc','ki_fc','fc_fc',...
        'Vmin','Vmax','mag_v','mag_hvt','fnv','daf',...
        'Tvect','Rs','mag_tot','p'};
        config(5).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,-1,1,-1,1,-1];

    case{'AC6','AC7','AC8'}


        switch drive
        case 'AC6'
            config(1).title='PM Synchronous Motor Drive';
        case 'AC7'
            config(1).title='Brushless DC Motor Drive';
        case 'AC8'
            config(1).title='Five-Phase PM Synchronous Motor Drive';
        end


        config(1).maskType='Permanent Magnet Synchronous Machine';
        switch drive
        case 'AC6'
            config(1).smlnkVarNames={'Resistance','dqInductances',...
            'dqInductances','Flux','Mechanical','Mechanical',...
            'Mechanical','MachineConstant','VoltageCst','TorqueCst',...
            'InitialConditions','InitialConditions',...
            'InitialConditions','InitialConditions','PolePairs'};
            config(1).smlnkIdx=[1,1,2,1,1,2,3,1,1,1,3,4,1,2,1];
        case 'AC7'
            config(1).smlnkVarNames={'Resistance','Inductance',...
            'Flat','Flux','Mechanical','Mechanical','Mechanical',...
            'MachineConstant','VoltageCst','TorqueCst',...
            'InitialConditions','InitialConditions',...
            'InitialConditions','InitialConditions','PolePairs'};
            config(1).smlnkIdx=[1,1,1,1,1,2,3,1,1,1,3,4,1,2,1];
        case 'AC8'
            config(1).smlnkVarNames={'Resistance','La',...
            'Flux','Mechanical','Mechanical','Mechanical',...
            'MachineConstant','VoltageCst','TorqueCst',...
            'InitialConditions5ph','InitialConditions5ph',...
            'InitialConditions5ph','InitialConditions5ph',...
            'InitialConditions5ph','InitialConditions5ph','PolePairs'};
            config(1).smlnkIdx=[1,1,1,1,2,3,1,1,1,3,4,5,6,1,2,1];
        end

        switch drive
        case{'AC6','AC7'}
            config(1).handle=[];
            config(1).matlabCell=ones(1,15);
            config(1).matlabIdx=[1:14,7];
            config(1).javaTab=ones(1,15);
            config(1).javaIdx=[1:14,7];
            config(1).loadIdx=ones(1,14);
        case 'AC8'
            config(1).handle=[];
            config(1).matlabCell=ones(1,16);
            config(1).matlabIdx=[1:15,7];
            config(1).javaTab=ones(1,16);
            config(1).javaIdx=[1:15,6];
            config(1).loadIdx=ones(1,15);
        end

        switch drive
        case 'AC6'

            config(1).MasksmlnkVarNames={'Rs','Lls',...
            'Lms','FluxCst','J','Friction',...
            'p','MachineConstant','VoltageCst','TorqueCst',...
            'wm','thetam',...
            'ia','ib','p'};
            config(1).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1];
        case 'AC7'
            config(1).MasksmlnkVarNames={'Rs','Lls',...
            'Flat','FluxCst','J','Friction','p',...
            'MachineConstant','VoltageCst','TorqueCst',...
            'wm','thetam',...
            'ia','ib','p'};
            config(1).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1];
        case 'AC8'
            config(1).MasksmlnkVarNames={'Rs','Lls',...
            'FluxCst','J','Friction','p',...
            'MachineConstant','VoltageCst','TorqueCst',...
            'wm','thetam',...
            'ia','ib',...
            'ic','id','p'};
            config(1).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1];
        end


        config(2).maskType='Universal Bridge';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1];
        config(2).matlabCell=2*ones(1,4);
        config(2).matlabIdx=[1,2,3,4];
        config(2).javaTab=2*ones(1,4);
        config(2).javaIdx=[1,2,3,4];
        config(2).loadIdx=2*ones(1,4);
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1];


        config(3).maskType='DC Bus';
        config(3).handle=[];
        config(3).smlnkVarNames={'capacitance','Rbrake','frequency','activationVoltage','shutdownVoltage'};
        config(3).smlnkIdx=[1,1,1,1,1];
        config(3).matlabCell=3*ones(1,5);
        config(3).matlabIdx=[1,2,3,4,5];
        config(3).javaTab=2*ones(1,5);
        config(3).javaIdx=[5,6,7,8,9];
        config(3).loadIdx=2*ones(1,5);
        config(3).MasksmlnkVarNames={'cap_bus','Rbrake','fbrake','activationVoltage','shutdownVoltage'};
        config(3).MasksmlnkIdx=[1,1,1,1,1];


        switch drive
        case{'AC6','AC7'}
            config(4).maskType='Inverter (Three-phase)';
            config(4).tag=INVERTER;
            config(4).handle=[];
            config(4).smlnkVarNames=getInverterVarNames(drive);
        case 'AC8'
            config(4).maskType='Inverter (Five-phase)';
            config(4).tag=INVERTER;
            config(4).handle=[];
            config(4).smlnkVarNames=getInverterVarNames(drive);
        end




















        switch drive
        case 'AC6'
            config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1,1,1,2,1,1,1];
            config(4).matlabCell=[4,4,4,4,4,4,4,4,4,4,4,-1,-1,-1,-1,-1];
            config(4).matlabIdx=[1,2,3,4,5,6,7,8,9,10,11,2,3,4,1,7];
            config(4).javaTab=[2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1];
            config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19,20,2,3,4,1,7];
            config(4).loadIdx=[2,2,2,2,2,2,2,2,2,2,2];
            config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
            config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1];

        case 'AC7'
            config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1,1,1,1];
            config(4).matlabCell=[4,4,4,4,4,4,4,4,4,4,-1,-1,-1];
            config(4).matlabIdx=[1,2,3,4,5,6,7,8,9,10,2,4,1];
            config(4).javaTab=[2,2,2,2,2,2,2,2,2,2,1,1,1];
            config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19,2,4,1];
            config(4).loadIdx=[2,2,2,2,2,2,2,2,2,2];
            config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
            config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,-1,-1,-1];

        case 'AC8'


            config(4).smlnkIdx=[1,1,1,2,1,2,1,2,1,1,1,1,1,1,1];
            config(4).matlabCell=[4,4,4,4,4,4,4,4,4,4,4,-1,-1,-1,-1];
            config(4).matlabIdx=[1,2,3,4,5,6,7,8,9,10,11,2,3,1,6];
            config(4).javaTab=[2,2,2,2,2,2,2,2,2,2,2,1,1,1,1];
            config(4).javaIdx=[10,11,12,13,14,15,16,17,18,19,20,2,3,1,6];
            config(4).loadIdx=[2,2,2,2,2,2,2,2,2,2,2];
            config(4).MasksmlnkVarNames=getInverterVarNames2(drive);
            config(4).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1];
        end


        config(5).maskType='Speed Controller (AC)';
        config(5).handle=[];
        config(5).smlnkVarNames={'ramp','ramp','kp','ki','fc','Tsc','ctrl_sat','ctrl_sat','SwK'};
        config(5).smlnkIdx=[2,1,1,1,1,1,1,2,1];
        config(5).matlabCell=[5,5,5,5,5,5,5,5,5];
        config(5).matlabIdx=[1,2,3,4,5,6,7,8,12];
        config(5).javaTab=[3,3,3,3,3,3,3,3,3];
        config(5).javaIdx=[1,2,3,4,5,6,7,8,12];
        config(5).loadIdx=3*ones(1,9);
        config(5).MasksmlnkVarNames={'Acc','Dec','kp_sc','ki_sc','fc_sc','Tsc','Tmin','Tmax','regulationType'};
        config(5).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1];


        config(6).handle=[];
        switch drive
        case{'AC6'}
            config(6).maskType='Vector Controller (PMSM)';
            config(6).smlnkVarNames={'h','Ts_vect','freq_max','nb_p',...
            'machineConstant','fluxConstant','voltageConstant',...
            'torqueConstant','fc_bus','car_freq','kp_Id',...
            'ki_Id','kp_Iq','ki_Iq','modulationType'};
            config(6).smlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
            config(6).matlabCell=[5,5,5,-1,-1,-1,-1,-1,5,5,5,5,5,5,5];
            config(6).matlabIdx=[10,9,11,7,8,4,9,10,13,14,15,16,...
            17,18,19];
            config(6).javaTab=[3,3,3,1,1,1,1,1,3,3,3,3,3,3,3];
            config(6).javaIdx=[10,9,11,7,8,4,9,10,13,14,15,16,17,...
            18,19];
            config(6).loadIdx=3*ones(1,10);
            config(6).MasksmlnkVarNames={'h','Tvect','freq_max','p',...
            'MachineConstant','FluxCst','VoltageCst',...
            'TorqueCst','fc_bus','car_freq','kp_Id',...
            'ki_Id','kp_Iq','ki_Iq','modulationType'};
            config(6).MasksmlnkIdx=[1,1,1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1];

        case 'AC7'
            config(6).maskType='Current Controller (Brushless DC)';
            config(6).smlnkVarNames={'h','Ts_vect','freq_max','nb_p',...
            'machineConstant','fluxConstant','voltageConstant',...
            'torqueConstant','flat'};
            config(6).smlnkIdx=[1,1,1,1,1,1,1,1,1];
            config(6).matlabCell=[5,5,5,-1,-1,-1,-1,-1,-1];
            config(6).matlabIdx=[10,9,11,7,8,4,9,10,3];
            config(6).javaTab=[3,3,3,1,1,1,1,1,1];
            config(6).javaIdx=[10,9,11,7,8,4,9,10,3];
            config(6).loadIdx=3*ones(1,3);
            config(6).MasksmlnkVarNames={'h','Tvect','freq_max','p',...
            'MachineConstant','FluxCst','VoltageCst',...
            'TorqueCst','Flat'};
            config(6).MasksmlnkIdx=[1,1,1,-1,-1,-1,-1,-1,-1];

        case{'AC8'}
            config(6).maskType='Vector Controller (PMSM)';
            config(6).smlnkVarNames={'h','Ts_vect','freq_max','nb_p',...
            'machineConstant','fluxConstant','voltageConstant',...
            'torqueConstant'};
            config(6).smlnkIdx=[1,1,1,1,1,1,1,1];
            config(6).matlabCell=[5,5,5,-1,-1,-1,-1,-1];
            config(6).matlabIdx=[10,9,11,6,7,3,8,9];
            config(6).javaTab=[3,3,3,1,1,1,1,1];
            config(6).javaIdx=[10,9,11,6,7,3,8,9];
            config(6).loadIdx=3*ones(1,3);
            config(6).MasksmlnkVarNames={'h','Tvect','freq_max','p',...
            'MachineConstant','FluxCst','VoltageCst',...
            'TorqueCst'};
            config(6).MasksmlnkIdx=[1,1,1,-1,-1,-1,-1,-1];
        end

    case 'DC1'

        config(1)=getDcMachine;


        config(1).title='2-Quadrant Single-Phase Rectifier DC Motor Drive';


        config(2).maskType='Thyristor Converter';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=ones(1,9);
        config(2).matlabCell=[2,2,2,2,3,3,3,3,5];
        config(2).matlabIdx=[1,2,3,4,3,4,5,6,1];
        config(2).javaTab=[2,2,2,2,2,2,2,2,3];
        config(2).javaIdx=[1,2,3,4,7,8,9,10,8];
        config(2).loadIdx=[2,2,2,2,2,2,2,2];
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1];



        config(3).maskType='Parallel RLC Branch';
        config(3).handle=[];
        config(3).smlnkVarNames=getRLCvarNames;
        config(3).smlnkIdx=1;
        config(3).matlabCell=3;
        config(3).matlabIdx=1;
        config(3).javaTab=2;
        config(3).javaIdx=5;
        config(3).loadIdx=2;
        config(3).MasksmlnkVarNames={'smoothingInductance'};
        config(3).MasksmlnkIdx=1;


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=3;
        config(4).matlabIdx=2;
        config(4).javaTab=2;
        config(4).javaIdx=6;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Regulation Switch';
        config(5).handle=[];
        config(5).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(5).smlnkIdx=ones(1:6);
        config(5).matlabCell=[6,5,5,-1,5,6];
        config(5).matlabIdx=[6,1,2,1,6,5];
        config(5).javaTab=[3,3,3,1,3,3];
        config(5).javaIdx=[19,8,9,1,13,18];
        config(5).loadIdx=[3,3];
        config(5).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tc'};
        config(5).MasksmlnkIdx=[1,-1,1,-1,1,1];


        config(6).maskType='Speed Controller (DC)';
        config(6).handle=[];
        config(6).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(6).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(6).matlabCell=[4,4,4,4,4,4,4,5,6];
        config(6).matlabIdx=[1,2,3,4,5,7,6,6,5];
        config(6).javaTab=3*ones(1,9);
        config(6).javaIdx=[1,2,3,4,5,7,6,13,18];
        config(6).loadIdx=3*ones(1,8);
        config(6).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tc'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,-1];


        config(7).maskType='Current Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'Pb','Vb','kp','ki','fci','lim','lim','sampling'};
        config(7).smlnkIdx=[1,1,1,1,1,1,2,1];
        config(7).matlabCell=[5,5,5,5,5,6,6,6];
        config(7).matlabIdx=[1,2,3,4,5,1,2,5];
        config(7).javaTab=3*ones(1,8);
        config(7).javaIdx=[8,9,10,11,12,14,15,18];
        config(7).loadIdx=3*ones(1,7);
        config(7).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','alphamin','alphamax','Tc'};
        config(7).MasksmlnkIdx=[-1,-1,1,1,1,1,1,-1];



        config(8).maskType='Bridge Firing Unit (DC)';
        config(8).handle=[];
        config(8).smlnkVarNames={'x4','x9'};
        config(8).smlnkIdx=[1,1];
        config(8).matlabCell=[6,6];
        config(8).matlabIdx=[3,4];
        config(8).javaTab=[3,3];
        config(8).javaIdx=[16,17];
        config(8).loadIdx=3*ones(1,2);
        config(8).MasksmlnkVarNames={'freqSynchro','pulseWitdth'};
        config(8).MasksmlnkIdx=[1,1];

    case 'DC2'

        config(1)=getDcMachine;


        config(1).title='4-Quadrant Single-Phase Rectifier DC Motor Drive';


        config(2).maskType='Thyristor Converter';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=ones(1,10);
        config(2).matlabCell=[2,2,2,2,4,4,4,4,4,6];
        config(2).matlabIdx=[1,2,3,4,4,5,6,7,3,1];
        config(2).javaTab=[2,2,2,2,2,2,2,2,2,3];
        config(2).javaIdx=[1,2,3,4,12,13,14,15,11,8];


        config(2).loadIdx=[2,2,2,2,2,2,2,2];
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1];


        config(3).maskType='Thyristor Converter';
        config(3).tag=INVERTER;
        config(3).handle=[];
        config(3).smlnkVarNames=getInverterVarNames(drive);
        config(3).smlnkIdx=ones(1,10);
        config(3).matlabCell=[3,3,3,3,4,4,4,4,4,6];
        config(3).matlabIdx=[1,2,3,4,4,5,6,7,3,1];
        config(3).javaTab=[2,2,2,2,2,2,2,2,2,3];
        config(3).javaIdx=[5,6,7,8,12,13,14,15,11,8];
        config(3).loadIdx=[2,2,2,2];
        config(3).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(3).MasksmlnkIdx=[1,1,1,1,-1,-1,-1,-1,-1,-1];


        config(4).maskType='Parallel RLC Branch';
        config(4).handle=[];
        config(4).smlnkVarNames=getRLCvarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=4;
        config(4).matlabIdx=1;
        config(4).javaTab=2;
        config(4).javaIdx=9;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'smoothingInductance'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='DC Voltage Source';
        config(5).handle=[];
        config(5).smlnkVarNames=getDCsourceVarNames;
        config(5).smlnkIdx=1;
        config(5).matlabCell=4;
        config(5).matlabIdx=2;
        config(5).javaTab=2;
        config(5).javaIdx=10;
        config(5).loadIdx=2;
        config(5).MasksmlnkVarNames={'Vfield'};
        config(5).MasksmlnkIdx=1;


        config(6).maskType='Circulating Current Inductors';
        config(6).handle=[];
        config(6).smlnkVarNames={'H'};
        config(6).smlnkIdx=1;
        config(6).matlabCell=4;
        config(6).matlabIdx=3;
        config(6).javaTab=2;
        config(6).javaIdx=11;
        config(6).loadIdx=2;
        config(6).MasksmlnkVarNames={'Lcc'};
        config(6).MasksmlnkIdx=-1;


        config(7).maskType='Regulation Switch';
        config(7).handle=[];
        config(7).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(7).smlnkIdx=ones(1:6);
        config(7).matlabCell=[7,6,6,-1,6,7];
        config(7).matlabIdx=[6,1,2,1,6,5];
        config(7).javaTab=[3,3,3,1,3,3];
        config(7).javaIdx=[19,8,9,1,13,18];
        config(7).loadIdx=[3,3];
        config(7).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tc'};
        config(7).MasksmlnkIdx=[1,-1,1,-1,1,1];


        config(8).maskType='Speed Controller (DC)';
        config(8).handle=[];
        config(8).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(8).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(8).matlabCell=[5,5,5,5,5,5,5,6,7];
        config(8).matlabIdx=[1,2,3,4,5,7,6,6,5];
        config(8).javaTab=3*ones(1,9);
        config(8).javaIdx=[1,2,3,4,5,7,6,13,18];
        config(8).loadIdx=3*ones(1,8);
        config(8).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tc'};
        config(8).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,-1];


        config(9).maskType='Current Controller (DC)';
        config(9).handle=[];
        config(9).smlnkVarNames={'Pb','Vb','kp','ki','fci','lim','lim','sampling'};
        config(9).smlnkIdx=[1,1,1,1,1,1,2,1];
        config(9).matlabCell=[6,6,6,6,6,7,7,7];
        config(9).matlabIdx=[1,2,3,4,5,1,2,5];
        config(9).javaTab=3*ones(1,8);
        config(9).javaIdx=[8,9,10,11,12,14,15,18];
        config(9).loadIdx=3*ones(1,7);
        config(9).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','alphamin','alphamax','Tc'};
        config(9).MasksmlnkIdx=[-1,-1,1,1,1,1,1,-1];


        config(10).maskType='Bridge Firing Unit (DC)';
        config(10).handle=[];
        config(10).smlnkVarNames={'x4','x9'};
        config(10).smlnkIdx=[1,1];
        config(10).matlabCell=[7,7];
        config(10).matlabIdx=[3,4];
        config(10).javaTab=[3,3];
        config(10).javaIdx=[16,17];
        config(10).loadIdx=3*ones(1,2);
        config(10).MasksmlnkVarNames={'freqSynchro','pulseWitdth'};
        config(10).MasksmlnkIdx=[1,1];

    case 'DC3'

        config(1)=getDcMachine;


        config(1).title='2-Quadrant Three-Phase Rectifier DC Motor Drive';


        config(2).maskType='Thyristor Converter';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);










        config(2).smlnkIdx=ones(1,9);
        config(2).matlabCell=[2,2,2,2,3,3,3,3,5];
        config(2).matlabIdx=[1,2,3,4,3,4,5,6,1];
        config(2).javaTab=[2,2,2,2,2,2,2,2,3];
        config(2).javaIdx=[1,2,3,4,7,8,9,10,8];
        config(2).loadIdx=[2,2,2,2,2,2,2,2];
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1];



        config(3).maskType='Parallel RLC Branch';
        config(3).handle=[];
        config(3).smlnkVarNames=getRLCvarNames;
        config(3).smlnkIdx=1;
        config(3).matlabCell=3;
        config(3).matlabIdx=1;
        config(3).javaTab=2;
        config(3).javaIdx=5;
        config(3).loadIdx=2;
        config(3).MasksmlnkVarNames={'smoothingInductance'};
        config(3).MasksmlnkIdx=1;


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=3;
        config(4).matlabIdx=2;
        config(4).javaTab=2;
        config(4).javaIdx=6;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Regulation Switch';
        config(5).handle=[];
        config(5).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(5).smlnkIdx=ones(1:6);
        config(5).matlabCell=[6,5,5,-1,5,6];
        config(5).matlabIdx=[6,1,2,1,6,5];
        config(5).javaTab=[3,3,3,1,3,3];
        config(5).javaIdx=[19,8,9,1,13,18];
        config(5).loadIdx=[3,3];
        config(5).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tc'};
        config(5).MasksmlnkIdx=[1,-1,1,-1,1,1];


        config(6).maskType='Speed Controller (DC)';
        config(6).handle=[];
        config(6).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(6).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(6).matlabCell=[4,4,4,4,4,4,4,5,6];
        config(6).matlabIdx=[1,2,3,4,5,7,6,6,5];
        config(6).javaTab=3*ones(1,9);
        config(6).javaIdx=[1,2,3,4,5,7,6,13,18];
        config(6).loadIdx=3*ones(1,8);
        config(6).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tc'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,-1];


        config(7).maskType='Current Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'Pb','Vb','kp','ki','fci','lim','lim','sampling'};
        config(7).smlnkIdx=[1,1,1,1,1,1,2,1];
        config(7).matlabCell=[5,5,5,5,5,6,6,6];
        config(7).matlabIdx=[1,2,3,4,5,1,2,5];
        config(7).javaTab=3*ones(1,8);
        config(7).javaIdx=[8,9,10,11,12,14,15,18];
        config(7).loadIdx=3*ones(1,7);
        config(7).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','alphamin','alphamax','Tc'};
        config(7).MasksmlnkIdx=[-1,-1,1,1,1,1,1,-1];


        config(8).maskType='Bridge Firing Unit (DC)';
        config(8).handle=[];
        config(8).smlnkVarNames={'x4','x9'};
        config(8).smlnkIdx=[1,1];
        config(8).matlabCell=[6,6];
        config(8).matlabIdx=[3,4];
        config(8).javaTab=[3,3];
        config(8).javaIdx=[16,17];
        config(8).loadIdx=3*ones(1,2);
        config(8).MasksmlnkVarNames={'freqSynchro','pulseWitdth'};
        config(8).MasksmlnkIdx=[1,1];

    case 'DC4'

        config(1)=getDcMachine;


        config(1).title='4-Quadrant Three-Phase Rectifier DC Motor Drive';


        config(2).maskType='Thyristor Converter';
        config(2).tag=RECTIFIER;
        config(2).handle=[];
        config(2).smlnkVarNames=getRectifierVarNames(drive);
        config(2).smlnkIdx=ones(1,10);
        config(2).matlabCell=[2,2,2,2,4,4,4,4,4,6];
        config(2).matlabIdx=[1,2,3,4,3,4,5,6,2,1];
        config(2).javaTab=[2,2,2,2,2,2,2,2,2,3];
        config(2).javaIdx=[1,2,3,4,11,12,13,14,10,8];


        config(2).loadIdx=[2,2,2,2,2,2,2,2];
        config(2).MasksmlnkVarNames=getRectifierVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1];


        config(3).maskType='Thyristor Converter';
        config(3).tag=INVERTER;
        config(3).handle=[];
        config(3).smlnkVarNames=getInverterVarNames(drive);
        config(3).smlnkIdx=ones(1,10);
        config(3).matlabCell=[3,3,3,3,4,4,4,4,4,6];
        config(3).matlabIdx=[1,2,3,4,3,4,5,6,2,1];
        config(3).javaTab=[2,2,2,2,2,2,2,2,2,3];
        config(3).javaIdx=[5,6,7,8,11,12,13,14,10,8];
        config(3).loadIdx=[2,2,2,2];
        config(3).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(3).MasksmlnkIdx=[1,1,1,1,-1,-1,-1,-1,-1,-1];


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=4;
        config(4).matlabIdx=1;
        config(4).javaTab=2;
        config(4).javaIdx=9;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Circulating Current Inductors';
        config(5).handle=[];
        config(5).smlnkVarNames={'H'};
        config(5).smlnkIdx=1;
        config(5).matlabCell=4;
        config(5).matlabIdx=2;
        config(5).javaTab=2;
        config(5).javaIdx=10;
        config(5).loadIdx=2;
        config(5).MasksmlnkVarNames={'Lcc'};
        config(5).MasksmlnkIdx=-1;


        config(6).maskType='Regulation Switch';
        config(6).handle=[];
        config(6).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(6).smlnkIdx=ones(1:6);
        config(6).matlabCell=[7,6,6,-1,6,7];
        config(6).matlabIdx=[6,1,2,1,6,5];
        config(6).javaTab=[3,3,3,1,3,3];
        config(6).javaIdx=[19,8,9,1,13,18];
        config(6).loadIdx=[3,3];
        config(6).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tc'};
        config(6).MasksmlnkIdx=[1,-1,1,-1,1,1];


        config(7).maskType='Speed Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(7).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(7).matlabCell=[5,5,5,5,5,5,5,6,7];
        config(7).matlabIdx=[1,2,3,4,5,7,6,6,5];
        config(7).javaTab=3*ones(1,9);
        config(7).javaIdx=[1,2,3,4,5,7,6,13,18];
        config(7).loadIdx=3*ones(1,8);
        config(7).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tc'};
        config(7).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,-1];


        config(8).maskType='Current Controller (DC)';
        config(8).handle=[];
        config(8).smlnkVarNames={'Pb','Vb','kp','ki','fci','lim','lim','sampling'};
        config(8).smlnkIdx=[1,1,1,1,1,1,2,1];
        config(8).matlabCell=[6,6,6,6,6,7,7,7];
        config(8).matlabIdx=[1,2,3,4,5,1,2,5];
        config(8).javaTab=3*ones(1,8);
        config(8).javaIdx=[8,9,10,11,12,14,15,18];
        config(8).loadIdx=3*ones(1,7);
        config(8).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','alphamin','alphamax','Tc'};
        config(8).MasksmlnkIdx=[-1,-1,1,1,1,1,1,-1];


        config(9).maskType='Bridge Firing Unit (DC)';
        config(9).handle=[];
        config(9).smlnkVarNames={'x4','x9'};
        config(9).smlnkIdx=[1,1];
        config(9).matlabCell=[7,7];
        config(9).matlabIdx=[3,4];
        config(9).javaTab=[3,3];
        config(9).javaIdx=[16,17];
        config(9).loadIdx=3*ones(1,2);
        config(9).MasksmlnkVarNames={'freqSynchro','pulseWitdth'};
        config(9).MasksmlnkIdx=[1,1];

    case 'DC5'

        config(1)=getDcMachine;


        config(1).title='1-Quadrant Chopper DC Motor Drive';


        config(2).maskType='Chopper';
        config(2).tag=INVERTER;
        config(2).handle=[];
        config(2).smlnkVarNames=getInverterVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1,2,1,2];
        config(2).matlabCell=2*ones(1,7);
        config(2).matlabIdx=[1,2,3,4,5,6,7];
        config(2).javaTab=2*ones(1,7);
        config(2).javaIdx=[1,2,3,4,5,6,7];
        config(2).loadIdx=2*ones(1,7);
        config(2).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1];


        config(3).maskType='Parallel RLC Branch';
        config(3).handle=[];
        config(3).smlnkVarNames=getRLCvarNames;
        config(3).smlnkIdx=1;
        config(3).matlabCell=3;
        config(3).matlabIdx=1;
        config(3).javaTab=2;
        config(3).javaIdx=8;
        config(3).loadIdx=2;
        config(3).MasksmlnkVarNames={'smoothingInductance'};
        config(3).MasksmlnkIdx=1;


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=3;
        config(4).matlabIdx=2;
        config(4).javaTab=2;
        config(4).javaIdx=9;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Regulation Switch';
        config(5).handle=[];
        config(5).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(5).smlnkIdx=ones(1:6);
        config(5).matlabCell=[5,5,5,-1,5,5];
        config(5).matlabIdx=[9,1,2,1,6,7];
        config(5).javaTab=[3,3,3,1,3,3];
        config(5).javaIdx=[17,9,10,1,14,15];
        config(5).loadIdx=3;
        config(5).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tic'};
        config(5).MasksmlnkIdx=[1,1,1,-1,1,1];


        config(6).maskType='Speed Controller (DC)';
        config(6).handle=[];
        config(6).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(6).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(6).matlabCell=[4,4,4,4,4,4,4,5,4];
        config(6).matlabIdx=[1,2,3,4,5,7,6,6,8];
        config(6).javaTab=3*ones(1,9);
        config(6).javaIdx=[1,2,3,4,5,7,6,14,8];
        config(6).loadIdx=3*ones(1,9);
        config(6).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tsc'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,1];


        config(7).maskType='Current Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'Pb','Vb','kp','ki','fci','sampling','F'};
        config(7).smlnkIdx=[1,1,1,1,1,1,1];
        config(7).matlabCell=[5,5,5,5,5,5,5];
        config(7).matlabIdx=[1,2,3,4,5,7,8];
        config(7).javaTab=3*ones(1,7);
        config(7).javaIdx=[9,10,11,12,13,15,16];
        config(7).loadIdx=3*ones(1,7);
        config(7).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','Tic','switchfreq'};
        config(7).MasksmlnkIdx=[-1,-1,1,1,1,-1,1];

    case 'DC6'

        config(1)=getDcMachine;


        config(1).title='2-Quadrant Chopper DC Motor Drive';


        config(2).maskType='Chopper';
        config(2).tag=INVERTER;
        config(2).handle=[];
        config(2).smlnkVarNames=getInverterVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1,2,1,2];
        config(2).matlabCell=2*ones(1,7);
        config(2).matlabIdx=[1,2,3,4,5,6,7];
        config(2).javaTab=2*ones(1,7);
        config(2).javaIdx=[1,2,3,4,5,6,7];
        config(2).loadIdx=2*ones(1,7);
        config(2).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1];


        config(3).maskType='Parallel RLC Branch';
        config(3).handle=[];
        config(3).smlnkVarNames=getRLCvarNames;
        config(3).smlnkIdx=1;
        config(3).matlabCell=3;
        config(3).matlabIdx=1;
        config(3).javaTab=2;
        config(3).javaIdx=8;
        config(3).loadIdx=2;
        config(3).MasksmlnkVarNames={'smoothingInductance'};
        config(3).MasksmlnkIdx=1;


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=3;
        config(4).matlabIdx=2;
        config(4).javaTab=2;
        config(4).javaIdx=9;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Regulation Switch';
        config(5).handle=[];
        config(5).smlnkVarNames={'SwK','P','V','Laf','lim','sampling','Ra','Ron','Von'};
        config(5).smlnkIdx=ones(1:9);
        config(5).matlabCell=[5,5,5,-1,5,5,-1,-2,-2];
        config(5).matlabIdx=[9,1,2,1,6,7,2,3,4];
        config(5).javaTab=[3,3,3,1,3,3,1,2,2];
        config(5).javaIdx=[17,9,10,1,14,15,2,3,4];
        config(5).loadIdx=3;
        config(5).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tic','Ra','Ron','Vf'};
        config(5).MasksmlnkIdx=[1,1,1,-1,1,1,-1,-1,-1];


        config(6).maskType='Speed Controller (DC)';
        config(6).handle=[];
        config(6).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(6).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(6).matlabCell=[4,4,4,4,4,4,4,5,4];
        config(6).matlabIdx=[1,2,3,4,5,7,6,6,8];
        config(6).javaTab=3*ones(1,9);
        config(6).javaIdx=[1,2,3,4,5,7,6,14,8];
        config(6).loadIdx=3*ones(1,9);
        config(6).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tsc'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,1];


        config(7).maskType='Current Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'Pb','Vb','kp','ki','fci','sampling','F'};
        config(7).smlnkIdx=[1,1,1,1,1,1,1];
        config(7).matlabCell=[5,5,5,5,5,5,5];
        config(7).matlabIdx=[1,2,3,4,5,7,8];
        config(7).javaTab=3*ones(1,7);
        config(7).javaIdx=[9,10,11,12,13,15,16];
        config(7).loadIdx=3*ones(1,7);
        config(7).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','Tic','switchfreq'};
        config(7).MasksmlnkIdx=[-1,-1,1,1,1,-1,1];

    case 'DC7'

        config(1)=getDcMachine;


        config(1).title='4-Quadrant Chopper DC Motor Drive';


        config(2).maskType='Chopper';
        config(2).tag=INVERTER;
        config(2).handle=[];
        config(2).smlnkVarNames=getInverterVarNames(drive);
        config(2).smlnkIdx=[1,1,1,1,2,1,2];
        config(2).matlabCell=2*ones(1,7);
        config(2).matlabIdx=[1,2,3,4,5,6,7];
        config(2).javaTab=2*ones(1,7);
        config(2).javaIdx=[1,2,3,4,5,6,7];
        config(2).loadIdx=2*ones(1,7);
        config(2).MasksmlnkVarNames=getInverterVarNames2(drive);
        config(2).MasksmlnkIdx=[1,1,1,1,1,1,1];


        config(3).maskType='Parallel RLC Branch';
        config(3).handle=[];
        config(3).smlnkVarNames=getRLCvarNames;
        config(3).smlnkIdx=1;
        config(3).matlabCell=3;
        config(3).matlabIdx=1;
        config(3).javaTab=2;
        config(3).javaIdx=8;
        config(3).loadIdx=2;
        config(3).MasksmlnkVarNames={'smoothingInductance'};
        config(3).MasksmlnkIdx=1;


        config(4).maskType='DC Voltage Source';
        config(4).handle=[];
        config(4).smlnkVarNames=getDCsourceVarNames;
        config(4).smlnkIdx=1;
        config(4).matlabCell=3;
        config(4).matlabIdx=2;
        config(4).javaTab=2;
        config(4).javaIdx=9;
        config(4).loadIdx=2;
        config(4).MasksmlnkVarNames={'Vfield'};
        config(4).MasksmlnkIdx=1;


        config(5).maskType='Regulation Switch';
        config(5).handle=[];
        config(5).smlnkVarNames={'SwK','P','V','Laf','lim','sampling'};
        config(5).smlnkIdx=ones(1:6);
        config(5).matlabCell=[5,5,5,-1,5,5];
        config(5).matlabIdx=[9,1,2,1,6,7];
        config(5).javaTab=[3,3,3,1,3,3];
        config(5).javaIdx=[17,9,10,1,14,15];
        config(5).loadIdx=3;
        config(5).MasksmlnkVarNames={'regulationType','Pb','Vb','Laf','refLim','Tic'};
        config(5).MasksmlnkIdx=[1,1,1,-1,1,1];


        config(6).maskType='Speed Controller (DC)';
        config(6).handle=[];
        config(6).smlnkVarNames={'wb','Is','fcw','kp','ki','ramp','ramp','lim','sampling'};
        config(6).smlnkIdx=[1,1,1,1,1,1,2,1,1];
        config(6).matlabCell=[4,4,4,4,4,4,4,5,4];
        config(6).matlabIdx=[1,2,3,4,5,7,6,6,8];
        config(6).javaTab=3*ones(1,9);
        config(6).javaIdx=[1,2,3,4,5,7,6,14,8];
        config(6).loadIdx=3*ones(1,9);
        config(6).MasksmlnkVarNames={'wb','InitialSpeed','fc_sc','kp_sc','ki_sc','Dec','Acc','refLim','Tsc'};
        config(6).MasksmlnkIdx=[1,1,1,1,1,1,1,-1,1];


        config(7).maskType='Current Controller (DC)';
        config(7).handle=[];
        config(7).smlnkVarNames={'Pb','Vb','kp','ki','fci','sampling','F'};
        config(7).smlnkIdx=[1,1,1,1,1,1,1];
        config(7).matlabCell=[5,5,5,5,5,5,5];
        config(7).matlabIdx=[1,2,3,4,5,7,8];
        config(7).javaTab=3*ones(1,7);
        config(7).javaIdx=[9,10,11,12,13,15,16];
        config(7).loadIdx=3*ones(1,7);
        config(7).MasksmlnkVarNames={'Pb','Vb','kp_ic','ki_ic','fc_ic','Tic','switchfreq'};
        config(7).MasksmlnkIdx=[-1,-1,1,1,1,-1,1];

    otherwise
        getInvalidDriveTypeError(drive);
        config=[];
        return;
    end

    function s=getAsyncMachine()

        s.maskType='Asynchronous Machine';
        s.handle=[];
        s.smlnkIdx=[1,1,2,3,1,1,2,1,2,3,4,5,6,7,8,1,2,3,1,2,1,1];
        s.matlabCell=ones(1,22);
        s.matlabIdx=[1:20,18,21];
        s.javaTab=ones(1,22);
        s.javaIdx=[1:20,18,21];
        s.loadIdx=ones(1,21);
        s.smlnkVarNames={'ReferenceFrame','NominalParameters',...
        'NominalParameters','NominalParameters','Lm',...
        'Stator','Stator','Rotor','Rotor','InitialConditions',...
        'InitialConditions','InitialConditions','InitialConditions',...
        'InitialConditions','InitialConditions','Mechanical',...
        'Mechanical','Mechanical','InitialConditions',...
        'InitialConditions','PolePairs','IterativeModel'};
        s.MasksmlnkVarNames={'ReferenceFrame','Pn',...
        'Vn','fn','Lms',...
        'Rs','Lls','Rr','Llr','ia',...
        'ib','ic','pha',...
        'phb','phc','J',...
        'Friction','p','slip',...
        'thdeg','p','IterativeDiscreteModel'};
        s.MasksmlnkIdx=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,1];

        function s=getDcMachine()



            s.maskType='DC machine';
            s.handle=[];
            s.smlnkVarNames={'Laf','RLa','RLa','RLf','RLf','J','Bm','Tf','w0'};
            s.smlnkIdx=[1,1,2,1,2,1,1,1,1];
            s.matlabCell=ones(1,9);
            s.matlabIdx=1:9;
            s.javaTab=ones(1,9);
            s.javaIdx=1:9;
            s.loadIdx=ones(1,9);
            s.MasksmlnkVarNames={'Laf','Ra','La','Rf','Lf','J','Bm','Tfriction','w0'};
            s.MasksmlnkIdx=[1,1,1,1,1,1,1,1,1];

            function v=getRectifierVarNames(drive)

                switch drive
                case{'AC1','AC4'}
                    v={'Ron','ForwardVoltage','SnubberResistance',...
                    'SnubberCapacitance'};
                case{'AC2','AC3','AC6','AC7','AC8'}
                    v={'SnubberResistance','SnubberCapacitance','Ron',...
                    'ForwardVoltage'};
                case{'DC1','DC3'}
                    v={'SnubberResistance','SnubberCapacitance','Ron',...
                    'ForwardVoltage','LineVoltage','LineFrequency',...
                    'SourceInductance','initAngle','NominalPower'};
                case{'DC2','DC4'}
                    v={'SnubberResistance','SnubberCapacitance','Ron',...
                    'ForwardVoltage','LineVoltage','LineFrequency',...
                    'SourceInductance','initAngle','CirculationInductance',...
                    'NominalPower'};
                otherwise
                    getInvalidDriveTypeError(drive);
                    v=[];
                    return;
                end
                function v=getRectifierVarNames2(drive)

                    switch drive
                    case{'AC1','AC4'}
                        v={'Ron_rec','Vf_rec','Rsnb_rec',...
                        'Csnb_rec'};
                    case{'AC2','AC3','AC6','AC7','AC8'}
                        v={'Rsnb_rec','Csnb_rec','Ron_rec',...
                        'Vf_rec'};

                    case{'DC1','DC3'}
                        v={'Rsnb_rec','Csnb_rec','Ron_rec',...
                        'Vf_rec','LineVoltage','LineFrequency',...
                        'sourceInductance','PhaseAngle','Pb'};

                    case{'DC2','DC4'}
                        v={'Rsnb_rec1','Csnb_rec1','Ron_rec1',...
                        'Vf_rec1','LineVoltage','LineFrequency',...
                        'sourceInductance','PhaseAngle','Lcc',...
                        'Pb'};
                    otherwise
                        getInvalidDriveTypeError(drive);
                        v=[];
                        return;
                    end

                    function v=getInverterVarNames(drive)

                        switch drive
                        case{'AC1','AC2','AC4'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance'};
                        case{'AC3'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance','SourceFrequency','Stator_im','Stator_im',...
                            'Rotor','Rotor','Lm','p','ReferenceFrame'};
                        case{'AC5'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance','SourceFrequency','Stator_sm','Stator_sm',...
                            'Stator_sm','Stator_sm','p'};



















                        case{'AC6'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance','SourceFrequency','dqInductances',...
                            'dqInductances','Flux','Resistance','p'};
                        case{'AC7'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance','Inductance',...
                            'Flux','Resistance'};
                        case{'AC8'}
                            v={'Device','Ron','ForwardVoltages','ForwardVoltages',...
                            'GTOparameters','GTOparameters','IGBTparameters',...
                            'IGBTparameters','SnubberResistance',...
                            'SnubberCapacitance','SourceFrequency','Ls',...
                            'Flux','Resistance','p'};
                        case{'DC2','DC4'}
                            v={'SnubberResistance','SnubberCapacitance','Ron',...
                            'ForwardVoltage','LineVoltage','LineFrequency',...
                            'SourceInductance','initAngle','CirculationInductance',...
                            'NominalPower'};
                        case{'DC5','DC6','DC7'}
                            v={'SnubberResistance','SnubberCapacitance','Ron',...
                            'ForwardVoltages','ForwardVoltages',...
                            'IGBTparameters','IGBTparameters'};
                        otherwise
                            getInvalidDriveTypeError(drive);
                            v=[];
                            return;
                        end

                        function v=getInverterVarNames2(drive)

                            switch drive
                            case{'AC1','AC2','AC4'}
                                v={'deviceType','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO','Tt_GTO','Tf',...
                                'Tt','Rsnb_inv',...
                                'Csnb_inv'};
                            case{'AC3'}
                                v={'deviceType','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO','Tt_GTO','Tf',...
                                'Tt','Rsnb_inv',...
                                'Csnb_inv','sourceFrequency','Rs','Lls',...
                                'Rr','Llr','Lms','p','ReferenceFrame'};
                            case{'AC5'}
                                v={'deviceType_inv','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO_inv','Tt_GTO_inv','Tf_inv',...
                                'Tt_inv','Rsnb_inv',...
                                'Csnb_inv','sourceFrequency','Rs','Lls',...
                                'Lmd','Lmq','p'};



















                            case{'AC6'}
                                v={'deviceType','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO','Tt_GTO','Tf',...
                                'Tt','Rsnb_inv',...
                                'Csnb_inv','sourceFrequency','Lls',...
                                'Lms','FluxCst','Rs','p'};
                            case{'AC7'}
                                v={'deviceType','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO','Tt_GTO','Tf',...
                                'Tt','Rsnb_inv',...
                                'Csnb_inv','Lls',...
                                'FluxCst','Rs'};
                            case{'AC8'}
                                v={'deviceType','Ron_inv','Vf_inv','Vfd_inv',...
                                'Tf_GTO','Tt_GTO','Tf',...
                                'Tt','Rsnb_inv',...
                                'Csnb_inv','sourceFrequency','Lls',...
                                'FluxCst','Rs','p'};
                            case{'DC2','DC4'}
                                v={'Rsnb_rec2','Csnb_rec2','Ron_rec2',...
                                'Vf_rec2','LineVoltage','LineFrequency',...
                                'sourceInductance','PhaseAngle','Lcc',...
                                'Pb'};
                            case{'DC5','DC6','DC7'}
                                v={'Rsnb','Csnb','Ron',...
                                'Vf','Vfd',...
                                'Tf','Tt'};
                            otherwise
                                getInvalidDriveTypeError(drive);
                                v=[];
                                return;
                            end

                            function v=getRLCvarNames

                                v={'Inductance'};

                                function v=getDCsourceVarNames

                                    v={'Amplitude'};

                                    function[]=getInvalidDriveTypeError(drive)

                                        powericon('psberror',...
                                        ['Unrecognized drive type ''',drive,''' in function ',mfilename,'.'],...
                                        'SpecializedPowerSystems:GetDialogConfig:InvalidDriveType','NoUiwait');
