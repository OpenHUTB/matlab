


function hiliteAnnotation(obj,codeLanguage,codeline)


    if strcmpi(codeLanguage,'c')
        obj.cv_c.highlightAnnotation(codeline);
    elseif strcmpi(codeLanguage,'hdl')
        obj.cv_hdl.highlightAnnotation(codeline);
    end

end