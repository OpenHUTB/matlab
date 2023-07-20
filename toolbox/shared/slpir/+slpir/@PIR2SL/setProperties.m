function setProperties(this,hC,slbh)

    if isempty(hC.getAllProperties)||(~hC.getRtwcgDraw()&&strcmp(this.SLEngineDebug,'off'))
        return;
    end
    str=strrep(hC.getAllProperties,char(10),' ');
    C=textscan(str,'%s','delimiter','#|');
    for i=1:2:length(C{1})
        t=C{1}{i};
        v=C{1}{i+1};
        if strcmp(t,'Name')||strcmp(t,'Type')
            continue;
        end

        if strcmp(t,'hasDSW')
            continue;
        end
        try
            tpv=get_param(slbh,t);
            if iscell(tpv)
                v={v};
            end
        catch
        end
        try
            set_param(slbh,t,v);
        catch
        end
    end
end