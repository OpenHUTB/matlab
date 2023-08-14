function out=isStartupVariantCoverageSupported()




    out=slfeature('StartupVariants')>0&&...
    slfeature('SlCovStartupVariantSupport')>0;
end
