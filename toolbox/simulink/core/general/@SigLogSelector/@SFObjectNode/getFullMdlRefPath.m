function path=getFullMdlRefPath(this)







    subPath=this.Name;
    chart=this.hParent;
    while~isempty(chart)
        if isa(chart,'SigLogSelector.SFObjectNode')
            subPath=[chart.Name,'.',subPath];%#ok<AGROW>
            chart=chart.hParent;
        else
            break;
        end
    end


    path=chart.getFullMdlRefPath;
    path.SubPath=subPath;

end
