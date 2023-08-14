

classdef SlCodeMetrics<handle
    properties(SetAccess=private,Hidden=true)
        ReportDir='';
        ReportFileName='';
    end
    properties(SetAccess=private)
        ModelName=[];
        BuildDir='';
    end
    properties(Hidden=true,SetAccess=protected)
        modifiedTimeStamp=[];
        bGenHyperlink=false;
        bInBuildProcess=false;
        displayModelName=[];
        sourceSubsystem=''
    end
    properties(SetAccess=private,Hidden=true,Transient=true)
        configsetObj=[];
    end
    methods(Abstract)
        emitHTML(slcm,rptFileName);
    end

    methods
        function slcm=SlCodeMetrics(tmpModelName,buildDir,sourceSubsystem)
            if nargin~=3
                DAStudio.error('RTW:report:invalidNumOfArgs');
            end
            slcm.ModelName=[];
            slcm.displayModelName=[];
            slcm.BuildDir='';
            slcm.ReportDir='';
            slcm.ReportFileName='';
            slcm.modifiedTimeStamp=[];
            slcm.bGenHyperlink=false;
            slcm.bInBuildProcess=false;
            slcm.sourceSubsystem=sourceSubsystem;
            modelName=strtok(sourceSubsystem,'/:');
            root=slroot;
            activeModel=tmpModelName;

            if root.isValidSlObject(activeModel)

                modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(activeModel);
                if~isempty(modelCodegenMgr)
                    slcm.bInBuildProcess=true;
                    slcm.bGenHyperlink=true;
                end


                ssH=rtwprivate('getSourceSubsystemHandle',tmpModelName);
                if~isempty(ssH)
                    modelName=get_param(bdroot(ssH),'Name');
                else
                    modelName=tmpModelName;
                end

                slcm.configsetObj=getActiveConfigSet(activeModel);
            elseif isempty(modelName)
                modelName=tmpModelName;
            end
            slcm.ModelName=modelName;
            slcm.displayModelName=tmpModelName;
            slcm.BuildDir=buildDir;
        end

        function set.BuildDir(slcm,buildDir)

            if exist(fullfile(pwd,buildDir),'dir')
                slcm.BuildDir=fullfile(pwd,buildDir);
            elseif exist(buildDir,'dir')
                slcm.BuildDir=buildDir;
            else
                slcm.BuildDir=buildDir;
                DAStudio.error('RTW:utility:invalidPath',buildDir);
            end
        end

        function reportDir=get.ReportDir(slcm)
            if isempty(slcm.ReportDir)
                reportDir=fullfile(slcm.BuildDir,'html');
            else
                reportDir=slcm.ReportDir;
            end
        end

        function reportFileName=get.ReportFileName(slcm)
            if isempty(slcm.ReportFileName)
                if isempty(slcm.displayModelName)
                    mdlName=slcm.ModelName;
                else
                    mdlName=slcm.displayModelName;
                end
                reportFileName=[mdlName,'_metrics.html'];
            else
                reportFileName=slcm.ReportFileName;
            end
        end

        function ret=getDisplayModelName(slcm)
            if~isempty(slcm.displayModelName)
                ret=slcm.displayModelName;
            else
                ret=slcm.ModelName;
            end
        end

        function configsetObj=get.configsetObj(slcm)

            if~isa(slcm.configsetObj,'Simulink.ConfigSet')
                load_system(slcm.ModelName);
                slcm.configsetObj=getActiveConfigSet(slcm.ModelName);
            end
            configsetObj=slcm.configsetObj;
        end
    end
end


