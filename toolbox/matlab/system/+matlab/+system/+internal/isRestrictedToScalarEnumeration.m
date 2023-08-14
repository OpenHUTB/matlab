function flag=isRestrictedToScalarEnumeration(metaProp)


    validation=metaProp.Validation;
    flag=~isempty(validation);

    if~flag
        return;
    end

    metaClass=metaProp.Validation.Class;
    flag=~isempty(metaClass);

    if~flag
        return;
    end

    flag=metaClass.Enumeration;

    if~flag
        return;
    end

    sizeSpec=validation.Size;
    flag=numel(sizeSpec)==2;

    if~flag
        return;
    end

    flag=strcmp(class(sizeSpec),'meta.FixedDimension');

    if~flag
        return;
    end

    flag=(sizeSpec(1).Length==1)&&(sizeSpec(2).Length==1);
end
