function entry=getEntry(obj)



    entry=[];
    if isa(obj.DD,'coderdictionary.softwareplatform.FunctionPlatform')
        entryRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(obj.DD.getOwner,obj.DD.Name,obj.EntryType,obj.EntryName);
        if~entryRef.isEmpty
            entry=entryRef.getCoderDataEntry;
        end
    else
        entry=loc_getEntryFromNativePlatform(obj);
    end
end

function entry=loc_getEntryFromNativePlatform(obj)
    try
        data=coder.internal.CoderDataStaticAPI.get(obj.DD,obj.EntryType);
    catch me
        if strcmp(me.identifier,'SLDD:sldd:DictionaryNotFound')
            entry=[];
            return;
        end
        rethrow(me);
    end
    name=obj.EntryName;
    entry=coder.internal.CoderDataStaticAPI.getByName(obj.DD,obj.EntryType,name);
    if isempty(entry)
        switch obj.EntryType
        case 'StorageClass'
            entry=coderdictionary.data.StorageClass.empty;
        case 'MemorySection'
            entry=coderdictionary.data.MemorySection.empty;
        case 'FunctionClass'
            entry=coderdictionary.data.FunctionClass.empty;
        otherwise
            entry=coderdictionary.data.StorageClass.empty;
        end
    end
end


