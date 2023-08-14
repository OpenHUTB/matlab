function[fromNormFcn,fromPropFcn]=getPluginMappingRules(param)





    switch param.Law
    case 'lin'
        fromNormFcn=@(x)fromNormPow(x,1,param.Min,param.Max);
        fromPropFcn=@(x)fromPropPow(x,1,param.Min,param.Max);
    case 'log'
        fromNormFcn=@(x)fromNormLog(x,param.Min,param.Max);
        fromPropFcn=@(x)fromPropLog(x,param.Min,param.Max);
    case 'pow'
        fromNormFcn=@(x)fromNormPow(x,param.Pow,param.Min,param.Max);
        fromPropFcn=@(x)fromPropPow(x,param.Pow,param.Min,param.Max);
    case 'fader'
        fromNormFcn=@(x)fromNormPow(x,3,param.Min,param.Max);
        fromPropFcn=@(x)fromPropPow(x,3,param.Min,param.Max);
    case 'int'
        fromNormFcn=@(x)fromNormInt(x,param.Min,param.Max);
        fromPropFcn=@(x)fromPropInt(x,param.Min,param.Max);
    case 'enum'
        nenums=size(param.Enums,1);
        fromNormFcn=@(x)fromNormEnum(x,param.Enums,nenums);
        fromPropFcn=@(x)fromPropEnum(x,param.Enums,nenums);
    case 'logical'
        fromNormFcn=@(x)fromNormLogical(x);
        fromPropFcn=@(x)fromPropLogical(x);
    case 'enumclass'
        nenums=size(param.Enums,1);
        enums=enumeration(param.DefaultValue);
        fromNormFcn=@(x)fromNormEnumClass(x,enums,nenums);
        fromPropFcn=@(x)fromPropEnumClass(x,enums,nenums);
    otherwise
        fromNormFcn=@(x)(x);
        fromPropFcn=@(x)(x);
    end

end