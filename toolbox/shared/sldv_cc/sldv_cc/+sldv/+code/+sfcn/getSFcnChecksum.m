function checksum=getSFcnChecksum(sfunction)








    checksum='';
    try
        checksum=evalin('base',sprintf('%s(''getSldvChecksum'')',sfunction));
    catch

    end
