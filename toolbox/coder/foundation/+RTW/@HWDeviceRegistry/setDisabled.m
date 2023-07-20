function setDisabled(h,fields)











    if isnumeric(fields)
        h.Enabled(fields)=false;
        return;
    end

    if ismember('all',fields)
        h.Enabled=[false,false,false,false,false,false,false,false...
        ,false,false,false,false,false,false,false,false,false];
        return;
    else
        allfields={...
        'BitPerChar','BitPerShort',...
        'BitPerInt','BitPerLong',...
        'WordSize','Endianess',...
        'IntDivRoundTo','ShiftRightIntArith','LongLongMode',...
        'BitPerFloat','BitPerDouble','BitPerPointer',...
        'BitPerLongLong','LargestAtomicInteger','LargestAtomicFloat',...
        'BitPerSizeT','BitPerPtrDiffT',...
        };
        memberIdx=ismember(fields,allfields);
        if all(memberIdx)
            [matchfields,idy,idx]=intersect(fields,allfields);
            h.Enabled(idx)=false;
        else
            DAStudio.error('RTW:targetRegistry:badFieldName',...
            sprintf(' "%s"',fields{~memberIdx}),sprintf(' "%s"',allfields{:}));
        end
    end
