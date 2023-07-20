function index=getLookupTableMemberSwappedIndex(axisCount,ii)





    if axisCount>1
        switch ii
        case 1
            index=2;
        case 2
            index=1;
        otherwise
            index=ii;
        end
    else
        index=ii;
    end
end

