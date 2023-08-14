function schema




    parentpkg=findpackage('simmechanics');
    parentcls=findclass(parentpkg,'SLConfigurationSetBase');
    cls=schema.class(parentpkg,'ConfigurationSet',parentcls);

    m=schema.method(cls,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


