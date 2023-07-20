function retVal=getDataTypeListForDataObjects(objType)




    persistent cache

    assert(ismember(objType,{'Parameter','Signal','StructElement','AliasType','LookupTable'}));


    if~isfield(cache,objType)






        cache.(objType)=[Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');
        {'fixdt(1,16,0)';'fixdt(1,16,2^0,0)';
        'Enum: <class name>';'Bus: <object name>'}];
        if ismember(objType,{'Parameter','Signal','LookupTable'})
            cache.(objType)=['auto';cache.(objType)];
        end
    end

    retVal=cache.(objType);

