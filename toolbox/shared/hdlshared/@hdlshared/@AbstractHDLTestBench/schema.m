function schema




    mlock;

    pkg=findpackage('hdlshared');
    this=schema.class(pkg,'AbstractHDLTestBench');


    schema.prop(this,'TargetLanguage','HDLTargetLanguage');
    schema.prop(this,'CodeGenDirectory','ustring');

    schema.prop(this,'TestBenchName','ustring');
    schema.prop(this,'TestBenchPostfix','ustring');
    schema.prop(this,'TestBenchDataPostfix','ustring');

    schema.prop(this,'TBFileNameSuffix','ustring');

    schema.prop(this,'TestBenchStimulus','mxArray');
    schema.prop(this,'TBRefSignals','bool');

    schema.prop(this,'ClockName','ustring');
    schema.prop(this,'ClockEnableName','ustring');
    schema.prop(this,'ResetName','ustring');
    schema.prop(this,'DataValidName','ustring');

    schema.prop(this,'ForceClockEnable','bool');
    schema.prop(this,'ForceClockEnableValue','int');

    schema.prop(this,'ForceClock','bool');
    schema.prop(this,'ForceClockHighTime','mxArray');
    schema.prop(this,'ForceClockLowTime','mxArray');
    schema.prop(this,'ForceHoldTime','mxArray');

    schema.prop(this,'HDLSimResolution','mxArray');

    schema.prop(this,'ForceReset','bool');
    schema.prop(this,'ForceResetValue','int');

    schema.prop(this,'ErrorMargin','int');


    p=schema.prop(this,'DutHasOutputs','bool');
    p.FactoryValue=true;

    schema.prop(this,'DutName','ustring');


    schema.prop(this,'hdlcomponentdecl','ustring');
    schema.prop(this,'hdlcomponentinst','ustring');
    schema.prop(this,'hdlcomponentconf','ustring');


    p=schema.prop(this,'InportSrc','mxArray');
    p.AccessFlags.AbortSet='off';

    p=schema.prop(this,'OutportSnk','mxArray');
    p.AccessFlags.AbortSet='off';



    schema.prop(this,'hdlSignals','mxArray');


    p=schema.prop(this,'DUTInport','mxArray');
    p.AccessFlags.AbortSet='off';

    p=schema.prop(this,'DUTOutport','mxArray');
    p.AccessFlags.AbortSet='off';


    schema.prop(this,'clkrate','int');
    schema.prop(this,'latency','int');
    schema.prop(this,'phaseVector','mxArray');
    schema.prop(this,'tbRates','mxArray');
    schema.prop(this,'initialLatency','int');
    schema.prop(this,'clockTable','mxArray');



    schema.prop(this,'TestBenchClockEnableDelay','int');
    schema.prop(this,'holdInputDataBetweenSamples','bool');
    schema.prop(this,'initializetestbenchinputs','bool');
    schema.prop(this,'resetlength','int');

    p=schema.prop(this,'doubleErrorMargin','ustring');
    p.FactoryValue='1.0e-9';
    p=schema.prop(this,'fixedPointErrorMargin','ustring');
    p.FactoryValue='0';

    schema.prop(this,'TestBenchFilesList','string vector');
    schema.prop(this,'TestBenchFile','ustring');
    schema.prop(this,'tbFileId','int');
    schema.prop(this,'TestBenchPackageFile','ustring');
    schema.prop(this,'tbPkgFileId','int');
    schema.prop(this,'TestBenchDataFile','ustring');
    schema.prop(this,'tbDataFileId','int');

    schema.prop(this,'additionalSimFailureMsg','ustring');
    p=schema.prop(this,'minPortSampleTime','double');
    p.FactoryValue=-1;


