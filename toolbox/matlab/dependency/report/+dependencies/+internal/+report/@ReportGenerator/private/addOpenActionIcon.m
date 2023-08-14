function annotatedElement=addOpenActionIcon(element,url,name)




    link=mlreportgen.dom.ExternalLink(url,"");
    iconPath=getIconFile(matlab.ui.internal.toolstrip.Icon.EXPORT_16);
    image=mlreportgen.dom.Image(iconPath);
    link.append(image);

    tooltip=getResource("MatlabLinkTooltip",name);
    link.CustomAttributes={...
    mlreportgen.dom.CustomAttribute("class","matlab_link")...
    ,mlreportgen.dom.CustomAttribute("title",tooltip)};
    link.Style={...
    mlreportgen.dom.CSSProperties(...
    mlreportgen.dom.CSSProperty('display','none'))};
    annotatedElement=mlreportgen.dom.Table({element,link});
    annotatedElement.TableEntriesVAlign="middle";
    annotatedElement.TableEntriesStyle={...
    mlreportgen.dom.InnerMargin("0px","10px")};
end
