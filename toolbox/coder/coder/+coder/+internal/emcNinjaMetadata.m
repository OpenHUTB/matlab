classdef emcNinjaMetadata<handle





    properties

        Kind=''

        Source={}

        SourcePath={}


        ScriptExt='';


        RootDir=''
        BuildDir=''
        StartDir=''
        MatlabDir=''
    end
    properties(Access=private)

        Arch=computer('arch')

        OutputFileName=''


        ObjExt=''

        ExecExt=''


        ObjNameRule=''

        IncludePrefix=''

        LibPathPrefix=''

        AddLibPrefix=''

        AddLibSuffix=''


CudaObjNameRule

CudaIncludePrefix


        CC=''
        CXX=''
        LD=''
        LDXX=''
        CFLAGS=''
        CXXFLAGS=''
        LDFLAGS=''
        LINKOBJS=''
        SetEnv=''


        CodingForCuda=false
        LinkObjectsAdded=false
        CUDAC=''
        CUDAFLAGS=''
        LDCUDA=''
        CodingForOpenCL=false
    end

    methods
        function initializeCompilerBasic(obj,aCompilerkind)
            obj.CudaObjNameRule='-o ';
            obj.CudaIncludePrefix='-I ';
            switch aCompilerkind
            case 'msvc'
                obj.Kind='msvc';
                obj.ObjExt='.obj';
                obj.ExecExt='.exe';
                obj.ScriptExt='.bat';
                obj.ObjNameRule='/Fo';
                obj.IncludePrefix='/I ';
                obj.LibPathPrefix='/LIBPATH:';
                obj.AddLibPrefix='lib';
                obj.AddLibSuffix='.lib';
                if obj.CodingForCuda
                    obj.LibPathPrefix='-L';
                end
            case 'mingw'
                obj.Kind='unix';
                obj.ObjExt='.o';
                obj.ExecExt='.exe';
                obj.ScriptExt='.bat';
                obj.ObjNameRule='-o ';
                obj.IncludePrefix='-I ';
                obj.LibPathPrefix='-L';
                obj.AddLibPrefix='-llib';
            case 'lcc'
                obj.Kind='lcc';
                obj.ObjExt='.obj';
                obj.ExecExt='.exe';
                obj.ScriptExt='.bat';
                obj.ObjNameRule='-Fo';
                obj.IncludePrefix='-I';
                obj.LibPathPrefix='-L';
                obj.AddLibPrefix='lib';
                obj.AddLibSuffix='.lib';
            case 'unix'
                obj.Kind='unix';
                obj.ObjExt='.o';
                obj.ExecExt='';
                obj.ScriptExt='.sh';
                obj.ObjNameRule='-o ';
                obj.IncludePrefix='-I ';
                obj.LibPathPrefix='-L';
                obj.AddLibPrefix='-l';
            end
        end

        function setCompiler(obj,aGroup,aName)
            switch aGroup
            case 'C'
                obj.CC=aName;
            case 'CXX'
                obj.CXX=aName;
            case 'CUDAC'
                obj.CUDAC=aName;
            end
        end

        function setCodingForCuda(obj,aBool)
            obj.CodingForCuda=aBool;
        end

        function ret=getCodingForCuda(obj)
            ret=obj.CodingForCuda;
        end

        function setCodingForOpenCL(obj,aBool)
            obj.CodingForOpenCL=aBool;
        end

        function ret=getCodingForOpenCL(obj)
            ret=obj.CodingForOpenCL;
        end

        function ret=getArch(obj)
            ret=obj.Arch;
        end

        function ret=getNinjaExecName(obj)
            ret=fullfile(matlabroot,'toolbox','shared','coder',...
            'ninja',obj.getArch,['ninja',obj.ExecExt]);
        end

        function setLinker(obj,aGroup,aName)
            obj.(aGroup)=aName;
        end

        function setOutputFileName(obj,aOutputName)
            obj.OutputFileName=aOutputName;
        end

        function ret=getOutputFileName(obj)
            ret=obj.OutputFileName;
        end

        function addSourceFile(obj,aSource,aPath,atIndex)
            obj.Source{atIndex}=aSource;
            obj.SourcePath{atIndex}=aPath;
        end

        function appendFlag(obj,aField,aFlag,delimiter)

            if nargin<4||isempty(delimiter)
                delimiter=' ';
            end
            obj.(aField)=[obj.(aField),delimiter,aFlag];
        end

        function prependFlag(obj,aField,aFlag,delimiter)

            if nargin<4||isempty(delimiter)
                delimiter=' ';
            end
            obj.(aField)=[aFlag,delimiter,obj.(aField)];
        end

        function ret=getFlag(obj,aField)
            ret=obj.(aField);
        end

        function replaceToken(obj,aField,token,aStr)
            obj.(aField)=strrep(obj.(aField),token,aStr);
        end

        function addIncludePath(obj,aInc)
            include=sprintf('%s"%s"',obj.IncludePrefix,aInc);
            cudaInclude=sprintf('%s"%s"',obj.CudaIncludePrefix,aInc);
            obj.appendFlag('CFLAGS',include);
            obj.appendFlag('CXXFLAGS',include);
            obj.appendFlag('CUDAFLAGS',cudaInclude);
        end

        function addDefine(obj,aDef)
            obj.appendFlag('CFLAGS',aDef);
            obj.appendFlag('CXXFLAGS',aDef);
            obj.appendFlag('CUDAFLAGS',aDef);
        end

        function addLibPath(obj,aPath)
            if isempty(aPath)
                return;
            end
            ldflag=sprintf('%s"%s"',obj.LibPathPrefix,aPath);
            obj.appendFlag('LDFLAGS',ldflag);
        end

        function addLinkLibrary(obj,aLib,usePrefix)
            if nargin<3
                usePrefix=true;
            end
            ldflag=[aLib,obj.AddLibSuffix];
            if usePrefix
                ldflag=[obj.AddLibPrefix,ldflag];
            end
            obj.appendFlag('LDFLAGS',ldflag);
        end

        function addLinkObject(obj,aObj)
            if obj.CodingForCuda&&~ispc&&~canNvccDirectLink(aObj)
                obj.appendFlag('LINKOBJS',['-Xlinker ','"',aObj,'"']);
            else
                obj.appendFlag('LINKOBJS',['"',aObj,'"']);
            end
        end

        function generateForCuda(obj,fid)
            fprintf(fid,'cudac = %s\n',obj.CUDAC);
            fprintf(fid,'linkercuda = %s\n',obj.LDCUDA);
            fprintf(fid,'\ncudaflags = %s\n',replaceTokens(obj,obj.CUDAFLAGS));

            fprintf(fid,'rule cudac\n');
            fprintf(fid,'    command = $cudac $cudaflags $in %s$out\n\n',obj.CudaObjNameRule);
            fprintf(fid,'rule linkcuda\n');
            if ispc
                fprintf(fid,'    command = $linkercuda $linkobjs $ldflags %s$out $in\n\n',obj.CudaObjNameRule);
            else
                fprintf(fid,'    command = $linkercuda $in $linkobjs $ldflags\n\n');
            end
        end

        function generate(obj,fid)

            fprintf(fid,'ninja_required_version = 1.3\n');



            obj.RootDir=escapeNormal(obj.RootDir,obj.Kind);
            obj.BuildDir=MinGWPathFix(obj,obj.BuildDir);
            obj.StartDir=escapeNormal(obj.StartDir,obj.Kind);
            obj.MatlabDir=escapeNormal(obj.MatlabDir,obj.Kind);


            fprintf(fid,'\n# Basic folders\n');
            if(ispc&&startsWith(obj.RootDir,"\\"))||...
                obj.CodingForOpenCL


                fprintf(fid,'root = %s\n',obj.RootDir);
            else
                fprintf(fid,'root = .\n');
            end
            fprintf(fid,'builddir = %s\n',obj.BuildDir);
            fprintf(fid,'matlabdir = %s\n',obj.MatlabDir);
            fprintf(fid,'startdir = %s\n',obj.StartDir);

            fprintf(fid,'\n# Toolchain information\n');
            fprintf(fid,'cc = %s\n',obj.CC);
            fprintf(fid,'cxx = %s\n',obj.CXX);
            fprintf(fid,'linker = %s\n',obj.LD);
            fprintf(fid,'linkerxx = %s\n',obj.LDXX);

            fprintf(fid,'\ncflags = %s\n',replaceTokens(obj,obj.CFLAGS));
            fprintf(fid,'\ncxxflags = %s\n',replaceTokens(obj,obj.CXXFLAGS));


            ldFlags=replaceTokens(obj,obj.LDFLAGS);
            if obj.CodingForCuda
                ldFlags=updateLdFlagsForGpuCoder(ldFlags);
            end
            fprintf(fid,'\nldflags = %s\n',ldFlags);
            fprintf(fid,'\nlinkobjs = %s\n',replaceTokens(obj,obj.LINKOBJS));


            fprintf(fid,'\n# Build Rules\n');
            fprintf(fid,'rule cc\n');
            fprintf(fid,'    command = $cc $cflags $in %s$out\n\n',obj.ObjNameRule);
            fprintf(fid,'rule cxx\n');
            fprintf(fid,'    command = $cxx $cxxflags $in %s$out\n\n',obj.ObjNameRule);
            fprintf(fid,'rule link\n');
            if ispc&&obj.Kind~="lcc"
                fprintf(fid,'    command = $linker @$out.rsp $linkobjs $ldflags\n');
                fprintf(fid,'    rspfile = $out.rsp\n');
                fprintf(fid,'    rspfile_content = $in\n\n');
            else
                fprintf(fid,'    command = $linker $in $linkobjs $ldflags\n\n');
            end
            fprintf(fid,'rule linkxx\n');
            fprintf(fid,'    command = $linkerxx $in $linkobjs $ldflags\n\n');

            if obj.CodingForCuda
                generateForCuda(obj,fid);
            end


            fprintf(fid,'# Build\n');
            objFiles=cell(1,numel(obj.Source));
            hasCXX=false;
            hasCuda=false;
            for i=1:numel(obj.Source)
                file=obj.Source{i};
                path=obj.SourcePath{i};
                [~,fileName,ext]=fileparts(file);
                out=MinGWPathFix(obj,fullfile('$builddir',[fileName,obj.ObjExt]));
                out=escapePathList(out);
                objFiles{i}=out;
                in=fullfile(path,file);
                in=replaceTokens(obj,MinGWPathFix(obj,in));
                in=escapeBuildLine(escapePathList(in));



                if obj.CodingForCuda&&strcmp(replaceTokens(obj,path),'$root')
                    rule='cudac';
                    hasCuda=true;
                else
                    switch ext
                    case '.c'
                        rule='cc';
                    case{'.cpp','.cc','.cxx','.c++'}
                        rule='cxx';
                        hasCXX=true;
                    case '.cu'
                        rule='cudac';
                        hasCuda=true;
                    otherwise
                        rule='cc';
                    end
                end
                fprintf(fid,'build %s : %s %s\n',out,rule,in);
            end


            fprintf(fid,'\n# Link\n');

            if hasCuda
                fprintf(fid,'build %s : linkcuda ',fullfile('$root',obj.OutputFileName));
            elseif~hasCXX
                fprintf(fid,'build %s : link ',fullfile('$root',obj.OutputFileName));
            else
                fprintf(fid,'build %s : linkxx ',fullfile('$root',obj.OutputFileName));
            end

            for i=1:numel(objFiles)
                fprintf(fid,'%s ',objFiles{i});
            end


            fprintf(fid,'\n');
        end

        function genSetEnv(obj,fid)
            fprintf(fid,'%s',strtrim(obj.SetEnv));
        end

        function genRunFile(obj,fid,genCompDb)
            ninjaExec=fullfile(matlabroot,'toolbox','shared','coder',...
            'ninja',obj.Arch,['ninja',obj.ExecExt]);
            if ispc
                fprintf(fid,'@echo off\n');
                if~strcmp(obj.Kind,'lcc')
                    fprintf(fid,'call setEnv.bat\n');
                else
                    fprintf(fid,'set MATLAB=%s\n',emlcprivate('emcAltPathName',matlabroot));
                    fprintf(fid,'call "%s"\n',fullfile(matlabroot,'sys',...
                    'lcc64','lcc64','mex','lcc64opts.bat'));
                end
                if genCompDb
                    fprintf(fid,'"%s" -t compdb cc cxx cudac > compile_commands.json\n',ninjaExec);
                end
                fprintf(fid,'"%s" -v %%*\n',ninjaExec);
            else
                if genCompDb
                    fprintf(fid,'"%s" -t compdb cc cxx cudac > compile_commands.json\n',ninjaExec);
                end
                fprintf(fid,'"%s" -v "$@"\n',ninjaExec);
            end
        end

    end
end


function str=replaceTokens(obj,str)
    str=escapeNormal(str,"");
    str=strrep(str,obj.RootDir,'$root');



    str=strrep(str,obj.MatlabDir,'$matlabdir');
    str=strrep(str,obj.StartDir,'$startdir');
    str=strrep(str,'$(MATLAB_ROOT)','$matlabdir');
    str=strrep(str,'$(START_DIR)','$startdir');
    str=strrep(str,'$(BUILD_DIR)','$root');
    str=strrep(str,'$(ARCH)',computer('arch'));
end

function out=escapeNormal(in,kind)
    out=regexprep(in,'(?<![\$])\$(?![\(\$])','$$');
    if ispc&&kind=="unix"
        out=strrep(out,filesep,'/');
    end
end

function out=escapePathList(in)
    out=strrep(in,' ','$ ');
end

function out=escapeBuildLine(in)
    out=strrep(in,':','$:');
end

function str=updateLdFlagsForGpuCoder(str)

    str=strrep(str,' -pthread','');

    str=strrep(str,'-Wl,','-Xlinker ');

    str=[str,' -Xnvlink -w  -Wno-deprecated-gpu-targets'];
    if ispc

        str=strrep(str,'/LIBPATH:','-L');


        str=regexprep(str,'/out:[^\s]*','');




        str=regexprep(str,'(?<!-Xlinker|-Xcompiler)\s+(/[^\s]*)',' -Xlinker $1');


        str=[str,' -Xlinker /NODEFAULTLIB:libcmt.lib'];
    end
end

function result=canNvccDirectLink(aObj)
    result=false;
    [~,~,ext]=fileparts(aObj);
    extsNvccCanLinkDirectly={'.so','.a','.lib','.o','.obj'};
    if any(strcmp(ext,extsNvccCanLinkDirectly))
        result=true;
    end
end

function result=MinGWPathFix(obj,aPath)
    if ispc&&obj.Kind=="unix"
        result=strrep(aPath,filesep,'/');
    else
        result=aPath;
    end
end
