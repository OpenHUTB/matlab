function Multimeterblock(BLOCKLIST)






    idx=BLOCKLIST.filter_type('Multimeter');
    for i=1:length(idx)
        block=BLOCKLIST.elements(idx(i));

        SPSVerifyLinkStatus(block);
    end