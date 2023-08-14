function htmlDom=createDOMForRichText(richText,isExternal,type)

    text=slreq.report.utils.strictHTML(richText,type,true);

    htmlDom=mlreportgen.dom.Container;


    if strcmpi(type,'pdf')
        if isExternal
            htmlDom.StyleName='SLReqReqDescriptionExValue';
        else
            htmlDom.StyleName='SLReqReqDescriptionInValue';
        end
    else
        htmlDom.StyleName='SLReqReqDescriptionValue';
    end
    append(htmlDom,text);
end