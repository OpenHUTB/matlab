function extents=getColorAlphaDataExtents(hObj)




    extents=nan(2,4);

    useColorOrder=strcmp(hObj.CDataMode,'auto')&&...
    ~hObj.isDataComingFromDataSource('Color')&&hObj.SeriesIndex~=0;

    if strcmp(hObj.CLimInclude,'on')&&~useColorOrder
        c=hObj.CDataCache;
        if~isempty(c)&&~istruecolor(c)
            k=find(isfinite(c));
            extents=[matlab.graphics.chart.primitive.utilities.arraytolimits(c(k));NaN,NaN,NaN,NaN];
        end
    end

    if strcmp(hObj.MarkerFaceAlpha,'flat')||strcmp(hObj.MarkerEdgeAlpha,'flat')
        a=hObj.AlphaDataCache;
        k=isfinite(a);
        extents(2,:)=matlab.graphics.chart.primitive.utilities.arraytolimits(a(k));
    end

    if all(isnan(extents),'all')
        extents=[];
    end
end

function out=istruecolor(c)
    out=false;
    if size(c,1)==1
        if size(c,2)==3

            out=true;
        end
    else
        if size(c,2)~=1
            out=true;
        end
    end
end
