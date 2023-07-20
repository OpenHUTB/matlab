function createDynamicEnum(~,className,labels,vals,baseClass)






    if strcmp(baseClass,'uint32')
        baseClass='int32';
    end

    Simulink.defineIntEnumType(className,labels,double(vals),'StorageType',baseClass,'DynamicallyCreatedBy','sllogging');
end
