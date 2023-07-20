function refreshGroupAnnotation(blockH)










    iconcmd=get_param(blockH,'MaskDisplay');
    annotationOn=strfind(iconcmd,'text');

    if~isempty(annotationOn)
        set_param(blockH,'MaskDisplay',iconcmd);
    end


