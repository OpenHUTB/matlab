


function guid=ModelChecksumToGUID(checksum)

    cs=sprintf('%x',checksum);

    cslong=repmat(cs,1,8);
    cs32=cslong(1:32);

    guid=[cs32(1:8),'-',cs32(9:12),'-',cs32(13:16),'-',cs32(17:20),'-',cs32(21:32)];
end
