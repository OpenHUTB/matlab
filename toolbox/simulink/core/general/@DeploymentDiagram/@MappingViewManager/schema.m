function schema





    pk=findpackage('DeploymentDiagram');

    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'MEViewManager');

    cls=schema.class(pk,'MappingViewManager',hDeriveFromClass);


    m=schema.method(cls,'getHeaderLabels');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(cls,'getHeaderContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'handle'};


    m=schema.method(cls,'eventHandler');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'getHeaderOrder');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string vector'};
    s.OutputTypes={'string'};


