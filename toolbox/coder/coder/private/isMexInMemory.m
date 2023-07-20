function ret=isMexInMemory(mexName)
    mexName=convertStringsToChars(mexName);
    ret=coder.internal.checkIsMEXLoaded(mexName);