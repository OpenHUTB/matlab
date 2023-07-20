function ref_blk=getRefBlk(blk)
    ref_blk=get_param(blk,'ReferenceBlock');
    ref_blk=regexprep(ref_blk,'\n',' ');
end