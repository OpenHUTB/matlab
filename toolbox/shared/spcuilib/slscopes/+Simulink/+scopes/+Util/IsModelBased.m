function out=IsModelBased(block)
    ioType=get_block_param(block,'IOType');
    out=strcmp(ioType,'viewer');
end
