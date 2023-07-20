function dumpSubsystemDetails(this,sysEntry,inReport,options)




    if options.elimFullCov&&sysEntry.flags.fullCoverage
        return;
    end
    shortSummBlocks=[];

    blkEntries=this.sortBlocksCustomOrder([sysEntry.blockIdx]);

    for blkEntry=blkEntries(:)'
        shortSummBlocks=dumpBlockDetails(this,shortSummBlocks,blkEntry,inReport,options);
    end
    dumpShortSummary(this,shortSummBlocks,options);

