function ret=da_syntax(model,symbol,type,align,alignType)



    ret.syntax=' ';
    ret.err='';
    hc=get_param(model,'TargetFcnLibHandle');
    tc=hc.TargetCharacteristics;
    lang=lower(get_param(model,'TargetLang'));
    if length(lang)>3
        lang=lang(1:3);
    end
    try
        if~isempty(tc)
            ret.syntax=tc.getAlignmentSyntax(symbol,type,align,lang,alignType);
        else
            DAStudio.error('CoderFoundation:tfl:UnableToAlignVariable',symbol,align,alignType,lang);
        end
    catch e
        ret.err=e.message;
    end;
end
