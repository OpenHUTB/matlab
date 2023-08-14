function[StrongStartTag,StrongEndTag]=createStrongTags









    if matlab.internal.display.isHot
        StrongStartTag='<strong>';
        StrongEndTag='</strong>';
    else
        StrongStartTag='';
        StrongEndTag='';
    end