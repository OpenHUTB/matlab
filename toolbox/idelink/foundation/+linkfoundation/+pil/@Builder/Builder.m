classdef(Hidden=true)Builder<rtw.connectivity.Builder





    methods

        function this=Builder(componentArgs,...
            targetApplicationFramework)
            narginchk(2,2);


            this@rtw.connectivity.Builder(componentArgs,...
            targetApplicationFramework);
        end
    end

    properties(Access='protected')
        mAutomationHandle=[];
    end

    methods(Access='protected')



        function automationHandle=getCachedAutomationHandle(this)
            if(isempty(this.mAutomationHandle))
                if this.isMakeFile()
                    this.mAutomationHandle=linkfoundation.xmakefile.XMakefile();
                else

                    NP=load(this.getLinkComponentBuildInfoPath());
                    ProjectBuildInfo=NP.ProjectBuildInfo;

                    AR=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
                    funcHandle=AR.getAutomationFactoryHandle(ProjectBuildInfo.mAdaptorName);

                    this.mAutomationHandle=funcHandle(ProjectBuildInfo);
                end
            end

            automationHandle=this.mAutomationHandle;
        end

        function isMake=isMakeFile(this)
            buildFormat=this.getComponentArgs.getParam('buildFormat');
            isMake=strcmpi(buildFormat,'Makefile');
        end

        function buildDir=getMakefileBuildDir(this)
            assert(this.isMakeFile());
            buildDir=this.getComponentArgs.getApplicationCodePath;
        end


        function buildInfo=getComponentIntegrationBuildInfo(this,buildInfo)
            narginchk(2,2);

            if this.isModelBlockPIL(this.getComponentArgs)


                linkObject=this.getLinkObject;


                np=load(this.getLinkComponentBuildInfoPath());
                ProjectBuildInfo=np.ProjectBuildInfo;


                buildInfo.Src.Files=[];








                silHostObjDir=fullfile(this.getComponentArgs.getComponentCodePath,...
                rtw.connectivity.Utils.getSilHostObjSubDir);
                pilFilesToAdd=fullfile(silHostObjDir,'pilFilesToAdd.txt');
                if exist(pilFilesToAdd,'file')
                    fid=fopen(pilFilesToAdd);
                    additionalFilesToAdd=[];
                    while 1
                        tline=fgetl(fid);
                        if~ischar(tline),break,end
                        additionalFilesToAdd{end+1}=tline;%#ok<AGROW>
                    end
                    fclose(fid);
                    additionalFilesToAdd=RTW.unique(additionalFilesToAdd);
                    ProjectBuildInfo.mPilSupportFiles=[ProjectBuildInfo.mPilSupportFiles,additionalFilesToAdd];
                end
                buildInfo.addSourceFiles(ProjectBuildInfo.mPilSupportFiles);



                buildInfo.addCompileFlags('-g');


                [apppath,appfile,appext]=fileparts(ProjectBuildInfo.mProjectName);
                ProjectBuildInfo.mProjectName=fullfile(apppath,[appfile,'_pil',appext]);


                [apppath,appfile]=fileparts(ProjectBuildInfo.mBinaryName);
                ProjectBuildInfo.mBinaryName=fullfile(apppath,[appfile,'_pil',linkObject.ide_getFileExt('program')]);


                ProjectBuildInfo.mBuildAction='Build';


                for i=1:length(ProjectBuildInfo.mReferencedModelLibs)
                    [path,name,ext]=fileparts(ProjectBuildInfo.mReferencedModelLibs{i});
                    buildInfo.addLinkObjects([name,ext],path);
                end


                save(this.getLinkPILComponentBuildInfoPath(),'ProjectBuildInfo');

            else

                buildInfo=RTW.BuildInfo;
            end
        end

        function projectBuildInfoPath=getLinkComponentBuildInfoPath(this)
            narginchk(1,1);
            projectBuildInfoPath=fullfile(this.getComponentArgs.getComponentCodePath,...
            'projectBuildInfo.mat');
        end

        function projectBuildInfoPath=getLinkPILComponentBuildInfoPath(this)
            narginchk(1,1);
            projectBuildInfoPath=fullfile(this.getComponentArgs.getApplicationCodePath,...
            'projectBuildInfo_pil.mat');
        end


        function pjtName=getProjectName(this)
            narginchk(1,1);
            buildDir=this.getComponentArgs.getComponentCodePath;
            srcName=this.getComponentArgs.getComponentCodeName;
            pjtName=fullfile(buildDir,srcName);
        end


        function build(this,buildInfo)
            narginchk(2,2);


            linkObject=this.getLinkObject;

            if this.isModelBlockPIL(this.getComponentArgs)


                np=load(this.getLinkPILComponentBuildInfoPath());
                ProjectBuildInfo=np.ProjectBuildInfo;


                ProjectBuildInfo.mBuildInfo=buildInfo;


                save(this.getLinkPILComponentBuildInfoPath(),'ProjectBuildInfo');


                curfolder=cd(this.getComponentArgs.getApplicationCodePath);
                linkObject.emitProject(ProjectBuildInfo);
                cd(curfolder);

            else

                projectName=this.getProjectName();
                try
                    linkObject.activate(projectName,'project');
                catch %#ok<CTCH>
                    linkObject.open(projectName,'project');
                end


                sourceFiles=getSourceFiles(buildInfo,true,true);
                warn_status=warning;
                warning off;%#ok<WNOFF>
                for k=1:length(sourceFiles)
                    try
                        linkObject.add(sourceFiles{k});
                    catch %#ok<CTCH>

                    end
                end
                warning(warn_status);


                this.setProjectOptions(buildInfo);

            end


            disp('### Building PIL Project...');
            curfolder=[];
            try
                curfolder=cd(this.getComponentArgs.getApplicationCodePath);
                linkObject.build;
                cd(curfolder);
            catch ex
                cd(curfolder);
                rethrow(ex);
            end

            disp('### Building PIL Project Completed...');
        end



        function setProjectOptions(this)%#ok<MANU>

        end


        function pilInfo=pilGetTargetData(this)
            pilInfo=[];
            pilConfigFile=this.getTargetConfigFile;

            if(~isempty(pilConfigFile))
                fid=fopen(pilConfigFile);
                if fid==-1
                    error(message('ERRORHANDLER:utils:CannotOpenFile',pilConfigFile));
                end
                while 1
                    tline=fgetl(fid);
                    if~ischar(tline)
                        break;
                    else
                        eval(['pilInfo.',tline]);
                    end
                end
                if~exist('pilInfo','var')
                    error(message('ERRORHANDLER:utils:PilInfoNotExtracted'));
                end
                fclose(fid);
            end
        end
    end

    methods(Abstract=true)

        linkObject=getLinkObject(this);
    end

    methods(Access='private')
        function pilTgtFile=getTargetConfigFile(this)



            pilTgtFile=fullfile(this.getComponentArgs.getComponentCodePath,...
            [this.getComponentArgs.getComponentCodeName,'_pilinfo','.dat']);


            if exist(pilTgtFile,'file')~=2,
                pilTgtFile=[];
            end
        end
    end

    methods(Static=true)

        function isModelBlockPIL=isModelBlockPIL(componentArgs)
            isModelBlockPIL=false;

            [rootModel,systemPath]=strtok(componentArgs.getComponentPath,'/');
            if isempty(systemPath)

                buildDirInfo=RTW.getBuildDir(rootModel);
                modelRefRelativeBuildDir=buildDirInfo.ModelRefRelativeBuildDir;
                if~isempty(strfind(componentArgs.getComponentCodePath,modelRefRelativeBuildDir))
                    isModelBlockPIL=true;
                end
            end
        end
    end

end


