function section=applyMargin(section,format)




    if upper(format)~="HTML-FILE"
        return
    end
    margin=mlreportgen.dom.OuterMargin("20px");
    for child=section.Children
        if isprop(child,"Style")
            child.Style{end+1}=margin;
        end
    end
end
