function MemoryID=memIdx(supportedDebugMem,offset,memS)


    MemoryID=find(strcmp(supportedDebugMem,memS))+(offset-1);


end