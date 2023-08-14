function result=hdlisinportsignal(idx)


    if hdlispirbased


        result=idx.isNetworkInput;
    else
        result=ismember(idx,hdlinportsignals);
    end
end
