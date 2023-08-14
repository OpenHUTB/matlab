function taskIDList=getCheckInstanceIDs(varargin)



    if nargin==1
        isRightClickMenu=varargin{1};
    else
        isRightClickMenu=false;
    end

    taskIDList={};
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;


    if any(strcmp(mdladvObj.CustomTARootID,{'_modeladvisor_','CommandLineRun'}))


        me=mdladvObj.MAExplorer;

        if isempty(me)&&isempty(mdladvObj.MAExplorer)
            return;
        else
            imme=DAStudio.imExplorer(me);


            currentNode=imme.getCurrentTreeNode;
            taskIDList=findTaskIDs(currentNode,taskIDList);
        end
    end

    if isRightClickMenu


        ans=taskIDList;%#ok<NOANS>
        ans %#ok<NOANS,NOPRT>
    end
end


function taskIDList=findTaskIDs(currentNode,taskIDList)
    if isempty(currentNode)
        return;
    end

    if isa(currentNode,'ModelAdvisor.Task')
        if currentNode.Selected
            taskIDList=[taskIDList,currentNode.ID];
        end
    else
        for i=1:length(currentNode.ChildrenObj)
            taskIDList=findTaskIDs(currentNode.ChildrenObj{i},taskIDList);
        end
    end
end