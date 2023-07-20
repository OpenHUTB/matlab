function[libraryPathString,isSimscapeBlock]=functioncallfromblock(blk)





    w=warning('off','backtrace');
    cleanupVar=onCleanup(@()(warning(w)));
    if isstring(blk)
        blk=cellstr(blk);
    end
    if iscell(blk)
        pm_assert(numel(blk)==1);
        blk=blk{1};
    end
    hBlk=pmsl_getdoublehandle(blk);

    libraryPathString='';
    isSimscapeBlock=false;

    if simscape.engine.sli.internal.issimscapeblock(hBlk)
        libraryPathString=get_param(hBlk,'SourceFile');
        isSimscapeBlock=true;
    end

end
