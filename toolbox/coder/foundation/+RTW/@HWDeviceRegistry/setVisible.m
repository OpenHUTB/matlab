function setVisible(h,fields)











    if isnumeric(fields)
        h.Visible(fields)=true;
        return;
    end

    if ismember('all',fields)
        h.Visible=[true,true,true,true,true,true,true,true...
        ,true,true,true,true,true,true,true,true,true];
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
            h.Visible(idx)=true;
        else
            DAStudio.error('RTW:targetRegistry:badFieldName',...
            sprintf(' "%s"',fields{~memberIdx}),sprintf(' "%s"',allfields{:}));
        end
    end
