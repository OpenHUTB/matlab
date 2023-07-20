function isMakefileBasedBuild=rtw_is_makefile_based_build...
    (cs,lTemplateMakefile)



    if(strfind(lTemplateMakefile,'MSVCBuild'))
        isMakefileBasedBuild=false;
    elseif(strcmp(get_param(cs,'GenerateMakefile'),'on'))
        isMakefileBasedBuild=true;
    else
        isMakefileBasedBuild=false;
    end


