


function out=getManualReview(obj,studio)

    studioT=studio.getStudioTag;
    if~isKey(obj.fManualReviews,studioT)

        mr=slci.manualreview.ManualReview(studio);
        obj.fManualReviews(studioT)=mr;
    end

    out=obj.fManualReviews(studioT);
end