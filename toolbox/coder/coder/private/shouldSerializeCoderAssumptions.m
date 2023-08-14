function out=shouldSerializeCoderAssumptions(bldParams)




    out=isa(bldParams.configInfo,'coder.EmbeddedCodeConfig')||...
    (isa(bldParams.configInfo,'coder.CodeConfig')&&...
    isSILTestingOn(bldParams.project.FeatureControl));
end
