function result=isComponentTransformer2Winding(componentPath)







    result=any(strcmp(componentPath,...
    {'ee.passive.transformers.two_winding_transformer.abc',...
    'ee.passive.transformers.two_winding_transformer.Xabc',...
    }));
end
