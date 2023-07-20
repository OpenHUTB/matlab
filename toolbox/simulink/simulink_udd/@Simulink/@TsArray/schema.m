function schema





    p=findpackage('Simulink');


    c=schema.class(p,'TsArray');


    schema.prop(c,'Name','string');


    schema.prop(c,'BlockPath','string');


    schema.prop(c,'PortIndex','MATLAB array');


    schema.prop(c,'IsBus','bool');


    p=schema.prop(c,'Members','MATLAB array');

    p.FactoryValue={};

    m=schema.method(c,'flatten');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle'};
    m.signature.outputTypes={'mxArray'};
