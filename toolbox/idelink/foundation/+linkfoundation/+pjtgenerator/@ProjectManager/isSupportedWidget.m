function ret=isSupportedWidget(h,Tag,AdaptorName)





    if isempty(AdaptorName)
        ret=false;
        return;
    end


    ret=true;

    Widgets=h.mAdaptorRegistry.getWidgetCustomizations(AdaptorName);
    WidgetNames=fieldnames(Widgets);

    for i=1:length(WidgetNames)
        if~isempty(strmatch(Tag,WidgetNames(i),'exact'))
            ret=false;
        end
    end
