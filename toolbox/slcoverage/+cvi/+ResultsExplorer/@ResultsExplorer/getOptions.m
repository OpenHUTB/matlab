function[options,res]=getOptions(obj)




    try
        get_param(obj.modelToSyncOptions,'name');
    catch
        obj.modelToSyncOptions=obj.topModelName;
    end
    options=cvi.CvhtmlSettings(obj.modelToSyncOptions);
    res=false;
    chtmlOptions=get_param(obj.modelToSyncOptions,'CovHTMLOptions');

    if isempty(obj.htmlOptions)
        obj.htmlOptions=chtmlOptions;
    end
    if~compareHtmlOptions(obj,obj.htmlOptions,chtmlOptions)
        resetLastReportLinks(obj);
        obj.htmlOptions=chtmlOptions;
        res=true;
    end
end