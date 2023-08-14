function result=isStoredIntProperty(propName)
    result=((slfeature('EnableStoredIntMinMax')>0)&&...
    (strcmp(propName,'StoredIntMin')||strcmp(propName,'StoredIntMax')));
end