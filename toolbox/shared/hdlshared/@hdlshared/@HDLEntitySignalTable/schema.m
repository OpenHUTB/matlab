function schema






    mlock;

    package=findpackage('hdlshared');
    this=schema.class(package,'HDLEntitySignalTable');
    findclass(package,'HDLEntitySignal');




    schema.prop(this,'IsSequentialContext','bool');
    p.FactoryValue=0;


    p=schema.prop(this,'ClockList','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';

    p=schema.prop(this,'ClockEnableList','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';

    p=schema.prop(this,'ResetList','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';

    p=schema.prop(this,'InportList','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';

    p=schema.prop(this,'OutportList','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';


    p=schema.prop(this,'CurrentClock','double');
    p.FactoryValue=0;

    p=schema.prop(this,'CurrentClockEnable','double');
    p.FactoryValue=0;

    p=schema.prop(this,'CurrentReset','double');
    p.FactoryValue=0;


    p=schema.prop(this,'NextSignalIndex','int');
    p.FactoryValue=1;



    p=schema.prop(this,'Signals','hdlshared.HDLEntitySignal vector');
    p.FactoryValue=[];







    p=schema.prop(this,'Names','MATLAB array');







    p=schema.prop(this,'PortHandles','mxArray');
    p.FactoryValue=[];




