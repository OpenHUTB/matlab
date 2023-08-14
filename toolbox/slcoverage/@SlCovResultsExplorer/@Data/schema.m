function schema





    pkg=findpackage('SlCovResultsExplorer');


    clsH=schema.class(pkg,...
    'Data',...
    pkg.findclass('ObjBase'));



    m=schema.method(clsH,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};


    m=schema.method(clsH,'getPropertyStyle');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={'mxArray'};