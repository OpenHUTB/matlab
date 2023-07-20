function schema




    pkg=findpackage('rptgen_sl');

    h=schema.class(pkg,...
    'propsrc_sl_annotation',...
    pkg.findclass('propsrc_sl'));

    p=rptgen.prop(h,'isParentParagraph','bool',false);
    p.Visible='off';
