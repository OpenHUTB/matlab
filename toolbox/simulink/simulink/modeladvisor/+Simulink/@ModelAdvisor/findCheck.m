function findCheck(varargin)




    persistent searchStr;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if strcmp(varargin{1},'MA')
        me=mdladvObj.MAExplorer;
        root=mdladvObj.TaskAdvisorRoot;
    elseif strcmp(varargin{1},'MACE')
        me=mdladvObj.ConfigUIWindow;
        root=mdladvObj.ConfigUIRoot;
    else
        me=mdladvObj.CheckLibraryBrowser;
        root=mdladvObj.CheckLibraryRoot;
    end

    imme=DAStudio.imExplorer(me);
    tb=me.userData.toolbar;

    if strcmp(varargin{2},'down')
        direction=1;
        if~tb.visible
            tb.visible=1;
            return;
        end
    elseif strcmp(varargin{2},'up')
        direction=-1;
    end

    searchComboboxHandle=me.UserData.filterCriteriaComboBoxWidget;
    findStr=strtrim(searchComboboxHandle.getCurrentText);

    if isempty(findStr)
        me.UserData.findText.setText('');
        return;
    end

    if~strcmp(searchStr,findStr)
        me.UserData.filterCriteriaComboBoxWidget.insertItems(0,findStr);
    end
    searchStr=findStr;


    findStr=strrep(findStr,'*','.*');
    findStr=strrep(findStr,'?','.?');
    findStr=strrep(findStr,'..','.');
    findStr=strrep(findStr,'..','.');
    findStr=strrep(findStr,')','\)');
    findStr=strrep(findStr,'(','\(');
    findStr=strrep(findStr,'$','\$');
    findStr=strrep(findStr,'+','\+');
    findStr=strrep(findStr,'^','\^');
    findStr=strrep(findStr,'[','\[');

    [currentNodeFlag,foundList]=findin(root,findStr,imme,[],0,direction);

    if~isempty(foundList)
        me.UserData.findText.setText('');
        if(currentNodeFlag>length(foundList))
            currentNodeFlag=1;
        elseif(currentNodeFlag==0)
            currentNodeFlag=length(foundList);
        end
        if(currentNodeFlag==-1)
            currentNodeFlag=length(foundList);
        end
        loc_selectTreeViewNode(imme,foundList(currentNodeFlag));
        if~isempty(regexpi(foundList(currentNodeFlag).DisplayName,findStr))
            if~isa(foundList(currentNodeFlag),'ModelAdvisor.Group')
                me.UserData.findTextString=([DAStudio.message('Simulink:tools:MANumberOccurrences',currentNodeFlag,length(foundList)),': ',DAStudio.message('Simulink:tools:MAPhraseFoundInCheckName')]);
            else
                me.UserData.findTextString=([DAStudio.message('Simulink:tools:MANumberOccurrences',currentNodeFlag,length(foundList)),': ',DAStudio.message('Simulink:tools:MAPhraseFoundInFolderName')]);
            end
        else
            me.UserData.findTextString=([DAStudio.message('Simulink:tools:MANumberOccurrences',currentNodeFlag,length(foundList)),': ',DAStudio.message('Simulink:tools:MAPhraseFoundInDescription')]);
        end
    else
        me.UserData.findTextString=(['<font color = red> ',DAStudio.message('Simulink:tools:MAPhraseNotFound'),' </font>']);
    end
    me.UserData.findText.setText(me.UserData.findTextString);

    function[currentNodeFlag,foundList]=findin(root,findStr,imme,foundList,currentNodeFlag,down)

        if~isempty(regexpi(root.DisplayName,findStr))
            foundList=[foundList,root];
        end
        currentNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if isempty(currentNode)
            return;
        end
        if strcmp(currentNode.ID,root.ID)
            currentNodeFlag=length(foundList)+down;
        end

        for i=1:length(root.ChildrenObj)
            if isa(root.ChildrenObj{i},'ModelAdvisor.Group')||...
                (isa(root.ChildrenObj{i},'ModelAdvisor.ConfigUI')&&strcmp(root.ChildrenObj{i}.Type,'Group'))
                if isa(root,'ModelAdvisor.ConfigUI')||~root.ChildrenObj{i}.Hide
                    [currentNodeFlag,foundList]=findin(root.ChildrenObj{i},findStr,imme,foundList,currentNodeFlag,down);
                end
            else
                if(~isempty(regexpi(root.ChildrenObj{i}.DisplayName,findStr))||~isempty(regexpi(root.ChildrenObj{i}.Description,findStr))...
                    ||~isempty(regexpi(root.ChildrenObj{i}.id,findStr)))
                    foundList=[foundList,root.ChildrenObj{i}];%#ok<AGROW>

                elseif isempty(root.ChildrenObj{i}.Description)&&(root.ChildrenObj{i}.MACIndex>0)&&~isempty(regexpi(root.MAObj.CheckCellArray{root.ChildrenObj{i}.MACIndex}.TitleTips,findStr))
                    foundList=[foundList,root.ChildrenObj{i}];%#ok<AGROW>             
                end
                if strcmp(currentNode.ID,root.ChildrenObj{i}.ID)
                    currentNodeFlag=length(foundList)+down;
                end
            end
        end

        function loc_selectTreeViewNode(imme,nodeObj)
            nodeObj=Advisor.Utils.convertMCOS(nodeObj);

            parentObjs={};
            parentObj=nodeObj.ParentObj;
            while~isempty(parentObj)
                parentObjs{end+1}=parentObj;%#ok<AGROW>
                parentObj=parentObj.ParentObj;
            end
            for i=length(parentObjs):-1:1
                imme.expandTreeNode(parentObjs{i});
            end
            imme.selectTreeViewNode(nodeObj);

