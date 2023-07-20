function ThreePhaseTransformer12Terminals(BLOCKLIST)









    idx=BLOCKLIST.filter_type('Three-Phase Linear Transformer 12-Terminals');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');

        SPSVerifyLinkStatus(block);
    end