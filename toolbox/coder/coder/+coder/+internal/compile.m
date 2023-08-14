function report=compile(compilationContext,buildInfo,buildConfig)




    report=compilationContext.Project.compile(buildInfo,compilationContext.CRLControl,compilationContext.ConfigInfo,buildConfig);
