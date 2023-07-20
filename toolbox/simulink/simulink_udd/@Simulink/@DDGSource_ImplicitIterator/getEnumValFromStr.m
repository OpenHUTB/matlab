function enumVal=getEnumValFromStr(this,enumStr,lstEnumStrs)




    enumVal=-1;
    for i=1:length(lstEnumStrs)
        if strcmp(enumStr,lstEnumStrs{i})
            enumVal=i-1;
            break;
        end
    end

end
