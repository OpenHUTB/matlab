function resetToolTip(p)

    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        p.hToolTip.String='';
    end
