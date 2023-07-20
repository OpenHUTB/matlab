function result=isComponentTransformer(componentPath)





    result=ee.internal.mask.isComponentTransformer2Winding(componentPath)||ee.internal.mask.isComponentTransformer3Winding(componentPath);
end
