function schema





    pkg=findpackage('cv');

    clsH=schema.class(pkg,...
    'CustomCov');



    p=schema.prop(clsH,'m_modelH','mxArray');
    p.Visible='off';

    p=schema.prop(clsH,'m_handles','mxArray');
    p.Visible='off';

    p=schema.prop(clsH,'m_handlesForReport','mxArray');
    p.Visible='off';

    p=schema.prop(clsH,'m_blkTypeName','string');
    p.Visible='off';

    p=schema.prop(clsH,'m_isCoverage','bool');
    p.Visible='off';

    p=schema.prop(clsH,'m_isCompileForCoverage','bool');
    p.Visible='off';

    p=schema.prop(clsH,'m_isAssert','bool');
    p.Visible='off';



    m=schema.method(clsH,'getText');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};



    m=schema.method(clsH,'getMetricId');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};




    m=schema.method(clsH,'evalDec');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};



    m=schema.method(clsH,'evalAssert');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};



    m=schema.method(clsH,'create','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray'};

