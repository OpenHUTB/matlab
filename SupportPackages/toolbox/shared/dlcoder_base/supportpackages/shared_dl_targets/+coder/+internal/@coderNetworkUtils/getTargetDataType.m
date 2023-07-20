



function dataType=getTargetDataType(ctx)
    dlconfig=coder.internal.getDeepLearningConfig(ctx);
    if isprop(dlconfig,'DataType')
        dataType=dlconfig.DataType;
    else
        dataType='fp32';
    end
end
