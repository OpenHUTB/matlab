function libpath=commhdllibpath(blk)






    commblks=['Communications',newline,'Toolbox/'];

    commsources='Sources';
    commoddemod='Modulation';
    commerrdetcorr=['Error Detection',newline,'and Correction'];
    commcnvint='Interleaving';
    commsinks='Sinks';

    if strncmpi(blk,'commseqgen2/',12)||strncmpi(blk,'commseqgen3/',12)
        libpath=[commsources,blk(12:end)];
    elseif strncmpi(blk,'commdigbbndpm3/',15)
        libpath=[commoddemod,blk(15:end)];
    elseif strncmpi(blk,'commdigbbndam3/',15)
        libpath=[commoddemod,blk(15:end)];
    elseif strncmpi(blk,'commcnvcod2/',12)
        libpath=[commerrdetcorr,blk(12:end)];
    elseif strncmpi(blk,'commcnvintrlv2/',15)
        libpath=[commcnvint,blk(15:end)];
    elseif strncmpi(blk,'commcrc2/',9)
        libpath=[commerrdetcorr,blk(9:end)];
    elseif strncmpi(blk,'commblkcod2/',12)
        libpath=[commerrdetcorr,blk(12:end)];
    elseif strncmpi(blk,'commsink2/',10)
        libpath=[commsinks,blk(10:end)];
    else
        libpath='';
    end

    libpath=[commblks,libpath];

end

