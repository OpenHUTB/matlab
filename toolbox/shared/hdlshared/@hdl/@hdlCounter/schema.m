function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    this=schema.class(package,'hdlCounter',parent);

    schema.prop(this,'Countertype','ustring');

    schema.prop(this,'sync_reset','hdlcoder.signal');
    schema.prop(this,'load_en','hdlcoder.signal');
    schema.prop(this,'load_value','hdlcoder.signal');
    schema.prop(this,'cnt_en','hdlcoder.signal');
    schema.prop(this,'cnt_dir','hdlcoder.signal');

    schema.prop(this,'StepSignal','hdlcoder.signal');
    schema.prop(this,'posStepSignal','hdlcoder.signal');
    schema.prop(this,'negStepSignal','hdlcoder.signal');
    schema.prop(this,'StepReg','hdlcoder.signal');
    schema.prop(this,'posStepReg','hdlcoder.signal');
    schema.prop(this,'negStepReg','hdlcoder.signal');
    schema.prop(this,'ComplSignal','hdlcoder.signal');
    schema.prop(this,'CounterSignal','hdlcoder.signal');
    schema.prop(this,'nextCount','hdlcoder.signal');
    schema.prop(this,'countUpCond','hdlcoder.signal');

    schema.prop(this,'resetvalues','mxArray');
    schema.prop(this,'Stepvalue','mxArray');
    schema.prop(this,'CountToValue','mxArray');
    schema.prop(this,'Outputdatatype','mxArray');
    schema.prop(this,'Wordlength','mxArray');
    schema.prop(this,'Fractionlength','mxArray');
    schema.prop(this,'Sampletime','mxArray');
