function ret=getStdLinkerOptions(h,pjtName,systemStackSize)




    ret{1}=' -c';
    ret{length(ret)+1}=' -x';
    ret{length(ret)+1}=[' -o"',pjtName,'.out" '];
    ret{length(ret)+1}=[' -m"',pjtName,'.map" '];
    ret{length(ret)+1}=[' -stack0x',dec2hex(systemStackSize)];