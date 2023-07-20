classdef WorkflowList<hdlturnkey.plugin.PluginListBase




    properties(Access=protected)





        CustomizationFileName='hdlcoder_workflow_registration';

    end

    methods
        function obj=WorkflowList()

            obj.buildWorkflowList;
        end

        function buildWorkflowList(obj)


            obj.clearWorkflowList;




            obj.searchWorkflowRegistrationFile;

        end

    end

    methods(Static)
        function hWorkflowList=getInstance(action)








            persistent localObj
            if nargin==1&&strcmpi(action,'reload')
                localObj=[];
            end
            if isempty(localObj)
                localObj=hdlworkflow.WorkflowList;
            end
            hWorkflowList=localObj;
        end
    end


    methods

        function workflowNameList=getWorkflowNameList(obj)

            workflowNameList=obj.getNameList;
        end

        function isIn=isInWorkflowList(obj,workflowName)
            isIn=obj.isInList(workflowName);
        end

        function hWorkflow=getWorkflow(obj,workflowName)



            [isIn,hWorkflow]=obj.isInList(workflowName);
            if~isIn
                error(message('hdlcommon:workflow:InvalidWorkflowName',workflowName));
            end
        end

    end


    methods

        function nodes=defineHDLWorkflowAdvisorTasks(obj,nodes,utilTaskTitle)


            workflowNameList=obj.getWorkflowNameList;
            for ii=1:length(workflowNameList)
                workflowName=workflowNameList{ii};
                hWorkflow=obj.getWorkflow(workflowName);
                nodes=hWorkflow.hdlwa_defineTasks(nodes,utilTaskTitle);
            end
        end

        function recordCellArray=defineHDLWorkflowAdvisorChecks(obj,recordCellArray,publishFailedMessage,publishResults,utilDisplayResult)


            workflowNameList=obj.getWorkflowNameList;
            for ii=1:length(workflowNameList)
                workflowName=workflowNameList{ii};
                hWorkflow=obj.getWorkflow(workflowName);
                recordCellArray=hWorkflow.hdlwa_defineChecks(recordCellArray,publishFailedMessage,publishResults,utilDisplayResult);
            end
        end

    end


    methods(Access=protected)
        function clearWorkflowList(obj)
            obj.initList;
        end

        function addWorkflow(obj,hWorkflow)



            workflowName=hWorkflow.WorkflowName;


            [isIn,hExistingWorkflow]=isInList(obj,workflowName);
            if isIn
                existingFilePath=hExistingWorkflow.getAbsolutePath;
                error(message('hdlcommon:workflow:DuplicatedWorkflowName',workflowName,existingFilePath));
            else
                obj.insertPluginObject(workflowName,hWorkflow);
            end
        end

        function searchWorkflowRegistrationFile(obj)




            workflowRegFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(workflowRegFiles)
                workflowRegFile=workflowRegFiles{ii};
                [workflowRegFileFolder,workflowRegFileName,~]=fileparts(workflowRegFile);

                try



                    cd(workflowRegFileFolder);
                    hWorkflow=eval(workflowRegFileName);



                    obj.validateWorkflowObject(hWorkflow,workflowRegFileName);


                catch ME

                    obj.reportInvalidPlugin(workflowRegFile,ME.message);
                    cd(currentFolder);
                    continue;

                end


                obj.addWorkflow(hWorkflow);


                cd(currentFolder);


            end
        end

        function validateWorkflowObject(~,hWorkflow,workflowRegFileName)


            if~isa(hWorkflow,'hdlworkflow.Workflow')
                error(message('hdlcommon:workflow:InvalidWorkflowObject',workflowRegFileName));
            end
        end

    end
end


