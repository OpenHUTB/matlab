function h=DependencyProp(parentClass,name,type,initialStatus,varargin)






    h=RTWConfiguration.DependencyProp(parentClass,name,type);


    if(length(varargin)==1)

        h.ActivateValue=varargin{1};
    else


        enumx=findtype(type);
        if(isempty(enumx))
            TargetCommon.ProductInfo.error('resourceConfiguration','MissingActivationValue',type);
        end;
        h.ActivateValue=enumx.Strings{1};
    end;


    switch initialStatus
    case 'initiallyActive'

        h.FactoryValue=h.ActivateValue;
    case 'initiallyInactive'

        h.FactoryValue=RTWConfiguration.deactivatedString;
    otherwise
        TargetCommon.ProductInfo.error('common','UnsupportedAction',['initial status: ',initialStatus]);
    end;
