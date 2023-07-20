function schema





    mlock;

    pkg=findpackage('NetworkEngine');
    c=schema.class(pkg,'SystemScaling');

    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(c,'nominalPostSet','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'isNominalValueViewerEnabled','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(c,'openNominalViewer','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={};
end

