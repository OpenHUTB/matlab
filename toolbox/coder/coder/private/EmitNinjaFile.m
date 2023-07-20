function EmitNinjaFile(project,buildInfo,bldMode,compilerInfo,configInfo,parallelCode)





    metaData=coder.internal.emcNinjaMetadata;
    metaData.setOutputFileName([GetTokenValue(buildInfo,'MLC_TARGET_NAME','BuildArgs'),'.',mexext]);
    metaData.setCodingForCuda(compilerInfo.codingForCuda);
    metaData.setCodingForOpenCL(~isempty(configInfo.GpuConfig)&&configInfo.GpuConfig.isOpenCLCodegen());


    parseMexOptions(compilerInfo,configInfo,metaData,buildInfo,project);

    if project.FeatureControl.ExportStyle=="Macro"
        buildInfo.addDefines('MW_NEEDS_VERSION_H');
    end


    updateParallelFlag(buildInfo,compilerInfo,parallelCode);

    if ispc&&~compilerInfo.codingMinGWMakefile&&~compilerInfo.codingForCuda
        if isprop(configInfo,'TargetLang')&&configInfo.TargetLang=="C++"
            buildInfo.addCompileFlags('/wd4251');
        end
    end


    metaData.RootDir=emcGetBuildDirectory(buildInfo,bldMode);
    if isempty(project.FileName)

        metaData.BuildDir='$root';


        metaData.MatlabDir=emcAltPathName(matlabroot);
    else
        metaData.BuildDir=fullfile('$root','build',computer('arch'));
        metaData.MatlabDir=matlabroot;
    end
    metaData.StartDir=project.OutDirectory;


    if project.FeatureControl.FileSaveEncoding=="UTF-8"
        if compilerInfo.codingMicrosoftMakefile
            flag='/utf-8';
            if compilerInfo.codingForCuda
                metaData.appendFlag('CUDAFLAGS',['-Xcompiler "',flag,'"']);
            end
            metaData.appendFlag('CFLAGS',flag);
            metaData.appendFlag('CXXFLAGS',flag);
        elseif compilerInfo.codingIntelMakefile
            metaData.appendFlag('CFLAGS','-Qoption,cpp,--unicode_source_kind,"UTF-8"');
            metaData.appendFlag('CXXFLAGS','-Qoption,cpp,--unicode_source_kind,"UTF-8"');
        end
    end


    if compilerInfo.codingIntelMakefile
        metaData.appendFlag('CFLAGS','/Qstd=c99');
        metaData.appendFlag('CXXFLAGS','/Qstd=c++11');
    end


    processBuildInfo(project,buildInfo,configInfo,metaData);


    if project.FeatureControl.ExportStyle~="Macro"
        gen_linkfile(metaData,buildInfo,bldMode,parallelCode);
    end


    generateNinjaFile(metaData,buildInfo,bldMode,compilerInfo.compilerName,configInfo.EnableDebugging);


    genBuildScript(metaData,configInfo,buildInfo,bldMode,project.FeatureControl.GenerateCompileCommands);

end

function out=convertTokensToStruct(tokens)
    if ispc
        trimQuotes=false;
    else
        trimQuotes=true;
    end
    for i=1:numel(tokens)
        t=tokens{i};
        if isempty(t)
            continue;
        end
        splitIdx=regexp(t,'=','once');
        parm=t(1:splitIdx-1);
        if startsWith(parm,'set')
            parm=parm(5:end);
        end
        value=t(splitIdx+1:end);
        if trimQuotes&&value(1)=='"'
            value=value(2:end-1);
        end
        out.(parm)=value;
    end
end

function msvc_mexopts_parser(tokens,buildInfo,configInfo,metaData,isIntel)

    metaData.initializeCompilerBasic('msvc');

    tmp=convertTokensToStruct(tokens);
    ensureMEXCompilerExists(tmp.PATH,{[tmp.COMPILER,'.exe'],[tmp.LINKER,'.exe']});


    metaData.setCompiler('C',tmp.COMPILER);
    metaData.setCompiler('CXX',tmp.COMPILER);
    metaData.setLinker('LD',tmp.LINKER);
    metaData.setLinker('LDXX',tmp.LINKER);
    metaData.appendFlag('CFLAGS',tmp.COMPFLAGS);
    metaData.appendFlag('LDFLAGS',tmp.LINKFLAGS);
    metaData.appendFlag('LDFLAGS',tmp.NAME_OUTPUT);

    if~configInfo.EnableDebugging
        metaData.appendFlag('CFLAGS',tmp.OPTIMFLAGS);
        if~isIntel
            metaData.appendFlag('CFLAGS','/fp:strict');
        end
    else
        metaData.appendFlag('CFLAGS',tmp.DEBUGFLAGS);
        metaData.appendFlag('LDFLAGS',tmp.LINKDEBUGFLAGS);
        metaData.replaceToken('LDFLAGS',['%OUTDIR%%MEX_NAME%.',mexext],metaData.getOutputFileName);

        if metaData.getCodingForCuda()
            metaData.appendFlag('CFLAGS','/FS');
            metaData.appendFlag('CUDAFLAGS','-Xcompiler "/FS"');
        end
    end
    metaData.appendFlag('CXXFLAGS',metaData.getFlag('CFLAGS'));

    metaData.appendFlag('SetEnv',sprintf('set PATH=%s\nset INCLUDE=%s\nset LIB=%s\nset LIBPATH=%s\n',...
    tmp.PATH,tmp.INCLUDE,tmp.LIB,tmp.LIBPATH));


    metaData.replaceToken('LDFLAGS','%OUTDIR%%MEX_NAME%%MEX_EXT%',metaData.getOutputFileName);
    metaData.replaceToken('LDFLAGS','/export:%ENTRYPOINT%','');
    metaData.replaceToken('LDFLAGS','/EXPORT:mexFunction','');

    buildInfo.addSysLibs('emlrt','');
    buildInfo.addSysLibs('covrt','');
    buildInfo.addSysLibs('ut','');
    buildInfo.addSysLibs('mwmathutil','');
end

function mingw_mexopts_parser(tokens,configInfo,metaData)

    metaData.initializeCompilerBasic('mingw');

    tmp=convertTokensToStruct(tokens);
    ensureMEXCompilerExists(tmp.PATH,{[tmp.COMPILER,'.exe'],[tmp.CXXCOMPILER,'.exe'],[tmp.LINKER,'.exe']});


    metaData.setCompiler('C',tmp.COMPILER);
    metaData.setCompiler('CXX',tmp.CXXCOMPILER);
    metaData.setLinker('LD',tmp.LINKER);
    metaData.setLinker('LDXX',tmp.CXXLINKER);
    metaData.appendFlag('CFLAGS',tmp.COMPFLAGS);
    metaData.appendFlag('CXXFLAGS',tmp.CXXCOMPFLAGS);
    metaData.appendFlag('LDFLAGS',tmp.LINKFLAGS);
    metaData.appendFlag('LDFLAGS',tmp.NAME_OUTPUT);

    if~configInfo.EnableDebugging
        metaData.appendFlag('CFLAGS',tmp.OPTIMFLAGS);
        metaData.appendFlag('CXXFLAGS',tmp.OPTIMFLAGS);
    else
        metaData.appendFlag('CFLAGS',tmp.DEBUGFLAGS);
        metaData.appendFlag('CXXFLAGS',tmp.DEBUGFLAGS);
        metaData.appendFlag('LDFLAGS',tmp.LINKDEBUGFLAGS);
    end

    metaData.appendFlag('SetEnv',sprintf('set PATH=%s\nset INCLUDE=%s\nset LIB=%s\nset LIBPATH=%s\n',...
    tmp.PATH,tmp.INCLUDE,tmp.LIB,tmp.LIBPATH));


    metaData.replaceToken('LDFLAGS','%OUTDIR%%MEX_NAME%%MEX_EXT%',metaData.getOutputFileName);
end

function lcc_mexopts_parser(~,configInfo,metaData)

    metaData.initializeCompilerBasic('lcc');




    metaData.setCompiler('C','lcc64');
    metaData.setLinker('LD','lcclnk64');
    metaData.appendFlag('CFLAGS','-nodeclspec -Zp8 -dll -c -I"$(MATLAB_ROOT)\sys\lcc64\lcc64\include64" -DMATLAB_MEX_FILE -noregistrylookup');

    ld=['-dll -L"$(MATLAB_ROOT)\sys\lcc64\lcc64\lib64" -L"$(MATLAB_ROOT)\extern\lib\win64\microsoft"'...
    ,' -entry LibMain libmx.lib libmex.lib libmat.lib libemlrt.lib libcovrt.lib libut.lib libmwmathutil.lib -o ',metaData.getOutputFileName];
    metaData.appendFlag('LDFLAGS',ld);

    if~configInfo.EnableDebugging
        metaData.appendFlag('CFLAGS','-DNDEBUG');
        metaData.appendFlag('LDFLAGS','-s');
    else
        metaData.appendFlag('CFLAGS','-g2');
    end
end

function unix_mexopts_parser(tokens,configInfo,metaData,project)

    metaData.initializeCompilerBasic('unix');

    tmp=convertTokensToStruct(tokens);


    metaData.setCompiler('C',tmp.CC);
    metaData.setCompiler('CXX',tmp.CXX);
    metaData.setLinker('LD',tmp.LD);
    metaData.setLinker('LDXX',tmp.LDXX);
    metaData.appendFlag('CFLAGS',tmp.CFLAGS);
    metaData.appendFlag('CXXFLAGS',tmp.CXXFLAGS);
    metaData.appendFlag('LDFLAGS',tmp.LDFLAGS);

    if~configInfo.EnableDebugging
        metaData.appendFlag('CFLAGS',tmp.COPTIMFLAGS);
        metaData.appendFlag('CXXFLAGS',tmp.CXXOPTIMFLAGS);
    else
        metaData.appendFlag('CFLAGS',tmp.CDEBUGFLAGS);
        metaData.appendFlag('CXXFLAGS',tmp.CXXDEBUGFLAGS);
        metaData.appendFlag('LDFLAGS',tmp.LDDEBUGFLAGS);
    end


    if ismac
        mapFlag='-exported_symbols_list';
        metaData.appendFlag('LDFLAGS','-Wl,-rpath,@loader_path');
    else
        mapFlag='--version-script';
        metaData.appendFlag('LDFLAGS','-Wl,-Bsymbolic');
    end

    oldExportMap=sprintf('-Wl,%s,"%s/extern/lib/%s/mexFunction.map"',mapFlag,matlabroot,computer('arch'));
    metaData.replaceToken('LDFLAGS',oldExportMap,'');
    metaData.appendFlag('LDFLAGS',['-o ',metaData.getOutputFileName]);
    if project.FeatureControl.ExportStyle=="Macro"
        metaData.appendFlag('CFLAGS','-fvisibility=hidden');
        metaData.appendFlag('CXXFLAGS','-fvisibility=hidden');

        if~ismac



            metaData.appendFlag('CXXFLAGS','-fno-gnu-unique');
            metaData.appendFlag('LDFLAGS','-Wl,--exclude-libs,ALL');
        end

        if metaData.getCodingForCuda()


            metaData.appendFlag('CUDAFLAGS','-Xcompiler -fvisibility=hidden');
        end
    end
end

function unixCommonPostProcess(buildInfo,configInfo,metaData)
    metaData.appendFlag('CXXFLAGS','-std=c++11');
    if configInfo.ForceANSIC
        metaData.appendFlag('CFLAGS','-ansi');
    else
        metaData.appendFlag('CFLAGS','-std=c99');
    end
    if metaData.getCodingForCuda()
        metaData.appendFlag('CUDAFLAGS','-Xcompiler -std=c++11');
    end
    buildInfo.addSysLibs('emlrt','');
    buildInfo.addSysLibs('covrt','');
    buildInfo.addSysLibs('ut','');
    buildInfo.addSysLibs('mwmathutil','');
end

function ensureMEXCompilerExists(path,exes)
    function checkIfExists(execName)
        found=false;

        for i=1:length(pathparts)
            if exist(fullfile(pathparts{i},execName),'file')||exist(execName,'file')
                found=true;
                break;
            end
        end
        if~found
            coder.internal.throwUnsupportedCompilerError();
        end
    end

    path=string(path);
    pathparts=path.split(';');
    cellfun(@checkIfExists,exes);
end

function parseMexOptions(compilerInfo,configInfo,metaData,buildInfo,project)
    tokens=strsplit(compilerInfo.mexOptsFile,newline);
    trimedTokens=cellfun(@strtrim,tokens,'UniformOutput',false);


    if metaData.getCodingForCuda()
        mexopts_update_cuda(configInfo,metaData);
    end

    if ispc
        if compilerInfo.codingMicrosoftMakefile
            msvc_mexopts_parser(trimedTokens,buildInfo,configInfo,metaData,false);
        elseif compilerInfo.codingMinGWMakefile
            mingw_mexopts_parser(trimedTokens,configInfo,metaData);

            buildInfo.addDefines('__USE_MINGW_ANSI_STDIO=1');
            unixCommonPostProcess(buildInfo,configInfo,metaData);
        elseif compilerInfo.codingIntelMakefile
            msvc_mexopts_parser(trimedTokens,buildInfo,configInfo,metaData,true);
        elseif compilerInfo.codingLcc64Makefile
            lcc_mexopts_parser(trimedTokens,configInfo,metaData);
            buildInfo.addSourceFiles('lccstub.c',fullfile(matlabroot,'\sys\lcc64\lcc64\mex'));
        end
    else
        unix_mexopts_parser(trimedTokens,configInfo,metaData,project);
        buildInfo.addCompileFlags('-c');
        unixCommonPostProcess(buildInfo,configInfo,metaData);
    end


    buildInfo.addIncludePaths('.');
end

function updateParallelFlag(buildInfo,compilerInfo,parallelCode)
    if~parallelCode
        return;
    end
    if ispc
        if compilerInfo.codingMinGWMakefile
            buildInfo.addCompileFlags('-fopenmp');
            buildInfo.addLinkFlags('-fopenmp');
        else
            buildInfo.addCompileFlags('/openmp /wd4101');
            ompLibPath=fullfile(matlabroot,'bin',computer('arch'));
            ldflags=sprintf('/nodefaultlib:vcomp /LIBPATH:"%s"',ompLibPath);
            buildInfo.addLinkFlags(ldflags);
            buildInfo.addSysLibs('iomp5md','');
        end
    elseif ismac
        omplibpath=fullfile(matlabroot,'sys','os',computer('arch'));
        ompfile=fullfile(omplibpath,'libiomp5.dylib');
        headerPath=fullfile(matlabroot,'toolbox','eml','externalDependency','omp',computer('arch'),'include');
        cflag=sprintf('-fPIC -Xpreprocessor -fopenmp -I "%s" -DOpenMP_omp_LIBRARY="%s"',headerPath,ompfile);
        buildInfo.addCompileFlags(cflag);
        ldflags=sprintf('-fPIC -L"%s" -liomp5',omplibpath);
        buildInfo.addLinkFlags(ldflags);
    else
        omplibpath=fullfile(matlabroot,'sys','os',computer('arch'));
        ompfile=fullfile(omplibpath,'libiomp5.so');
        cflag=sprintf('-fopenmp -DOMPLIBNAME="%s"',ompfile);
        buildInfo.addCompileFlags(cflag);
        ldflags=sprintf('-fPIC -L"%s" -liomp5',omplibpath);
        buildInfo.addLinkFlags(ldflags);
    end
end

function processBuildInfo(project,buildInfo,configInfo,metaData)
    function ret=isFullPath(aPath)
        ret=false;
        if ispc
            if length(aPath)>2&&aPath(2)==':'
                ret=true;
            elseif startsWith(aPath,'\\')
                ret=true;
            end
        else
            if startsWith(aPath,'/')
                ret=true;
            end
        end
    end

    function loc=findSourceFile(currentDir,aFile)
        sourcePath=buildInfo.getSourcePaths(true);
        for idx=1:numel(sourcePath)
            if isFullPath(sourcePath{idx})
                fPath=sourcePath{idx};
            else
                fPath=fullfile(currentDir,sourcePath{idx});
            end
            if isfile(fullfile(fPath,aFile))
                loc=fPath;
                return;
            end
        end

        error(message('Coder:buildProcess:fileNotFound',...
        aFile,'custom source code',strjoin(sourcePath,newline)));
    end

    function checkFileExtension(f,e)
        if emcValidateFileKind(e)~=1
            ccwarningid('Coder:buildProcess:InvalidSourceExtension',[f,e]);
        end

    end




    [sysLib,sysLibPath]=buildInfo.getSysLibInfo();
    for i=1:numel(sysLibPath)
        metaData.addLibPath(sysLibPath{i});
    end
    standardSysLib=buildInfo.getFiles('syslib',false,false,{'Standard'});
    for i=1:numel(sysLib)
        if any(strcmp(sysLib{i},standardSysLib))
            continue;
        end
        metaData.addLinkLibrary(sysLib{i});
    end


    ldflags=buildInfo.getLinkFlags('');
    metaData.appendFlag('LDFLAGS',strjoin(ldflags,' '));


    lobjs=buildInfo.getLinkObjects();
    for i=1:numel(lobjs)
        if lobjs(i).LinkOnly
            metaData.addLinkObject(fullfile(lobjs(i).Path,lobjs(i).Name));
        else

            srcFiles=lobjs(i).getSourceFiles(true,true);
            for srcIdx=1:numel(srcFiles)
                [p,f,e]=fileparts(srcFiles{i});
                checkFileExtension(f,e);
                buildInfo.addSourceFiles([f,e],p);
            end
        end
    end

    sourceFiles=buildInfo.getSourceFiles(true,true);
    metaData.Source=cell(1,numel(sourceFiles));
    metaData.SourcePath=cell(1,numel(sourceFiles));

    bldDir=project.BldDirectory;


    for i=1:numel(sourceFiles)
        [p,n,e]=fileparts(sourceFiles{i});
        file=[n,e];
        if isempty(p)
            p=findSourceFile(bldDir,file);
        end
        checkFileExtension(n,e);
        metaData.addSourceFile(file,p,i);
    end


    include=buildInfo.getIncludePaths(true);
    for i=1:numel(include)
        metaData.addIncludePath(include{i});
    end


    def=buildInfo.getDefines();
    metaData.addDefine(strjoin(def,' '));


    if metaData.getCodingForCuda()
        flags=buildInfo.getCompileFlags('',{'C_OPTS','CPP_OPTS','CU_OPTS'});
    else
        flags=buildInfo.getCompileFlags('',{'C_OPTS','CPP_OPTS'});
    end

    metaData.appendFlag('CFLAGS',strjoin(flags,' '));
    metaData.appendFlag('CXXFLAGS',strjoin(flags,' '));


    cflags=buildInfo.getCompileFlags('C_OPTS');
    metaData.appendFlag('CFLAGS',strjoin(cflags,' '));


    cxxflags=buildInfo.getCompileFlags('CPP_OPTS');
    metaData.appendFlag('CXXFLAGS',strjoin(cxxflags,' '));


    if metaData.getCodingForCuda()
        processBuildInfoForCuda(buildInfo,metaData,configInfo.GpuConfig.UseShippingLibs);
    end
end

function gen_linkfile(metaData,buildInfo,bldMode,~)
    function unix_emitter
        fprintf(file,'MEX {\n');
        fprintf(file,'\tglobal:\n');
        fprintf(file,'\t\t%s;\n',exports{:});
        fprintf(file,'\tlocal:\n');
        fprintf(file,'\t\t*;\n');
        fprintf(file,'};\n');
        metaData.appendFlag('LDFLAGS',['-Wl,--version-script,',mexTarget,nameSuffix]);
    end

    function mac_emitter
        fprintf(file,'_%s\n',exports{:});
        metaData.appendFlag('LDFLAGS',['-Wl,-exported_symbols_list,',mexTarget,nameSuffix]);
    end

    function microsoft_emitter
        if metaData.getCodingForCuda()
            links=exports;
            for idx=1:size(exports,2)
                links{idx}=sprintf('/export:%s',exports{idx});
            end
            metaData.appendFlag('LDFLAGS',['-Xlinker ',strjoin(links,',')]);
        else
            for i=1:numel(exports)
                metaData.appendFlag('LDFLAGS',['/export:',exports{i}]);
            end
        end
    end

    function lcc64_emitter
        fprintf(file,'LIBRARY %s.mexw64\n',mexTarget);
        fprintf(file,'EXPORTS\n');
        fprintf(file,'%s\n',exports{:});
        metaData.appendFlag('LDFLAGS',[mexTarget,nameSuffix]);
    end

    function prime_lcc64_emitter
        nameSuffix='.def';
        emitter=@lcc64_emitter;
    end

    switch metaData.Kind
    case 'msvc'
        nameSuffix='';
        emitter=@microsoft_emitter;
    case 'unix'
        nameSuffix='.map';
        if ismac
            emitter=@mac_emitter;
        elseif ispc






            prime_lcc64_emitter();
        else
            emitter=@unix_emitter;
        end
    case 'lcc'
        prime_lcc64_emitter();
    otherwise
        return;
    end

    mexTarget=GetTokenValue(buildInfo,'MLC_TARGET_NAME','BuildArgs');
    exports={'mexFunction'};
    if~metaData.getCodingForCuda()
        exports{end+1}='mexfilerequiredapiversion';
    end

    if bldMode==coder.internal.BuildMode.Normal
        tokens=regexp(char(GetTokenValue(buildInfo,'EMC_ENTRY_POINTS')),',','split');
        if isempty(tokens)||(numel(tokens)==1&&isempty(tokens{1}))
            tokens{end+1}='emlrtMexFcnProperties';
        end
        exports=[exports,tokens];

        exports(cellfun(@isempty,exports))=[];
    end

    if~isempty(nameSuffix)
        [file,fspec]=OpenSupportFile(buildInfo,[mexTarget,nameSuffix],bldMode);
        if bldMode==coder.internal.BuildMode.Normal
            buildInfo.addNonBuildFiles(fspec);
        end
        emitter();
        fclose(file);
    else
        emitter();
    end
end

function gen_setEnv(metaData,buildInfo,bldMode)
    if ispc
        fid=OpenSupportFile(buildInfo,['SetEnv',metaData.ScriptExt],bldMode);
        metaData.genSetEnv(fid);
        fclose(fid);
    end
end

function gen_runFile(metaData,buildInfo,bldMode,genCompDb)
    fid=OpenSupportFile(buildInfo,[GetTokenValue(buildInfo,'EMC_PROJECT'),'_mex',metaData.ScriptExt],bldMode);
    metaData.genRunFile(fid,genCompDb);
    fclose(fid);
end

function generateNinjaFile(metaData,buildInfo,bldMode,compilerName,isDebug)

    fid=OpenSupportFile(buildInfo,'build.ninja',bldMode,'UTF-8');
    fprintf(fid,'# CompilerName=%s\n',compilerName);
    if isDebug
        fprintf(fid,'# Mode=debug\n');
    else
        fprintf(fid,'# Mode=optim\n');
    end
    metaData.generate(fid);
    fclose(fid);
end

function cudaFlags=getCudaFlags(configInfo)
    cudaFlags='-rdc=true -Wno-deprecated-gpu-targets -Xcompiler -fPIC,-ansi,-fexceptions,-fno-omit-frame-pointer,-pthread -Xcudafe "--display_error_number --diag_suppress=2381 --diag_suppress=unsigned_compare_with_zero --diag_suppress=useless_type_qualifier_on_return_type" -D_GNU_SOURCE -DMATLAB_MEX_FILE';
    if ispc
        cudaFlags='-c -rdc=true -Wno-deprecated-gpu-targets -Xcompiler "/wd 4819" -Xcompiler "/MD" -Xcudafe "--display_error_number --diag_suppress=2381 --diag_suppress=unsigned_compare_with_zero --diag_suppress=useless_type_qualifier_on_return_type" -D_GNU_SOURCE -DMATLAB_MEX_FILE --no-exceptions -Xcompiler "/EHa"';
    end

    if configInfo.GpuConfig.UseShippingLibs

        if isunix
            cuda_lib_dir='$(MATLAB_ROOT)/bin/glnxa64';
            cudaFlags=[cudaFlags,' -noprof -ldir "',cuda_lib_dir,'"'];
        else
            cuda_lib_dir='$(MATLAB_ROOT)/bin/win64';
            cudaFlags=[cudaFlags,' -noprof -ldir "',cuda_lib_dir,'"'];
        end
    end

end

function mexopts_update_cuda(configInfo,metaData)

    metaData.setCompiler('CUDAC','nvcc');
    metaData.setLinker('LDCUDA','nvcc');

    cudaFlags=getCudaFlags(configInfo);
    metaData.appendFlag('CUDAFLAGS',cudaFlags);


    if configInfo.EnableDebugging
        metaData.appendFlag('CUDAFLAGS','-g -G -O0');
    end
end

function processBuildInfoForCuda(buildInfo,metaData,useShippingCudaLibs)
    flags=buildInfo.getCompileFlags('',{'C_OPTS','CPP_OPTS','CU_OPTS'});
    cudacflags=buildInfo.getCompileFlags('CU_OPTS');
    metaData.appendFlag('CUDAFLAGS',strjoin(flags,' '));
    metaData.appendFlag('CUDAFLAGS',strjoin(cudacflags,' '));

    additionalIncludes={...
    '-I "$(MATLAB_ROOT)/simulink/include"',...
    '-I "$(MATLAB_ROOT)/toolbox/shared/simtargets"'};

    metaData.appendFlag('CUDAFLAGS',strjoin(additionalIncludes,' '));

    if ispc
        if useShippingCudaLibs
            cudaStaticLibPath=fullfile(matlabroot,'sys','cuda','win64','cuda','lib','x64');
            metaData.addLibPath(cudaStaticLibPath);

            cudaPath=fullfile(matlabroot,'bin','win64');
            metaData.addLibPath(cudaPath);
        else
            cudaPath=getenv('CUDA_PATH');
            libDir='x64';
            if strcmp(mexext,'mexw32')
                libDir='Win32';
            end
            metaData.addLibPath([cudaPath,'\lib\',libDir]);
        end
    elseif isunix
        if useShippingCudaLibs
            cudaStaticLibPath=fullfile(matlabroot,'sys','cuda','glnxa64','cuda','lib64');
            metaData.addLibPath(cudaStaticLibPath);
        end
    end

    if useShippingCudaLibs&&isunix
        additionalLibraries=coder.gpu.internal.getLinuxShippingCudaLibs();
    else
        additionalLibraries={'cudart','cublas','cusolver','cufft','curand','cusparse'};
    end

    if~ispc
        additionalLibraries{end+1}='c';
    end
    usePrefix=~ispc;
    for i=1:numel(additionalLibraries)
        metaData.addLinkLibrary(additionalLibraries{i},usePrefix);
    end
end

function genBuildScript(metaData,configInfo,buildInfo,bldMode,genCompDb)
    useShippingCudaLibs=~isempty(configInfo.GpuConfig)&&configInfo.GpuConfig.UseShippingLibs;
    if metaData.getCodingForCuda&&useShippingCudaLibs
        if isunix

            fid=OpenSupportFile(buildInfo,[GetTokenValue(buildInfo,'EMC_PROJECT'),'_mex',metaData.ScriptExt],bldMode);
            fprintf(fid,'#!/bin/sh\n');
            cudabin=fullfile(matlabroot,'sys/cuda/glnxa64/cuda/bin');
            nvvmbin=fullfile(matlabroot,'sys/cuda/glnxa64/cuda/nvvm/bin');
            exportCommand=['export PATH="',cudabin,':',nvvmbin,':$PATH"'];
            fprintf(fid,'%s ; "%s" -v "$@"\n',exportCommand,metaData.getNinjaExecName());
            fclose(fid);
        else
            assert(ispc);
            cudabin=fullfile(matlabroot,'sys/cuda/win64/cuda/bin');
            nvvmbin=fullfile(matlabroot,'sys/cuda/win64/cuda/nvvm/bin');

            metaData.prependFlag('SetEnv',sprintf('set PATH=%s;%s;%%PATH%%\n',cudabin,nvvmbin));
            gen_setEnv(metaData,buildInfo,bldMode);
            gen_runFile(metaData,buildInfo,bldMode,genCompDb);
        end
    else
        gen_runFile(metaData,buildInfo,bldMode,genCompDb);


        gen_setEnv(metaData,buildInfo,bldMode);
    end
end
