function schema




    mlock;

    pkg=findpackage('RptgenML');

    clsH=schema.class(pkg,...
    'DOMDOCXTemplateEditor',...
    pkg.findclass('DB2DOMTemplateEditor'));

    p=rptgen.prop(clsH,'TemplateCopyPath','string','');
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='on';
    p.Visible='off';


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