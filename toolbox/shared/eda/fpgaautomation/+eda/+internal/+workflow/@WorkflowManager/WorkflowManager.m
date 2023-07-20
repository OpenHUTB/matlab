classdef WorkflowManager<handle







    properties
        mAutoInterfaceObj=[];
        mXilinxAIObj=[];
        mWorkflowInfo=struct([]);
    end

    methods
        function h=WorkflowManager(varargin)
            h.mAutoInterfaceObj=eda.internal.workflow.TclTM;
            h.mXilinxAIObj=eda.internal.workflow.ApiTM;




            h.getWorkflowData(varargin{:});

        end

        function run(h,varargin)

            [continueOnWarn,hdlcParams]=h.getInputParam(varargin{:});

            h.checkLicense;

            disp(' ');
            dispFpgaMsg('Begin FPGA Workflow');
            disp(' ');


            initialParam=h.mWorkflowInfo.userParam;


            [currentWorkflow,success]=h.validateWorkflow(continueOnWarn);
            if~success
                return;
            end


            h.generateHDL(hdlcParams);


            h.mWorkflowInfo.userParam.workflow='Project generation';


            h.generateDCM;
            h.generateUCF;


            status=h.runWorkflow(currentWorkflow);


            h.finishWorkflow(currentWorkflow,initialParam);


            if~status
                dispFpgaMsg('FPGA Workflow Complete.');
            else
                dispFpgaMsg('FPGA Project Generation Failed.');
            end
        end


        function[continueOnWarn,hdlcParams]=getInputParam(h,varargin)
            continueOnWarn=0;
            hdlcParams={};


            if nargin>1
                continueOnWarn=varargin{1};
                if nargin>2
                    hdlcParams=varargin{2};
                end
            end
        end


        function checkLicense(h)
            if~(builtin('license','checkout','EDA_Simulator_Link'))
                error(message('EDALink:WorkflowManager:WorkflowManager:noedalinklicense'));
            end
            h.checkSupportedOS;
        end


        function checkSupportedOS(h)
            b=istdkfpgainstalled;
            if~b
                error(message('EDALink:WorkflowManager:WorkflowManager:notdkfpgainstalled'));
            end
        end


        function[currentWorkflow,success]=validateWorkflow(h,continueOnWarn)
            userParam=h.mWorkflowInfo.userParam;

            if strcmpi(userParam.projectGenOutput,'ISE project')

                if userParam.assocExist

                    currentWorkflow='update';
                    success=h.validateUpdateProject(continueOnWarn);
                elseif strcmpi(userParam.associate,'New ISE project')

                    currentWorkflow='create';
                    success=h.validateCreateProject(continueOnWarn);
                else

                    currentWorkflow='addexist';
                    success=h.validateAddExistingProject(continueOnWarn);
                end
            else

                currentWorkflow='gentcl';
                success=h.validateGenerateTcl;
            end


            if success


                h.validateGenerateDCM;
            end

        end


        function status=runWorkflow(h,currentWorkflow)
            switch currentWorkflow
            case 'create'
                status=h.createProject;
            case 'addexist'
                status=h.addExistingProject;
            case 'update'
                status=h.updateProject;
            case 'gentcl'
                status=h.generateTclScript;
            otherwise
                error(message('EDALink:WorkflowManager:WorkflowManager:undefinedworkflow'));
            end
            if status~=0
                return;
            end
        end


        function finishWorkflow(h,currentWorkflow,initialParam)
            switch currentWorkflow
            case 'create'
                h.setWorkflowData(initialParam,'associate');
            case 'addexist'
                h.setWorkflowData(initialParam,'associate');
                if h.mWorkflowInfo.userParam.importSettings
                    h.setWorkflowData(initialParam,'import');
                end
            case 'update'
                if h.mWorkflowInfo.userParam.importSettings
                    h.setWorkflowData(initialParam,'import');
                end
            otherwise

            end
        end



        function makeHdlDir(h)
            [s,mess,messid]=mkdir(h.mWorkflowInfo.hdlcData.codegenDir);
            if s==0
                switch lower(messid)
                case 'matlab:mkdir:directoryexists',
                case 'matlab:mkdir:oserror',
                    error(message('EDALink:WorkflowManager:WorkflowManager:directoryfailure',h.mWorkflowInfo.hdlcData.codegenDir));
                otherwise
                    error(message('EDALink:WorkflowManager:WorkflowManager:otherdirectoryfailure',mess));
                end
            end
        end



        function makeProjectDir(h)
            projectDir=h.mWorkflowInfo.userParam.projectLoc;
            [s,mess,messid]=mkdir(projectDir);
            if s==0
                switch lower(messid)
                case 'matlab:mkdir:directoryexists',
                    error(message('EDALink:WorkflowManager:WorkflowManager:directoryexits',projectDir));
                case 'matlab:mkdir:oserror',
                    error(message('EDALink:WorkflowManager:WorkflowManager:directoryfailure',projectDir));
                otherwise

                    error(message('EDALink:WorkflowManager:WorkflowManager:otherdirectoryfailure',mess));
                end
            end
        end



        function hdlcFullDir=getHdlFullDir(h)
            if~exist(h.mWorkflowInfo.hdlcData.codegenDir,'dir')
                error(message('EDALink:WorkflowManager:WorkflowManager:nocodegendir'));
            end

            orgDir=pwd;
            cd(h.mWorkflowInfo.hdlcData.codegenDir);
            hdlcFullDir=pwd;
            cd(orgDir);
        end


        function filepath=getGenFilePath(h,targetdir,filelist)

            for n=1:length(filelist)
                filepath{n}=strrep(fullfile(targetdir,filelist{n}),'\','/');
            end
        end



        function writeTclScript(h,tclFile,tclStr,tclErrMsg,internalUse)
            if nargin<5
                internalUse=true;
            end


            hver=ver('matlab');
            header=['# Generated by ',hver.Name,' ',hver.Version,char(10)];




            fid=fopen(tclFile,'w+');
            if fid==-1
                errormsg='Unable to open Tcl script file for writing.';
                if nargin==4
                    errormsg=[tclErrMsg,blanks(1),errormsg];
                end
                error(message('EDALink:WorkflowManager:WorkflowManager:opentclfile',errormsg));
            end

            fprintf(fid,'%s',[header,tclStr]);
            fclose(fid);
        end



        function xtclRtn=executeTclScript(h,tclFile,tclErrMsg)

            tclsh=h.mAutoInterfaceObj.getTclShell;
            [xtclStat,xtclRtn]=system([tclsh,' ',tclFile]);

            if xtclStat
                errormsg='Unable to execute Tcl script.';
                if nargin==3
                    errormsg=[tclErrMsg,blanks(1),errormsg];
                end
                if~isempty(xtclRtn)
                    errormsg=[errormsg,char(10)...
                    ,'ISE returned the following error message:'...
                    ,char(10),char(10),xtclRtn,char(10)];
                end
                error(message('EDALink:WorkflowManager:WorkflowManager:runtclfile',errormsg));
            end
        end




        function writeAssocInfo(h,projectName,addedFileList)
            assocMdlPath=get_param(h.mWorkflowInfo.hdlcData.modelName,'FileName');
            wInfoFile=[projectName,h.mWorkflowInfo.tdkParam.assocInfoName];
            save(wInfoFile,'assocMdlPath','addedFileList');
        end



        function assocInfo=readAssocInfo(h,projectLoc,projectName)
            wInfoFile=[projectName,h.mWorkflowInfo.tdkParam.assocInfoName];
            wInfoFile=fullfile(projectLoc,wInfoFile);
            if~exist(wInfoFile,'file')
                assocInfo.model='';
                assocInfo.files='';
            else
                w=load(wInfoFile,'assocMdlPath','addedFileList');
                if isfield(w,'assocMdlPath')
                    assocInfo.model=w.assocMdlPath;
                else
                    assocInfo.model='';
                end
                if isfield(w,'addedFileList')
                    assocInfo.files=w.addedFileList;
                else
                    assocInfo.files='';
                end
            end
        end


        function projectPath=getProjectPath(h,loc,name,ext)
            projectPath.fileName=[name,ext];
            projectPath.filePath=fullfile(loc,[name,ext]);
        end


        function projectParts=getProjectParts(h,projectPath)
            [loc,name,ext]=fileparts(projectPath);
            projectParts.loc=loc;
            projectParts.file=[name,ext];
            projectParts.name=name;
            projectParts.ext=ext;
        end




        function deleteExistingProject(h)
            userParam=h.mWorkflowInfo.userParam;
            tdkParam=h.mWorkflowInfo.tdkParam;

            projPath=h.getProjectPath(userParam.projectLoc,...
            userParam.projectName,tdkParam.projectExt);
            if exist(projPath.fileName,'file')
                delete(projPath.fileName);
            end

            projPath=h.getProjectPath(userParam.projectLoc,...
            userParam.projectName,tdkParam.projectOldExt);
            if exist(projPath.fileName,'file')
                delete(projPath.fileName);
            end
        end


        function iseDetected=isIseRunning(h)

            tclsh=h.mAutoInterfaceObj.getTclShell;

            if ispc
                tclsh=[tclsh,'.exe'];
                ise='ise.exe';
            else
                ise='_pn';
            end

            if lookforprocess(ise)||lookforprocess(tclsh)
                iseDetected=true;
            else
                iseDetected=false;
            end
        end

    end

end
