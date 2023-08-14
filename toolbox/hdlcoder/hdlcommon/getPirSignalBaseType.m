function pirSignalBaseType=getPirSignalBaseType(pirSignalType)






    if pirSignalType.isRecordType






        numMembers=numel(pirSignalType.MemberTypesFlattened);



        pirSignalBaseType=getPirSignalBaseType(pirSignalType.MemberTypesFlattened(1));
        for ii=2:numMembers
            pirSignalBaseType_ii=getPirSignalBaseType(pirSignalType.MemberTypesFlattened(ii));
            if~pirSignalBaseType.isEqual(pirSignalBaseType_ii)


                pirSignalBaseType=[];
                break;
            end
        end
    elseif pirSignalType.isArrayType

        pirSignalBaseType=pirSignalType.BaseType;
    else

        pirSignalBaseType=pirSignalType;
    end
end