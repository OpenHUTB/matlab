classdef(Hidden=true)Builder<linkfoundation.pil.Builder




    properties(SetAccess='private',GetAccess='private')

        buildConfig=[];
        model=[];
    end

    methods

        function this=Builder(componentArgs,...
            targetApplicationFramework)
            narginchk(2,2);

            this@linkfoundation.pil.Builder(componentArgs,...
            targetApplicationFramework);
            this.buildConfig=targetfoundation.Utilities.getBuildConfig(...
            componentArgs.getParam('projectOptions'));
        end


        function ProcLink_Obj=getLinkObject(this)
            ProcLink_Obj=[];


            pilInfo=this.pilGetTargetData;
            if isempty(pilInfo)

                ProcLink_Obj=this.getCachedAutomationHandle();
            else

                assert(false,DAStudio.message('ERRORHANDLER:pjtgenerator:UnsupportedPILApproachForMakefile'));
            end
        end
    end
    methods(Access='protected')

        function exe=getExecutable(this,buildInfo)%#ok<INUSD>
            narginchk(2,2);

            componentArgs=this.getComponentArgs;

            if this.isModelBlockPIL(componentArgs)
                if(this.isMakeFile())
                    buildDir=fullfile(this.getMakefileBuildDir(),this.buildConfig);
                else
                    buildDir=fullfile([getProjectName(this),'_pil'],this.buildConfig);
                end
                srcName=[this.getComponentArgs.getComponentCodeName,'_pil'];
            else
                buildDir=fullfile(getProjectName(this),this.buildConfig);
                srcName=this.getComponentArgs.getComponentCodeName;
            end
            exe=fullfile(buildDir,[srcName,this.getLinkObject.ide_getFileExt('program')]);
        end

        function pjtName=getProjectName(this)
            narginchk(1,1);
            linkObject=this.getLinkObject;
            buildDir=linkObject.cd();
            srcName=this.getComponentArgs.getComponentCodeName;
            pjtName=fullfile(buildDir,srcName);
        end



        function setProjectOptions(this,buildInfo)
            ProcLink_Obj=this.getLinkObject();
            try
                includePaths=getIncludePaths(buildInfo,true);
                [defines,defineNames,defineValues]=getDefines(buildInfo);
                linkFlags=getLinkFlags(buildInfo);
                strng=[];


                if~isempty(includePaths)
                    for k=1:length(includePaths)
                        if~isempty(includePaths{k})
                            strng=[strng,'-I"',includePaths{k},'" '];%#ok<AGROW>
                        end
                    end
                end
                if~isempty(defines)
                    for j=1:length(defines)

                        strng=[strng,' -D"',defineNames{j},'=',defineValues{j},'"'];%#ok<AGROW>
                    end
                end

                newopt=regexprep(strng,'\\','\/');
                ProcLink_Obj.addbuildopt('Compiler',newopt);
                if~isempty(linkFlags)
                    flags=[];
                    for j=1:length(linkFlags)
                        flags=[flags,linkFlags{j}];%#ok<AGROW>
                    end
                    ProcLink_Obj.addbuildopt('Linker',flags);
                end
            catch setoptException
                rethrow(setoptException);
            end
        end
    end

    methods(Access='private')
    end
end


