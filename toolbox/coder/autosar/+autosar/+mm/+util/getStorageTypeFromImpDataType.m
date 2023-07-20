function storageType=getStorageTypeFromImpDataType(classType,className,impM3iObj)















    if impM3iObj.IsApplication||...
        ~(isa(impM3iObj,'Simulink.metamodel.types.Integer')...
        ||isa(impM3iObj,'Simulink.metamodel.types.Enumeration'))
        DAStudio.error('autosarstandard:ui:validateImplDataTypeForEnumeration',className);
    end
    if isa(impM3iObj,'Simulink.metamodel.types.Integer')||...
        isa(impM3iObj,'Simulink.metamodel.types.Enumeration')
        if impM3iObj.IsSigned
            storageType='int';
        else
            storageType='uint';
        end




        storageSize=impM3iObj.Length.value;
        assert(storageSize>0,'Element %s has invalid storage size: %s',...
        autosar.api.Utils.getQualifiedName(impM3iObj),num2str(storageSize));
        if storageSize<=8
            storageSize=8;
        elseif storageSize<=16
            storageSize=16;
        elseif storageSize<=32
            storageSize=32;
        end

        storageType=[storageType,num2str(storageSize)];


        enumSupportedStorageTypes={'uint8','uint16','int8','int16','int32'};
        if~any(strcmp(storageType,enumSupportedStorageTypes))
            enumSupportedStorageTypesStr='uint8, uint16, int8, int16, int32';
            DAStudio.error('RTW:autosar:unsupportedStorageType',...
            impM3iObj.Name,classType,className,storageType,enumSupportedStorageTypesStr);
        end
    end
end



