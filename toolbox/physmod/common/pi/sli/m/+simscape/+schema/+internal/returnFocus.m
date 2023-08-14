function returnFocus(hBlk,isStandalone)







    if~isStandalone
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        if~isempty(studios)
            studios(1).show();
        end
    else
        open_system(hBlk);
    end

end
