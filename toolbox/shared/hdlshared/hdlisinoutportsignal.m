function result=hdlisinoutportsignal(idx)


    result=false;
    if hdlispirbased
        if hdlisinportsignal(idx)
            pirPort=idx.getDrivers;
            result=pirPort.getBidirectional;
        else
            pirPort=idx.getReceivers;
            result=pirPort.getBidirectional;
        end
    end
