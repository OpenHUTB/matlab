function checkIDList=getID(varargin)






    checkIDList={};
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if strcmp(mdladvObj.CustomTARootID,'_modeladvisor_')||strcmp(mdladvObj.CustomTARootID,'CommandLineRun')
        me=mdladvObj.MAExplorer;
    elseif nargin>0&&strcmp(varargin{1},'MACE')
        me=mdladvObj.ConfigUIWindow;
    else
        me=mdladvObj.CheckLibraryBrowser;
    end

    if isempty(me)&&isempty(mdladvObj.MAExplorer)
        return;
    elseif isempty(me)
        me=mdladvObj.MAExplorer;
    end

    imme=DAStudio.imExplorer(me);
    currentNode=imme.getCurrentTreeNode;
    ans=findCheckIDin(currentNode,{});%#ok<NOANS>
    checkIDList=ans;%#ok<NOANS>
    ans %#ok<NOPRT>


    function checkIDList=findCheckIDin(currentNode,checkIDList)
        if isempty(currentNode)
            return;
        end
        if isa(currentNode,'ModelAdvisor.Task')
            if currentNode.Selected
                checkIDList=[checkIDList,currentNode.MAC];
            end
        else
            for i=1:length(currentNode.ChildrenObj)
                checkIDList=findCheckIDin(currentNode.ChildrenObj{i},checkIDList);
            end
        end