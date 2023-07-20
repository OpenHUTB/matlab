function[enumStrings,enumValues]=getUniqueListOfEnumNamesAndValues(metaClass)






    assert(Simulink.data.isSupportedEnumClass(metaClass));

    className=metaClass.Name;
    [enumVals,enumNames]=enumeration(className);
    dblVals=double(enumVals);

    enumStrAndVal={};


    for idx=1:length(enumNames)
        thisEnumString=enumNames{idx};
        thisEnumValue=dblVals(idx);



        if(isempty(enumStrAndVal)||...
            ~any(([enumStrAndVal{:,2}]==thisEnumValue)))
            enumStrAndVal{end+1,1}=thisEnumString;%#ok
            enumStrAndVal{end,2}=thisEnumValue;
        end
    end


    enumStrAndVal=sortrows(enumStrAndVal,2);

    enumStrings=enumStrAndVal(:,1);
    enumValues=cell2mat(enumStrAndVal(:,2));


