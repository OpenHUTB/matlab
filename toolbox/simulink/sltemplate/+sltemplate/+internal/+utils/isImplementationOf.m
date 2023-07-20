function isImpl=isImplementationOf(className,interfaceName)







    classMeta=meta.class.fromName(className);

    isImpl=~classMeta.Abstract&&...
    any(strcmp(superclasses(className),interfaceName));

end