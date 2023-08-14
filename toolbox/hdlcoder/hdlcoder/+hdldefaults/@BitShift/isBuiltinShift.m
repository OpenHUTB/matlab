function builtin=isBuiltinShift(this,slbh)



    blkname=get_param(slbh,'BlockType');
    builtin=strcmp(blkname,'ArithShift');
end
