classdef HookBuildOpts




    properties(Transient=true,SetAccess=private)
codeWasUpToDate
    end

    properties(Transient=true,Hidden=true)
buildName
sysTargetFile
    end

    properties(Transient=true,SetAccess=private,Hidden=true)
TargetLangExt
AutosarTopCodegenFolder
AutosarTopComponent
generateCodeOnly
isCpp
mem_alloc
modelrefInfo
modules
solverMode
    end

    methods(Access=public,Hidden=true)
        function this=HookBuildOpts...
            (lTargetLangExt,...
            lBuildName,...
            mem_alloc,...
            sysTargetFile,...
            solverMode,...
            modules,...
            isCpp,...
            generateCodeOnly,...
            codeWasUpToDate,...
            modelrefInfo,...
            arTopCodegenFolder,...
            arTopComponent)

            this.TargetLangExt=lTargetLangExt;
            this.buildName=lBuildName;
            this.mem_alloc=mem_alloc;
            this.sysTargetFile=sysTargetFile;
            this.solverMode=solverMode;
            this.modules=modules;
            this.isCpp=isCpp;
            this.generateCodeOnly=generateCodeOnly;
            this.codeWasUpToDate=codeWasUpToDate;
            this.modelrefInfo=modelrefInfo;
            this.AutosarTopCodegenFolder=arTopCodegenFolder;
            this.AutosarTopComponent=arTopComponent;

        end
    end
end
