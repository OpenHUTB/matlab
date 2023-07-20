function[propExpr,propUnits]=getProperty(this,qualifiedPropName)









    narginchk(2,2);

    qualifiedPropName=this.getPropertyFQN(qualifiedPropName);

    try
        propVal=this.getPrototypable.getPropVal(qualifiedPropName);
        propExpr=propVal.expression;
        propUnits=propVal.units;
    catch me
        if strcmp(me.identifier,'SystemArchitecture:Property:PropertyNotFound')

            propExpr='';
            propUnits='';
        else
            throw(me);
        end
    end

end

