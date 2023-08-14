classdef(HandleCompatible)UpdateSysObjBuildInfo<...
    coder.ExternalDependency %#codegen






    methods
        function this=UpdateSysObjBuildInfo
            coder.allowpcode('plain');
        end
    end
    methods(Static,Hidden)

        function bName=getDescriptiveName(~)
            bName='DSP Halide Library';
        end

        function tf=isSupportedContext(buildContext)
            if buildContext.isMatlabHostTarget()
                tf=true;
            else
                error('DSP Halide Library not available for this target');
            end
        end

        function updateBuildInfo(buildInfo,buildContext)

            coderTarget=lower(buildContext.CodeGenTarget);
            if dsp.enhancedsim.IsSysObjSimInCodeGen(coderTarget)==false
                return;
            end

            [~,linkLibExt,execLibExt,~]=buildContext.getStdLibInfo();
            group='';

            hdrFilePath=fullfile(matlabroot,'toolbox','dsp',...
            'halidesim','include');
            libName='libmwdsp_halidesim';
            buildInfo.addIncludePaths(hdrFilePath,group);

            if ispc
                lang=buildContext.TargetLang;
                isGNU=strcmp(mex.getCompilerConfigurations(lang).Manufacturer,'GNU');
                if isGNU
                    linkPath=fullfile(matlabroot,'extern','lib',...
                    'win64','mingw64');
                else
                    linkPath=fullfile(matlabroot,'extern','lib',...
                    'win64','microsoft');
                end
            elseif ismac
                linkPath=fullfile(matlabroot,'bin','maci64');
            else
                linkPath=fullfile(matlabroot,'bin','glnxa64');
            end
            linkFiles=strcat(libName,linkLibExt);
            linkPriority=1000;
            linkPrecompiled=false;
            linkLinkOnly=true;
            buildInfo.addLinkObjects(linkFiles,linkPath,...
            linkPriority,linkPrecompiled,linkLinkOnly,group);


            nbFiles=strcat(libName,execLibExt);
            nbFilesPath=fullfile(matlabroot,'bin',lower(computer('arch')));
            buildInfo.addNonBuildFiles(nbFiles,nbFilesPath,group);
        end
    end
end