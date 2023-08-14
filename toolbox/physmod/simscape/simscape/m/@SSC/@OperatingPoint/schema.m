function schema







    mlock;

    pkg=findpackage('SSC');
    c=schema.class(pkg,'OperatingPoint');

    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(c,'isOpNameEnabled','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'bool'};

end

