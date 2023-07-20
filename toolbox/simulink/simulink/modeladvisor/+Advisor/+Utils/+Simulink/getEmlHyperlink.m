function link=getEmlHyperlink(sid,text,iBegin,iEnd)










    if ischar(iBegin)
        iBegin=str2double(iBegin);
    end

    if ischar(iEnd)
        iEnd=str2double(iEnd);
    end

    tbl=ModelAdvisor.FormatTemplate('TableTemplate');
    link=tbl.formatEntry(sprintf('%s:%d-%d',sid,iBegin,iEnd));
    link.Content=text;
    link.ContentsContainHTML=false;
end