function block=src_block(nl,node)

    port=nl.src_port(node);
    block=get_param(port,'Parent');
    block=nl.promote_block(block);




