





function status=isRowMajorFeatureEnabled(modelH)


    status=slfeature('RowMajorDimensionSupport')>0;


    if nargin>0&&status
        status=get_param(bdroot(modelH),'RowMajorDimensionSupport')=="on"||...
        get_param(bdroot(modelH),'ArrayLayout')=="Row-major";
    end
