function initATG(jtagMaster,atg)
    for thisATG=1:numel(atg)
        ATGInfo=atg(thisATG);



        jtagMaster.writememory(ATGInfo.BASE_ADDR,uint32(1));
        jtagMaster.writememory(ATGInfo.BASE_ADDR,uint32(0));


        delay=round(ATGInfo.ATGClockFreq*ATGInfo.transactionPeriod*1e6);

        switch ATGInfo.ReadWrite
        case 'r'
            rw=uint32(1);
        case 'w'
            rw=uint32(0);
        end
        jtagMaster.writememory(ATGInfo.rw,uint32(rw));
        jtagMaster.writememory(ATGInfo.addr,uint32(hex2dec(ATGInfo.MemAddress)));
        jtagMaster.writememory(ATGInfo.Burst_req,uint32(ATGInfo.TotalBurstReq));
        jtagMaster.writememory(ATGInfo.len,uint32(ATGInfo.BurstLength));
        jtagMaster.writememory(ATGInfo.delay,uint32(delay));
    end
end

