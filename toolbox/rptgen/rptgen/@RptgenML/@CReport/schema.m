function schema




    pkg=findpackage('rptgen');
    pkgRG=findpackage('RptgenML');

    h=schema.class(pkgRG,'CReport',...
    pkg.findclass('coutline'));

    p=rptgen.prop(h,'WarnOnSaveFileName','ustring','',...
    '',2);



    rptgen.makeStaticMethods(h,{
    },{
'getDisplayLabel'
'copyReport'
    });












    m=find(h.Method,'Name','getDisplayIcon');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle'};
        s.OutputTypes={'string'};
    end


