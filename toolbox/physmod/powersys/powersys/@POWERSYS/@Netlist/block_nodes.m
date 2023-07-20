function ns=block_nodes(nl,block);





    block=get_param(block,'Handle');
    blk_idx=find(nl.elements==block);
    nsx=nl.nodes(blk_idx,:);
    ns=nsx{1};