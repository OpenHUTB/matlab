


function out=getView(obj,studio)

    studioT=studio.getStudioTag;
    if isempty(obj.fViews)

        vw=slci.view.Studio(studio);
        obj.fViews(studioT)=vw;
        out=vw;
    else
        if~isKey(obj.fViews,studioT)

            vw=slci.view.Studio(studio);
            obj.fViews(studioT)=vw;
        end

        out=obj.fViews(studioT);
    end