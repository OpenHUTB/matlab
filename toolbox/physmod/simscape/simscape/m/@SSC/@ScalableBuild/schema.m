function schema







    mlock;

    pkg=findpackage('SSC');
    c=schema.class(pkg,'ScalableBuild');

    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={};
    s.OutputTypes={'MATLAB array'};

end

