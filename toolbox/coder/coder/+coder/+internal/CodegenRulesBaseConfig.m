function mxcfg=CodegenRulesBaseConfig()











    mxcfg=coder.config('MEX');


    mxcfg.FilePartitionMethod='SingleFile';


    mxcfg.TargetLang='C++';


    mxcfg.GenCodeOnly=true;



    if strcmp(string(getenv('MW_TARGET_ARCH')),"win64")||...
        strcmp(string(getenv('MW_TARGET_ARCH')),"glnxa64")||...
        strcmp(string(getenv('MW_TARGET_ARCH')),"maci64")

        mxcfg.EnableOpenMP=true;
    else
        mxcfg.EnableOpenMP=false;
    end



end
