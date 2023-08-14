function result=hdlisclockenablesignal(idx)


    if hdlispirbased
        result=false;
        clkensigs=hdlclockenablesignals;
        for ii=1:length(clkensigs)
            if strcmp(idx.RefNum,clkensigs(ii).RefNum)
                result=true;
                return;
            end
        end
    else
        result=ismember(idx,hdlclockenablesignals);
    end
end
