function value=getAsMxArray(this)

    if isempty(this.cachedValue)
        if(isa(this.usage.initialValue.type,'systemcomposer.property.Enumeration'))
            value=jsondecode(this.value);
            value=eval(this.usage.initialValue.type.MATLABEnumName+"('"+value+"')");
        elseif(isa(this.usage.initialValue.type,'systemcomposer.property.FloatType')||...
            isa(this.usage.initialValue.type,'systemcomposer.property.IntegerType'))
            baseType=this.usage.propertyDef.getBaseType;
            value=feval(baseType,jsondecode(this.value));
        else
            value=jsondecode(this.value);
        end
        this.cachedValue=value;
    else
        value=this.cachedValue;
    end

