function MOSFETBlock(BLOCKLIST)









    idx=BLOCKLIST.filter_type('Mosfet');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');

        SPSVerifyLinkStatus(block);
    end