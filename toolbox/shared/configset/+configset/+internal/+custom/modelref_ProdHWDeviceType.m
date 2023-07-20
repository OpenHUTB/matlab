function result=modelref_ProdHWDeviceType(csTop,csChild,varargin)














    topParam=get_param(csTop,'ProdHWDeviceType');
    childParam=get_param(csChild,'ProdHWDeviceType');

    result=~target.internal.isHWDeviceTypeEq(topParam,childParam);
end
