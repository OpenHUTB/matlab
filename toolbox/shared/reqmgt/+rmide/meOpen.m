function meOpen(varargin)




    if ischar(varargin{1})
        calledFromME=false;
        dictFile=varargin{1};
        [~,dictName]=fileparts(dictFile);
        myConnection=rmide.connection(dictFile);
        ddIsLoaded=~isempty(myConnection);
        if~ddIsLoaded
            return;
        end
        if nargin>1
            ddEntryKey=varargin{2};

            entryPath=rmide.getEntryPath(myConnection,ddEntryKey);
        else
            entryPath='';
        end
    else

        calledFromME=true;
        obj=varargin{1};
        dictName=obj.getPropValue('DataSource');
        entryPath=obj.getPropValue('Path');
        dictFile=dictName;
        myConnection=[];
    end

    if isempty(entryPath)

        if~calledFromME
            ensureDictionaryOpenAndCurrent(dictFile,myConnection);
        end
    else

        defaultScope='Design.';
        defaultScopeLength=length('Design.');
        if strncmp(entryPath,defaultScope,defaultScopeLength)


            varName=entryPath(defaultScopeLength+1:end);
            slprivate('exploreListNode',dictFile,'dictionary',varName)
        else

            ensureDictionaryOpenAndCurrent(dictFile,myConnection);
            me=daexplr;
            findAndSelectTreeViewNode(me,dictName,entryPath);
        end
    end
end



function ensureDictionaryOpenAndCurrent(dictFile,ddConnection)
    currentInME=rmide.getCurrent(dictFile);
    if isempty(currentInME)||~strcmp(currentInME,dictFile)
        if isempty(ddConnection)
            ddConnection=rmide.connection(dictFile);
        end
        ddConnection.explore();
    end
end

function findAndSelectTreeViewNode(me,dictName,entryPath)
    imme=DAStudio.imExplorer;
    imme.setHandle(me);
    [node,remainder]=findMyNode(imme,[dictName,'.',entryPath],'');
    if isempty(node)
        errordlg(...
        getString(message('Slvnv:rmide:DataEntryNotFound',entryPath)),...
        getString(message('Slvnv:rmide:NavigateToData')));
    else
        if~isempty(remainder)
            findAndSelectListViewNode(me,node,remainder(2:end));
        end
    end
end

function[node,remainder]=findMyNode(imme,nodePath,parent)
    node=[];
    [nodeName,remainder]=strtok(nodePath,'.');
    allNodes=imme.getVisibleTreeNodes();





    for i=1:length(allNodes)
        switch allNodes{i}.getDisplayClass()
        case{'Simulink.DataDictionaryRootNode','Simulink.DataDictionaryScopeNode'}
            name=allNodes{i}.getNodeName();
            if strcmp(name,nodeName)&&...
                (isempty(parent)||strcmp(allNodes{i}.getParent.getNodeName(),parent))
                node=allNodes{i};
                break;
            end
        otherwise
            continue;
        end
    end
    if isempty(node)

        return;
    else

        imme.selectTreeViewNode(node);
        if isempty(remainder)

            return;
        else

            if isempty(node.getHierarchicalChildren)
                return;
            else
                imme.expandTreeNode(node);
                [node,remainder]=findMyNode(imme,remainder(2:end),nodeName);
            end
        end
    end
end

function findAndSelectListViewNode(me,node,myLabel)
    [listUdi,nIdx]=node.getIndexForNamedItem(me,myLabel);
    if~isequal(nIdx,-1)
        me.view(listUdi,nIdx);
    else
        errordlg(...
        getString(message('Slvnv:rmide:DataEntryNotFound',myLabel)),...
        getString(message('Slvnv:rmide:NavigateToData')));
    end
end
