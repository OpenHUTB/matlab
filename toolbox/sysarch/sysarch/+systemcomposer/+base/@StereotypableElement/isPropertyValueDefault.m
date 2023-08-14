function tf=isPropertyValueDefault(this,qualifiedPropName)





    narginchk(2,2);

    qualifiedPropName=this.getPropertyFQN(qualifiedPropName);

    tf=this.getPrototypable.isPropValDefault(qualifiedPropName);

end


