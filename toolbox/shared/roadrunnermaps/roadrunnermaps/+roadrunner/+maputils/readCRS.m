function crs=readCRS(rrMap)







    projectionString=rrMap.getProjectionString();
    hasCRS=~isempty(projectionString);
    if(hasCRS)
        [wkt,crsinfo]=map.internal.crs.getCRS(projectionString);
        if startsWith(wkt,"BOUNDCRS")

            wkt=extractBetween(string(wkt),...
            "SOURCECRS["+whitespacePattern,...
            ","+whitespacePattern+"TARGETCRS[");
        end
        if startsWith(wkt,"COMPOUNDCRS")

            if crsinfo.IsProjected
                str="PROJCRS["+extractBetween(string(wkt),...
                "PROJCRS[",","+whitespacePattern+"VERTCRS[");
                if isempty(str)
                    wkt="PROJCRS["+extractBetween(string(wkt),...
                    "PROJCRS[",","+whitespacePattern+"BOUNDCRS[");
                else
                    wkt=str;
                end
            else
                wkt="GEOGCRS["+extractBetween(string(wkt),...
                "GEOGCRS[",","+whitespacePattern+"VERTCRS[");
            end
        end



        if crsinfo.IsGeographic
            crs=geocrs(wkt);
        elseif crsinfo.IsProjected
            crs=projcrs(wkt);
        else
            error(message('roadrunnermaps:hdmap:noCRSDataInMap'));
        end
    else
        error(message('roadrunnermaps:hdmap:noCRSDataInMap'));
    end
end