function out=getPLCKeywords(model)









    targetIDE='';
    if nargin>0&&~isempty(model)
        plcOptions=plcprivate('plc_options',model);
        targetIDE=plcOptions.TargetIDE;
    end

    out=plcprivate('plc_keyword_list');

    if any(strcmp(targetIDE,{'tiaportal','tiaportal_double'}))
        out=plcprivate('plc_tia_portal_keyword_list',out);
    end


