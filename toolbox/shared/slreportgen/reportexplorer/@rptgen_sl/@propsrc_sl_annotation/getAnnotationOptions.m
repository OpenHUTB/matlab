function opt=getAnnotationOptions(this,propName)




    opt=struct('isDOM',false,'format','','interpreter','',...
    'dName','','propName',propName);
    opt.isDOM=false;
    adRG=rptgen.appdata_rg;
    rpt=adRG.RootComponent;
    if~isempty(rpt)
        opt.format=rpt.Format;
        opt.isDOM=...
        (~isempty(regexp(rpt.Format,'dom-','ONCE'))||...
        strcmp(rpt.Format,'db'));
    end





    if~opt.isDOM||(opt.isDOM&&this.isParentParagraph)
        opt.propName='PlainText';
    end

end

