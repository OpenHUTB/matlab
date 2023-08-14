function obj=p_getDataTypeObj(argument,types)




    for ii=1:length(types)
        if argument.dims==1
            if strcmp(argument.datatype.Name,types(ii).Identifier)
                obj=types(ii);
                return;
            end
        else
            if isa(types(ii),'embedded.matrixtype')


                if(prod(argument.dims)==prod(types(ii).Dimensions))&&...
                    strcmp(argument.datatype.Name,types(ii).BaseType.Identifier)
                    obj=types(ii);
                    return;
                end
            end
        end
    end

    DAStudio.error('RTW:autosar:unknownCodeInfoDataType');
