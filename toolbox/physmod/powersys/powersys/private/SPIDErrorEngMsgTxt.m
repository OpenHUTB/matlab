function[ErrorTitle,ErrorTime,TitleStr,TypeStr,FormatStr,ErrorID]=SPIDErrorEngMsgTxt()





    ErrorTitle='Error in circuit';
    ErrorTime='Error occurred at t = %24.16e s.';


    TitleStr{1,1,1}='The voltage across the following switch is undetermined:';
    TitleStr{1,2,1}='The current flowing through the following switch is undetermined:';
    TitleStr{1,3,1}='The voltage across the following switches are made dependent:';
    TitleStr{1,4,1}='The current flowing through the following switches is made dependent:';
    TypeStr{1,1,1}='iSW_SPID';
    TypeStr{1,2,1}='vSW_SPID';
    FormatStr{1,1,1}='''%s''    (%u: open)';
    FormatStr{1,2,1}='''%s''    (%u: closed)';

    ErrorID{1}='SpecializedPowerSystems:Simulation:UndeterminedSwitchStatus';


    TitleStr{2,1,1}='The following capacitor is short-circuited:';
    TitleStr{2,2,1}='The following inductor is open-circuited:';
    TitleStr{2,3,1}='The following capacitors are connected together:';
    TitleStr{2,4,1}='The following inductors are connected together:';
    TypeStr{2,1,1}='Uc';
    TypeStr{2,2,1}='Il';
    FormatStr{2,1,1}='''%s''    (u = %e V)';
    FormatStr{2,2,1}='''%s''    (i = %e A)';

    TitleStr{2,1,2}='by switching of:';
    TitleStr{2,2,2}='by switching of:';
    TitleStr{2,3,2}='by switching of:';
    TitleStr{2,4,2}='by switching of:';
    TypeStr{2,1,2}='iSW_SPID';
    TypeStr{2,2,2}='vSW_SPID';
    FormatStr{2,1,2}='''%s''    (%u: open)';
    FormatStr{2,2,2}='''%s''    (%u: closed)';

    ErrorID{2}='SpecializedPowerSystems:Simulation:StateDependencies';


    TitleStr{3,1,1}='The following current source is open-circuited:';
    TitleStr{3,2,1}='The following voltage source is short-circuited:';
    TitleStr{3,3,1}='The following current sources are connected together:';
    TitleStr{3,4,1}='The following voltage sources are connected together:';
    TypeStr{3,1,1}='iJ';
    TypeStr{3,2,1}='vE';
    FormatStr{3,1,1}='''%s''    (i = %e A)';
    FormatStr{3,2,1}='''%s''    (u = %e V)';

    TitleStr{3,1,2}='by switching of:';
    TitleStr{3,2,2}='by switching of:';
    TitleStr{3,3,2}='by switching of:';
    TitleStr{3,4,2}='by switching of:';
    TypeStr{3,1,2}='iSW_SPID';
    TypeStr{3,2,2}='vSW_SPID';
    FormatStr{3,1,2}='''%s''    (%u: open)';
    FormatStr{3,2,2}='''%s''    (%u: closed)';

    ErrorID{3}='SpecializedPowerSystems:Simulation:ShortedSource';


    TitleStr{4,1,1}='The following capacitor(s):';
    TitleStr{4,2,1}='The following inductor(s):';
    TitleStr{4,3,1}='The following capacitor(s):';
    TitleStr{4,4,1}='The following inductor(s):';
    TypeStr{4,1,1}='Uc';
    TypeStr{4,2,1}='Il';
    FormatStr{4,1,1}='''%s''    (u = %e V)';
    FormatStr{4,2,1}='''%s''    (i = %e A)';

    TitleStr{4,1,2}='are connected with the following current source:';
    TitleStr{4,2,2}='are connected with the following voltage source:';
    TitleStr{4,3,2}='are connected with the following current sources:';
    TitleStr{4,4,2}='are connected with the following voltage sources:';
    TypeStr{4,1,2}='iJ';
    TypeStr{4,2,2}='vE';
    FormatStr{4,1,2}='''%s''    (i = %e A)';
    FormatStr{4,2,2}='''%s''    (u = %e V)';

    TitleStr{4,1,3}='by switching of:';
    TitleStr{4,2,3}='by switching of:';
    TitleStr{4,3,3}='by switching of:';
    TitleStr{4,4,3}='by switching of:';
    TypeStr{4,1,3}='iSW_SPID';
    TypeStr{4,2,3}='vSW_SPID';
    FormatStr{4,1,3}='''%s''    (%u: open)';
    FormatStr{4,2,3}='''%s''    (%u: closed)';

    ErrorID{4}='SpecializedPowerSystems:Simulation:StateSourceDependencies';


    TitleStr{5,1,1}='The simulation has reached the maximum iterations permissible in search of an adequate configuration for switch status.';

    ErrorID{5}='SpecializedPowerSystems:Simulation:MaximumIterations';

