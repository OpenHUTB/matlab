function desc=getPolySpaceBlockComment(blockname)





    desc{1}=get_param(blockname,'PolySpaceStartComment');
    desc{2}=get_param(blockname,'PolySpaceEndComment');
end