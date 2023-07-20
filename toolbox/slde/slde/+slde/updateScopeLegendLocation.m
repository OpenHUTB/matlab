function updateScopeLegendLocation(blkPath,location)




    s=get_param(blkPath,'ScopeSpecificationObject');
    if~isempty(s)&&isLaunched(s)
        hScope=getUnifiedScope(s);
        hLegend=findall(hScope.Parent,'tag','legend');
        if ischar(location)
            hLegend.Location=location;
        else
            oldPos=getpixelposition(hLegend);
            oldPos(1:2)=location;
            setpixelposition(hLegend,oldPos);
        end
    end


