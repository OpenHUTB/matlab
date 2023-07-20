function schema




    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    c=schema.class(pkg,'csl_cfgset',pkgRG.findclass('rpt_var_display'));

    m=schema.method(c,'msg','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring'};
    s.OutputTypes={'ustring'};

    rptgen.makeStaticMethods(c,{
    },{
'vdGetDialogSchema'
'getDisplayName'
'getDisplayValue'
    });

