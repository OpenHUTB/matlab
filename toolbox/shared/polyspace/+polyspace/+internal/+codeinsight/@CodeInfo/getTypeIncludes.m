function[typeIncludes,typeWithNoInclude]=getTypeIncludes(typelist)





    typeIncludes=string([]);
    typeWithNoInclude=internal.cxxfe.ast.types.Type.empty;
    seenTypesUUID=string.empty;

    function extractTypeIncludes(aType)

        currType=internal.cxxfe.ast.types.Type.skipQualifiers(aType);


        if currType.isPointerType()||currType.isArrayType()
            extractTypeIncludes(currType.Type);
            return;
        end

        if ismember(currType.UUID,seenTypesUUID)
            return;
        end
        seenTypesUUID(end+1)=currType.UUID;


        if~isempty(currType.DefPos)
            if~isempty(currType.DefPos.File)&&currType.DefPos.File.IsInclude
                headerName=string(currType.DefPos.File.WrittenName);
                if~ismember(headerName,typeIncludes)
                    typeIncludes(end+1)=headerName;
                end
            else



                typeWithNoInclude(end+1)=currType;
            end
        end

    end

    if~isempty(typelist)
        for t=typelist
            extractTypeIncludes(internal.cxxfe.ast.types.Type.skipQualifiers(t));
        end
    end

end


