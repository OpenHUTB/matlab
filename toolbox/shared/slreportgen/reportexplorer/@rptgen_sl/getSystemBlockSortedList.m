function sortedList=getSystemBlockSortedList(sysName,force)












    if(nargin==1)
        force=false;
    end


    sysName=getfullname(sysName);

    adSL=rptgen_sl.appdata_sl;
    modelName=bdroot(sysName);
    try
        if(~force&&adSL.FailedCompiledModelList.contains(modelName))
            error(message('RptgenSL:rptgen_sl:GetSystemBlockSortListFailedBefore',sysName,modelName));
        else
            sortedList=get_param(sysName,'SortedList');
        end
        adSL.FailedCompiledModelList.remove(modelName);
    catch me
        adSL.FailedCompiledModelList.add(modelName);
        rethrow(me);
    end
