function bcc=getBCCDefaultDebug()




    bcc.debugIDNumWLimit=2^16;
    bcc.debugBankNumWLimit=2^16;
    bcc.debugCounterWLimit=32;
    bcc.debugDMADepthLimit=2^32;
    bcc.debugDMAWidthLimit=128;
    bcc.memReadLatency=1;
    bcc.debugMemReadLatency=5;

    bcc.debugMemDepth=4096;
    bcc.debugMemMinDepth=1024;


end
