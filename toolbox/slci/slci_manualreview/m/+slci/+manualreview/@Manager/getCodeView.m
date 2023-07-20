


function out=getCodeView(obj,studio)

    studioT=studio.getStudioTag;
    if~isKey(obj.fCodeViews,studioT)

        mr=slci.manualreview.CodeView(studio);
        obj.fCodeViews(studioT)=mr;
    end

    out=obj.fCodeViews(studioT);
end