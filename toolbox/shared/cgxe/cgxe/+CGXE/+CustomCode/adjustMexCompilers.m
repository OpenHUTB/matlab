







function[compilerInfo,clearObj]=adjustMexCompilers(genCpp,setupMatchingCompiler)
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',genCpp);
    clearObj=[];

    compilerName=compilerInfo.compilerName;
    isGccLike=~ispc||strncmpi(compilerName,'mingw64',7);

    compilerInfo.forceCxx=genCpp&&isGccLike;
    compilerInfo.isLcc=ispc&&strcmpi(compilerName,'lcc');

    if isGccLike&&~genCpp
        compilerInfo.cppOverrides='-std=c++03';
    else
        compilerInfo.cppOverrides='';
    end

    if setupMatchingCompiler
        try
            cCompInfo=mex.getCompilerConfigurations('C','Selected');
            cxxCompInfo=mex.getCompilerConfigurations('C++','Selected');
            if genCpp
                if~isempty(cxxCompInfo)

                    cCompName=internal.cxxfe.util.getMexCompilerInfo(...
                    'getCxxCompatInfo',cxxCompInfo.ShortName);
                    clearObj=setupMexCompiler(...
                    cCompInfo,cCompName,false);
                end
            else
                if~isempty(cCompInfo)&&~compilerInfo.isLcc

                    cxxCompName=internal.cxxfe.util.getMexCompilerInfo(...
                    'getCCompatInfo',cCompInfo.ShortName);
                    clearObj=setupMexCompiler(...
                    cxxCompInfo,cxxCompName,true);
                end
            end
        catch
        end
    end




    function clrObj=setupMexCompiler(currCompInfo,newCompName,isCxx)


        clrObj=[];
        if~isempty(currCompInfo)&&strcmp(currCompInfo.ShortName,newCompName)
            return
        end


        mexExtraArgs='';
        if isCxx
            mexExtraArgs=' C++';
        end
        cmdFcn=@(x)sprintf('try,mex -setup:%s%s,catch,end',x,mexExtraArgs);
        evalc(cmdFcn(newCompName));


        if~isempty(currCompInfo)
            clrObj=onCleanup(@()evalc(cmdFcn(currCompInfo.ShortName)));
        end


