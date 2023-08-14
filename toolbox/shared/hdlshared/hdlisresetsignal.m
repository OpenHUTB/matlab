function result=hdlisresetsignal(idx)


    if hdlispirbased
        result=false;
        clkresetsigs=hdlresetsignals;
        for ii=1:length(clkresetsigs)
            if strcmp(idx.RefNum,clkresetsigs(ii).RefNum)
                result=true;
                return;
            end
        end
    else
        result=ismember(idx,hdlresetsignals);
    end
end
