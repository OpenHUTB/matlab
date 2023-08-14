function rtn=processCouplingWithPattern(obj,Lobe)
    az=obj.OptimStruct.Angles(1,:);
    el=obj.OptimStruct.Angles(2,:);
    switch Lobe
    case 'Main'
        if obj.OptimStruct.EnableCoupling
            rtn=pattern(obj,obj.OptimStruct.CenterFrequency,az(1),el(1));
        else
            rtn=patternMultiply(obj,obj.OptimStruct.CenterFrequency,az(1),el(1));
        end
    case 'Back'
        if obj.OptimStruct.EnableCoupling
            rtn=pattern(obj,obj.OptimStruct.CenterFrequency,az(2),el(2));
        else
            rtn=patternMultiply(obj,obj.OptimStruct.CenterFrequency,az(2),el(2));
        end
    otherwise
        if obj.OptimStruct.EnableCoupling
            rtn=pattern(obj,obj.OptimStruct.CenterFrequency);
        else
            rtn=patternMultiply(obj,obj.OptimStruct.CenterFrequency);
        end
    end
end