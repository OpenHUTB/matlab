function result=modelref_HWTargetParams(csTop,csChild,varargin)
















    param=varargin{1};

    topProdEqTarget=get_param(csTop,'ProdEqTarget');
    childProdEqTarget=get_param(csChild,'ProdEqTarget');

    result=false;



    if(strcmp(topProdEqTarget,'off')&&strcmp(childProdEqTarget,'off'))

        pTop=configset.getParameterInfo(csTop,param);
        pChild=configset.getParameterInfo(csChild,param);

        if(pTop.IsReadable&&pChild.IsReadable)||strcmp(param,'TargetUnknown')



            topParam=get_param(csTop,param);
            childParam=get_param(csChild,param);


            if strcmp(param,'TargetHWDeviceType')
                result=~target.internal.isHWDeviceTypeEq(topParam,childParam);
            else
                result=~isequal(topParam,childParam);
            end
        end
    end
end
