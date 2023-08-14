function result=hdlisoutportsignal(idx)


    if hdlispirbased


        result=idx.isNetworkOutput;
    else
        result=ismember(idx,hdloutportsignals);
    end
end
