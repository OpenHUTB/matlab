function bss=extractBlockSupportSettingsFromPref(list)




    bss=lutdesigner.config.internal.createBlockSupportSetting([0,1]);

    if isempty(list)
        return;
    end

    m=createExistenceCheckMap();
    listArray=list.entrySet.toArray;
    for idx=1:size(listArray)
        customKey=listArray(idx).getKey;
        if~m.isKey(customKey)
            customEntry=listArray(idx).getValue;
            if~isempty(customEntry)
                bss(end+1,1)=createSettingFromPrefEntry(customKey,customEntry);%#ok
                m(customKey)=true;
            end
        end
    end
end

function m=createExistenceCheckMap()

    keysReservedForBuiltInBlocks={
'SubSystem///Repeating Sequence Interpolated'
'S-Function///LookupIdxSearch'
'S-Function///Fixed-Point Look-Up Table Dynamic'
'SubSystem///Repeating table'
'S-Function///S-function: sfun_directlook'
'Lookup_n-D///Curve'
'Lookup_n-D///Map'
'S-Function///S-function: sftable2'
'S-Function///LookupNDInterp'
'Lookup_n-D///'
'Interpolation_n-D///'
'Lookup2D///'
'S-Function///LookupNDInterpIdx'
'Lookup///'
'LookupNDDirect///'
'Interpolation_n-D///Map Using Prelookup'
'SubSystem///Lookup Table (2-D)'
'PreLookup///'
'PreLookup///Prelookup'
'Interpolation_n-D///Curve Using Prelookup'
    };
    m=containers.Map(keysReservedForBuiltInBlocks,true(size(keysReservedForBuiltInBlocks)));
end

function bss=createSettingFromPrefEntry(customKey,customEntry)

    customType=split(customKey,'///');

    numDims="";
    if(isa(customEntry(2),'java.lang.String[]'))
        numDims=string(customEntry(2));
    end

    axes={};
    if(isa(customEntry(1),'java.lang.String[]'))
        axes=string(customEntry(1));
    end

    table="";
    if(isa(customEntry(10),'java.lang.String[]'))
        table=string(customEntry(10));
    end

    bss=lutdesigner.config.internal.createBlockSupportSetting(customType{1},customType{2},numDims,table,axes);
end
