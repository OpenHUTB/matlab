




classdef WorkflowManager<handle

    properties(SetAccess=private,GetAccess=private)

    end


    methods(Static)

        function updateWorkflow(mdlAdvObj)



            system=mdlAdvObj.System;
            hModel=bdroot(system);
            hDriver=hdlmodeldriver(hModel);
            hDI=hDriver.DownstreamIntegrationDriver;
            hdlwaDriver=hDriver.getWorkflowAdvisorDriver;




            taskList=hdlwa.getWorkflowTaskList('DownstreamObject',hDI);
            hdlwa.WorkflowManager.buildWorkflowTaskTree(taskList);


        end
    end


    methods(Static)



        function buildWorkflowTaskTree(taskList)
            curProc=[];
            curTask=[];
            curLvl=0;
            curNum='';



            if isempty(taskList)
                return;
            end


            for i=1:length(taskList)
                taskLvl=taskList{i}{1};
                taskID=taskList{i}{2};


                [taskObj,curNum]=hdlwa.WorkflowManager.updateTaskDisplayName(taskLvl,curLvl,curNum,taskID);


                while~isempty(curProc)&&taskLvl<curLvl
                    curProc=curProc.ParentObj;
                    curLvl=curLvl-1;
                end

                if isa(taskObj,'ModelAdvisor.Procedure')
                    curProc=hdlwa.WorkflowManager.addProc(taskObj,curProc);
                else
                    curTask=hdlwa.WorkflowManager.addTask(taskObj,curTask,curProc);
                end


                curLvl=taskLvl;
            end


            hdlwa.WorkflowManager.refreshTaskTree;

        end



        function curProc=addProc(procObj,curProc)


            if~isempty(curProc)&&~ismember(procObj.ID,curProc.Children)
                curProc.ChildrenObj{end+1}=procObj;
                curProc.Children{end+1}=procObj.ID;
            end


            procObj.ChildrenObj={};
            procObj.Children={};


            curProc=procObj;

        end



        function curTask=addTask(taskObj,curTask,curProc)


            if~isempty(curTask)
                curTask.NextInProcedureCallGraph=taskObj;


                if ismember(char(curTask.state),{char(ModelAdvisor.CheckStatus.Failed),char(ModelAdvisor.CheckStatus.NotRun)})
                    taskObj.updateStates(ModelAdvisor.CheckStatus.NotRun);
                    taskObj.Enable=false;
                end
            end
            taskObj.PreviousInProcedureCallGraph=curTask;
            taskObj.NextInProcedureCallGraph=[];



            curProc.ChildrenObj{end+1}=taskObj;
            curProc.Children{end+1}=taskObj.ID;

            curTask=taskObj;
        end



        function refreshTaskTree
            mdlAdvObj=hdlwa.getHdladvObj;
            hMAExplorer=mdlAdvObj.MAExplorer;
            if~isempty(hMAExplorer)&&ismethod(hMAExplorer,'getRoot')
                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('HierarchyChangedEvent',hMAExplorer.getRoot);
            end
        end




        function[taskObj,curNum]=updateTaskDisplayName(taskLvl,curLvl,curNum,taskID)
            mdlAdvObj=hdlwa.getHdladvObj;
            system=mdlAdvObj.System;
            hModel=bdroot(system);
            hDriver=hdlmodeldriver(hModel);
            hDI=hDriver.DownstreamIntegrationDriver;
            hdlwaDriver=hDriver.getWorkflowAdvisorDriver;

            taskObj=hdlwaDriver.getTaskObj(taskID);
            s=taskObj.DisplayName;


            if(strcmp(taskID,'com.mathworks.HDL.WorkflowAdvisor'))
                curNum='';
                return;
            end


            curNum=hdlwa.WorkflowManager.createTaskNumber(taskLvl,curLvl,curNum);
            taskObj.DisplayName=regexprep(s,'^[\d.]+',[curNum,'.']);

        end

        function num=createTaskNumber(taskLvl,curLvl,curNum)









            idx=regexp(curNum,'(\d*)$');


            if isempty(idx)
                count=0;
                base='';
            else
                count=str2double(curNum(idx:end));
                base=curNum(1:idx-2);
            end





            if taskLvl>curLvl
                base=curNum;
                count=1;
            elseif taskLvl==curLvl
                count=count+1;
            elseif taskLvl<curLvl
                num=hdlwa.WorkflowManager.createTaskNumber(taskLvl,curLvl-1,base);
                return;
            end



            if isempty(base)
                num=sprintf('%d',count);
            else
                num=sprintf('%s.%d',base,count);
            end

        end

    end
end



