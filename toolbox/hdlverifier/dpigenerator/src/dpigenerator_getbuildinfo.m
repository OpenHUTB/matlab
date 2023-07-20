function bi=dpigenerator_getbuildinfo(modelName,buildInfo)







    [~,incList]=buildInfo.getFullFileList('include');
    [~,srcList]=buildInfo.getFullFileList('source');


    modelIncList=incList;

    mainList=regexp(srcList,'^rt_main\.c*|rt_malloc_main\.c*');
    nonMainList=cellfun(@(x)(isempty(x)),mainList);
    modelSrcList=srcList(nonMainList);

    modelObjListGlnx=regexprep(modelSrcList,'\.c$','.o');
    modelObjListWin=regexprep(modelSrcList,'\.c$','.obj');

    bi.IncListNoPath=modelIncList;
    bi.SrcListNoPath=modelSrcList;

    bi.IncListGlnx=sprintf('%s ',modelIncList{:});
    bi.SrcListGlnx=sprintf('%s ',modelSrcList{:});
    bi.ObjListGlnx=sprintf('%s ',modelObjListGlnx{:});

    bi.IncListWin=sprintf('%s ',modelIncList{:});
    bi.SrcListWin=sprintf('%s ',modelSrcList{:});
    bi.ObjListWin=sprintf('obj\\%s ',modelObjListWin{:});


    bi.OrigMdlSubsystemPath=dpigenerator_getvariable('dpigSubsystemPath');
    bi.OrigMdlSubsystemName=dpigenerator_getvariable('dpigSubsystemName');
    if(~isempty(bi.OrigMdlSubsystemPath))
        bi.OrigMdlDut=[bi.OrigMdlSubsystemPath,'/',bi.OrigMdlSubsystemName];
    else
        bi.OrigMdlDut=modelName;
    end

end
