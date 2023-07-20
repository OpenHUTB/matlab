function[buildCmdFcn,buildCmdArgs]=getBuildCmdNonSimTarget(iMdl)







    activeCS=getActiveConfigSet(iMdl);
    [outOfDate,msg]=slprivate('updateCS',activeCS,'UpdateIfWrongTargetClass');
    if outOfDate
        disp(msg);
    end



    if strcmp(get_param(iMdl,'GenerateMakefile'),'off')
        buildCmdArgs='';
        buildCmdFcn='make_rtw';
    else
        [buildCmdFcn,buildCmdArgs]=strtok(get_param(iMdl,'MakeCommand'));
    end


    buildCmdArgs=strtrim(buildCmdArgs);
