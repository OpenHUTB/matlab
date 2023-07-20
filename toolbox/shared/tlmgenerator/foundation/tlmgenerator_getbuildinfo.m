function bi=tlmgenerator_getbuildinfo(modelName,buildInfo)



    try





        [~,incList]=buildInfo.getFullFileList('include');
        [~,srcList]=buildInfo.getFullFileList('source');


        cfg=tlmgenerator_getconfigset(modelName);




        modelIncList=incList;

        mainList=regexp(srcList,'^rt_main\.c*');
        nonMainList=cellfun(@(x)(isempty(x)),mainList);
        modelSrcList=srcList(nonMainList);

        modelObjListGlnx=regexprep(modelSrcList,{'\.c$','\.cpp$'},'.o');
        modelObjListWin=regexprep(modelSrcList,{'\.c$','\.cpp$'},'.obj');

        bi.IncListNoPath=modelIncList;
        bi.SrcListNoPath=modelSrcList;

        bi.IncListGlnx=sprintf('include/%s ',modelIncList{:});
        bi.SrcListGlnx=sprintf('src/%s ',modelSrcList{:});
        bi.ObjListGlnx=sprintf('obj/%s ',modelObjListGlnx{:});

        bi.IncListWin=sprintf('include\\%s ',modelIncList{:});
        bi.SrcListWin=sprintf('src\\%s ',modelSrcList{:});
        bi.ObjListWin=sprintf('obj\\%s ',modelObjListWin{:});


        bi.OrigMdlSubsystemPath=getappdata(0,'tlmgSubsystemPath');
        bi.OrigMdlSubsystemName=getappdata(0,'tlmgSubsystemName');
        if(~isempty(bi.OrigMdlSubsystemPath))
            bi.OrigMdlDut=[bi.OrigMdlSubsystemPath,'/',bi.OrigMdlSubsystemName];
        else
            bi.OrigMdlDut=modelName;
        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG getbuildinfo: %s',ME.message);
        throw(l_me);
    end

end
