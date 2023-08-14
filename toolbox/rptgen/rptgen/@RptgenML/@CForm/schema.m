function schema




    pkg=findpackage('rptgen');
    pkgRG=findpackage('RptgenML');


    h=schema.class(pkgRG,'CForm',pkg.findclass('cform_outline'));


    rptgen.prop(h,'WarnOnSaveFileName','ustring','','',2);


    rptgen.makeStaticMethods(h,{
    },{
'getDisplayLabel'
'copyReport'
'getDOMFormats'
'getHoleIds'
    });

    m=find(h.Method,'Name','getDisplayIcon');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle'};
        s.OutputTypes={'string'};
    end


