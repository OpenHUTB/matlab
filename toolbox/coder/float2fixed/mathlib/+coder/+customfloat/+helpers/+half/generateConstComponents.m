%#codegen















function obj=generateConstComponents(prec,const,component)
    coder.allowpcode('plain');

    [~,exp,mant]=coder.customfloat.helpers.extractComponentsFromUInt(prec,storedInteger(emlhalf(const)));
    if strcmp(component,'exponent')
        obj=exp;
    elseif strcmp(component,'mantissa')
        obj=mant;
    end
end