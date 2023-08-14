function source=sources(nl,block,idx)

    block=get_param(block,'Handle');
    blk_idx=find(nl.elements==block);
    node=nl.nodes(blk_idx,idx)
    source.Port=nl.src_port(node,idx);
    source.Block=nl.promote_block(get_param(source.Port,'Parent'));



