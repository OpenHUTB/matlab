function[propFilter,filteredProps]=createClassPropertyFilter(mxClassInfo)




    props=mxClassInfo.ClassProperties;
    definedIns={props.ClassDefinedIn};
    filterables=false(size(mxClassInfo.ClassProperties));
    filterables(strcmp(definedIns,'ref')|strcmp(definedIns,'coder.internal.ref'))=true;
    propNames={props(filterables).PropertyName};
    filterables(filterables)=strcmp(propNames,'matlabCodegenUserReadableName')|strcmp(propNames,'contents');
    propFilter=~filterables;
    filteredProps=mxClassInfo.ClassProperties(propFilter);
end