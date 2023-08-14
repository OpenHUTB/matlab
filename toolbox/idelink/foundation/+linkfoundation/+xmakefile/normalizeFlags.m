function nflags=normalizeFlags(flags)



    nflags='';
    if(isempty(flags))
        return;
    end
    tokens=textscan(flags,'%s','MultipleDelimsAsOne',1);
    entries=tokens{1,1};
    for index=1:length(entries)
        nflags=sprintf('%s %s',nflags,entries{index});
    end
    nflags=strtrim(nflags);

end
