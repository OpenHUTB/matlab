classdef(Abstract,Hidden)StereotypableElement<handle





    properties(Access=protected,Hidden)
DynamicProperties
    end

    methods(Hidden)
        value=getCustomPropertyValue(this,propObj);
        setCustomPropertyValue(this,propObj,value);
        removePrototype(this);
        addPrototype(this);
        addPrototypeProperties(this,protoName,propName);
        propUsage=getPropertyUsage(this,propSetName,propName);
        removePrototypeProperties(this,protoName,propName);
        updatePrototypePropertyName(this,protoName,oldPropName,newPropName);
        updatePrototypeName(this,oldName,newName);
        tf=isPropertyValueDefault(this,qualifiedPropName);
        elem=getPrototypable(this);
    end

    methods(Access=protected,Hidden)
        propObj=getPropertyImpl(this,protoName,propName);
        addDynamicProperties(this,ElementImpl);
        removeDynamicProperties(this,ElementImpl);
        updatedFQN=getPropertyFQN(this,qualifiedPropName);
        val=castValueToCorrectDataType(this,typeImpl,strValue);
    end

    methods
        applyStereotype(this,prototypeName);
        removeStereotype(this,prototypeName);
        nameArray=getStereotypes(this);
        tf=hasStereotype(this,stereotypeNameOrObj)
        [propExpr,propUnits]=getProperty(this,qualifiedPropName);
        tf=hasProperty(this,qualifiedPropName);
        setProperty(this,qualifiedPropName,propExpr,propUnit);
        val=getPropertyValue(this,qualifiedPropName);
        val=getEvaluatedPropertyValue(this,qualifiedPropName);
        nameArray=getStereotypeProperties(this);
    end
end
