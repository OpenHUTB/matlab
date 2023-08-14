function propertyNames=getStereotypeProperties(this)






    stereotypes=this.getPrototypable.getPrototype;
    totalProps=0;

    allStereotypes=[];

    for i=1:numel(stereotypes)
        stereotype=stereotypes(i);
        while~isempty(stereotype)


            allStereotypes=[allStereotypes,stereotype];%#ok<*AGROW>
            propArray=stereotype.propertySet.properties.toArray;
            totalProps=totalProps+numel(propArray);
            stereotype=stereotype.parent;
        end
    end

    propertyNames=string.empty(0,totalProps);
    cnt=1;
    for i=1:numel(allStereotypes)
        stereotype=allStereotypes(i);
        prop=stereotype.propertySet.properties.toArray;
        for n=1:numel(prop)
            propertyNames(cnt)=prop(n).fullyQualifiedName;
            cnt=cnt+1;
        end
    end

end
