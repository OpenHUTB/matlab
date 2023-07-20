function schema






    pkg=findpackage('RptgenML');

    clsH=schema.class(pkg,...
    'StylesheetAttribute',...
    pkg.findclass('StylesheetElementID'));


    m=schema.method(clsH,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};
