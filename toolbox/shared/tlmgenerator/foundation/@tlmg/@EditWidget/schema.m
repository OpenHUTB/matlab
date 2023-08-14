function schema()





    hCreateInPackage=findpackage('tlmg');


    c=schema.class(hCreateInPackage,'EditWidget');


    add_prop(c,'propName','string','','on','off');
    add_prop(c,'labelW','mxArray','','on','off');
    add_prop(c,'editW','mxArray','','on','off');

    p=add_prop(c,'Visible','bool',true,'on','on');
    p.SetFunction=@setVis;
    p=add_prop(c,'Enabled','bool',true,'on','on');
    p.SetFunction=@setEn;
    p=add_prop(c,'DialogRefresh','bool',false,'on','on');
    p.SetFunction=@setDialogRefresh;


    m=schema.method(c,'addCallback');
    s=m.Signature;
    s.varargin='off';

    s.InputTypes={'handle','string','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'getWidgetStructs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'setPropOnWidgets');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'getWidgetTags','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

end


function p=add_prop(c,name,type,defval,varargin)
    p=schema.prop(c,name,type);
    p.FactoryValue=defval;
    if(nargin==5)
        p.Visible=varargin{1};
    end
    if(nargin==6)
        p.AccessFlags.PublicSet=varargin{2};
    end
end

function val=setVis(h,val)
    h.setPropOnWidgets('Visible',val);
end

function val=setEn(h,val)
    h.setPropOnWidgets('Enabled',val);
end

function val=setDialogRefresh(h,val)
    h.setPropOnWidgets('DialogRefresh',val);
end


