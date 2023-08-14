function returnHighlightState(cachedHilight)



    if~iscell(cachedHilight)&&~isempty(cachedHilight)
        tmpCell=cell(1,length(cachedHilight));
        for kCache=1:length(cachedHilight)
            tmpCell{kCache}=cachedHilight(kCache);
        end
        cachedHilight=tmpCell;
    end

    for k=1:length(cachedHilight)


        try



            hilite_system(get_param(cachedHilight{k}.sid,'Handle'),...
            cachedHilight{k}.hilite);

        catch



        end
    end
