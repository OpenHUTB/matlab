function[val,fullPathTMF]=isProjectBuild(lTemplateMakefile)



    tmf=deblank(lTemplateMakefile);


    isMSVCBuild=(strcmp(tmf,'RTW.MSVCBuild')||...
    ~isempty(regexp(lTemplateMakefile,'@RTW.MSVCBuild','once')));



    isLegacyTMF=(strcmp(tmf,'ert_msvc.tmf')||...
    strcmp(tmf,'grt_msvc.tmf')||...
    ~isempty(regexp(lTemplateMakefile,'[eg]rt_msvc\.tmf','once')));



    val=isMSVCBuild||isLegacyTMF;

    if val
        if isLegacyTMF

            lTemplateMakefile='RTW.MSVCBuild';
        end
        fullPathTMF=which(lTemplateMakefile);
    else
        fullPathTMF='';
    end
