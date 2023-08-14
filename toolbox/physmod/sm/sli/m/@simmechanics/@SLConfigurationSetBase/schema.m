function schema




    pkg=findpackage('simmechanics');


    parentpkg=findpackage('Simulink');
    parentcls=findclass(parentpkg,'CustomCC');
    cls=schema.class(pkg,'SLConfigurationSetBase',parentcls);


    m=schema.method(cls,'attachSubComponents');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
    };















