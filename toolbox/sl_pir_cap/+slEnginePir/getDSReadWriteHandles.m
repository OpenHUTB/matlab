function handles=getDSReadWriteHandles(handle)
    DSReadWriteBlocks=get_param(handle,'DSReadWriteBlocks');
    handles=[DSReadWriteBlocks.handle];
end