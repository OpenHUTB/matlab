function result=hdlisclocksignal(idx)


    if hdlispirbased
        result=false;
        clksigs=hdlclocksignals;
        for ii=1:length(clksigs)
            if strcmp(idx.RefNum,clksigs(ii).RefNum)
                result=true;
                return;
            end
        end
    else
        result=ismember(idx,hdlclocksignals);
    end
end
