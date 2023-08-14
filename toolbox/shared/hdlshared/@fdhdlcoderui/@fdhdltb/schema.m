function schema







    mlock;

    pk=findpackage('hdlcoderui');
    parentcls=findclass(pk,'abstracthdltb');
    pk=findpackage('fdhdlcoderui');
    c=schema.class(pk,'fdhdltb',parentcls);

    if isempty(findtype('FracDelayStimulusStringType')),
        schema.EnumType('FracDelayStimulusStringType',{'Get value from filter','Ramp sweep','Random sweep','User defined'});
    end

    p=schema.prop(c,'TestBenchFracDelayStimulusString','FracDelayStimulusStringType');
    set(p,'Visible','off');

    p=schema.prop(c,'TestBenchFracDelay_User_Stimulus','ustring');
    set(p,'Visible','off');

    p=schema.prop(c,'TestbenchCoeffStimulus','ustring');
    set(p,'Visible','off');

    p=schema.prop(c,'ErrorMargin','ustring');
    set(p,'Visible','off');




    p=schema.prop(c,'Impulse','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'Step','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'Ramp','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'Chirp','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'Noise','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'UserDefined','bool');
    set(p,'FactoryValue',false,'Visible','off');

    p=schema.prop(c,'TestBenchUserStimulus','ustring');
    set(p,'Visible','off');


    if isempty(findtype('HDLTargetLanguageType'))
        schema.EnumType('HDLTargetLanguageType',{'VHDL','Verilog'});
    end

    p=schema.prop(c,'TestbenchLanguage','HDLTargetLanguageType');
    set(p,'Visible','off');

    p=schema.prop(c,'GenerateTestBench','bool');
    set(p,'FactoryValue',true,'Visible','off');

    p=schema.prop(c,'ActiveTab','int');
    set(p,'FactoryValue',0,'Visible','off');

    p=schema.prop(c,'TestbenchLanguage_bk','ustring');
    set(p,'FactoryValue','','Visible','off');






    m=schema.method(c,'getTabDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'help');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(c,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(c,'getparam');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};

    m=schema.method(c,'setobject');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array','handle'};
    s.OutputTypes={'bool','string'};


