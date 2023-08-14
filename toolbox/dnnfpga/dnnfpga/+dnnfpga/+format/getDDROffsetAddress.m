function address=getDDROffsetAddress(ddrOffsetTable,label)
    sz=size(ddrOffsetTable);
    address={};
    for i=1:sz(1)
        entry=ddrOffsetTable(i,:);
        if strcmp(entry.offset_name,label)
            address=hex2dec(entry.offset_address);
            break;
        end
    end
end