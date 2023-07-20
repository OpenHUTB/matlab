function libraryPathString=functionstringfromblock(blk)






    hBlk=pmsl_getdoublehandle(blk);
    [libraryPathString,isSimscapeBlock]=simscape.compiler.sli.internal.functioncallfromblock(hBlk);





    if isSimscapeBlock&&~isempty(libraryPathString)
        if isempty(which(libraryPathString))&&...
            ~strcmp(get_param(hBlk,'BlockType'),'SimscapeComponentBlock')
            pkgPath=textscan(libraryPathString,'%s','delimiter','.');
            pkg=pkgPath{1}{1};
            pm_error('physmod:network_engine:sli:SourceNotOnPath',...
            get_param(hBlk,'Name'),pkg);
        end
    end
end

