function result=isComponentTransformer3Winding(componentPath)







    result=any(strcmp(componentPath,...
    {'ee.passive.transformers.ZDY.abc',...
    'ee.passive.transformers.ZDY.Xabc',...
    'ee.passive.transformers.three_winding_transformer.abc',...
    'ee.passive.transformers.three_winding_transformer.Xabc',...
    }));
end
