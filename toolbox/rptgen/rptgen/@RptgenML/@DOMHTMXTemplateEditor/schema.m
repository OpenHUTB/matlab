function schema




    mlock;

    pkg=findpackage('RptgenML');

    clsH=schema.class(pkg,...
    'DOMHTMXTemplateEditor',...
    pkg.findclass('DB2DOMTemplateEditor'));


    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'copyTemplate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(clsH,'moveTemplate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(clsH,'openEditor');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(clsH,'openStyleSheet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};