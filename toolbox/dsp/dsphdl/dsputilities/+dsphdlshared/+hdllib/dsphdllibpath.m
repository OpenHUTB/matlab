function libpath=dsphdllibpath(blk)






    dspblks=['DSP',newline,'System Toolbox/'];
    dspfilters='Filtering';
    dspsources='Sources';
    dspsinks='Sinks';
    dspsigattribs=['Signal',newline,'Management/Signal',newline,'Attributes'];
    dspindex=['Signal',newline,'Management/Indexing'];
    dspsigops=['Signal',newline,'Operations'];
    dspstats='Statistics';
    dspobsolete='Obsolete';
    dspxfrm='Transforms';
    dspmathops='Math Functions';

    dsphdlblks='DSP HDL Toolbox/';
    dsphdlfilters='Filtering';

    dsphdlsigops=['Signal',newline,'Operations'];
    dsphdlxfrm='Transforms';
    dsphdlmathops='Math Functions';

    if strncmpi(blk,'dspsrcs4/',9)
        libpath=[dspblks,dspsources,blk(9:end)];
    elseif strncmpi(blk,'dspsnks4/',9)
        libpath=[dspblks,dspsinks,blk(9:end)];
    elseif strncmpi(blk,'dspsigattribs',13)
        libpath=[dspblks,dspsigattribs,blk(14:end)];
    elseif strncmpi(blk,'dspindex/',8)
        libpath=[dspblks,dspindex,blk(9:end)];
    elseif strncmpi(blk,'dspadpt3/',9)
        libpath=[dspblks,dspfilters,blk(9:end)];
    elseif strncmpi(blk,'dspmlti4/',9)
        libpath=[dspblks,dspfilters,blk(9:end)];
    elseif strncmpi(blk,'dsparch4/',9)
        libpath=[dspblks,dspfilters,blk(9:end)];
    elseif strncmpi(blk,'dspsigops/',10)
        libpath=[dspblks,dspsigops,blk(10:end)];
    elseif strncmpi(blk,'dsphdlsigops/',13)
        libpath=[dspblks,dspsigops,blk(13:end)];
    elseif strncmpi(blk,'dspstat3/',9)
        libpath=[dspblks,dspstats,blk(9:end)];
    elseif strncmpi(blk,'dspobslib/',10)
        libpath=[dspblks,dspobsolete,blk(10:end)];
    elseif strncmpi(blk,'dspxfrm3/',9)
        libpath=[dspblks,dspxfrm,blk(9:end)];
    elseif strncmpi(blk,'dsphdlxfrm/',11)
        libpath=[dspblks,dspxfrm,blk(11:end)];
    elseif strncmpi(blk,'dspmathops/',11)
        libpath=[dspblks,dspmathops,blk(11:end)];
    elseif strncmpi(blk,'dsphdlmathfun/',14)
        libpath=[dspblks,dspmathops,blk(14:end)];
    elseif strncmpi(blk,'dsphdlfiltering/',16)
        libpath=[dspblks,dspfilters,blk(16:end)];
    elseif strncmpi(blk,'dsphdlxfrm2/',12)
        libpath=[dsphdlblks,dsphdlxfrm,blk(12:end)];
    elseif strncmpi(blk,'dspmathops2/',12)
        libpath=[dsphdlblks,dsphdlmathops,blk(12:end)];
    elseif strncmpi(blk,'dsphdlmathfun2/',15)
        libpath=[dsphdlblks,dsphdlmathops,blk(15:end)];
    elseif strncmpi(blk,'dsphdlfiltering2/',17)
        libpath=[dsphdlblks,dsphdlfilters,blk(17:end)];
    elseif strncmpi(blk,'dsphdlsigops2/',14)
        libpath=[dsphdlblks,dsphdlsigops,blk(14:end)];
    else
        libpath=dspblks;
    end


end

