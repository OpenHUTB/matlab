function checkRowMajor(modelName)




    if slfeature('RowMajorDimensionSupport')&&...
        (strcmp(get_param(modelName,'RowMajorDimensionSupport'),'on')||...
        strcmp(get_param(modelName,'ArrayLayout'),'Row-major'))
        DAStudio.error('PIL:pil:RowMajorERTSFunction',modelName);
    end


