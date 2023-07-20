













function dlcodegenOptionsCallback=getDeepLearningCodegenOptionsCallback(ctx)

    if~isempty(ctx)
        dlcodegenOptionsCallback=ctx.getConfigProp('DeepLearningCustomCallback');
    else



        dlcodegenOptionsCallback='';
    end

end

