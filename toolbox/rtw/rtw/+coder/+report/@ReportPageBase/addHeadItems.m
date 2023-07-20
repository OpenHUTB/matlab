function addHeadItems(rpt)




    meta=rpt.getMetaTag;
    if~isempty(meta)
        rpt.Doc.addHeadItem(meta);
    end
    css=rpt.getStyleSheet;
    if~isempty(css)
        [folder,filename,ext]=fileparts(css);
        rpt.copyResource([filename,ext],folder);
        rpt.Doc.addHeadItem(['<link rel="stylesheet" type="text/css" href="',filename,ext,'" />']);
    end
    if~isempty(rpt.JavaScriptLib)
        if~iscell(rpt.JavaScriptLib)
            jsLib={rpt.JavaScriptLib};
        else
            jsLib=rpt.JavaScriptLib;
        end
        for i=1:length(jsLib)
            [folder,filename,ext]=fileparts(jsLib{i});
            rpt.copyResource([filename,ext],folder);
            rpt.Doc.addHeadItem(['<script language="JavaScript" ','type="text/javascript" src="',filename,ext,'"></script>',newline]);
        end
    end
    if~isempty(rpt.JavaScriptHead)
        rpt.Doc.addHeadItem(sprintf('<script language="JavaScript" type="text/javascript" ><!--\n%s//-->\n</script>\n',rpt.JavaScriptHead));
    end
    if~isempty(rpt.JavaScriptBody)
        rpt.Doc.setBodyAttribute('onload',rpt.JavaScriptBody);
    end
end


