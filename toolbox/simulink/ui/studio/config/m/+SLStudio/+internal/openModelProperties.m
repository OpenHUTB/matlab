function openModelProperties(modelName)
    if~isempty(modelName)
        obj=get_param(modelName,'Object');
        tag=['_DDG_MP_',modelName,'_TAG_'];
        found=SLStudio.Utils.showDialogIfExists(tag);

        if~found
            DAStudio.Dialog(obj,tag,'DLG_STANDALONE');
        end
    end
end
