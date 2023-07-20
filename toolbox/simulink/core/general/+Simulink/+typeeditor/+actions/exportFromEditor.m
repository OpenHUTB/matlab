function exportFromEditor(type,~,varargin)




    narginchk(2,3);

    ed=Simulink.typeeditor.app.Editor.getInstance;

    curTreeNode=ed.getCurrentTreeNode;
    assert(length(curTreeNode)==1&&isvalid(curTreeNode{1}));
    curTreeNode=curTreeNode{1};

    st=ed.getStudio;
    ts=st.getToolStrip;
    exportAction=ts.getAction('exportToFileAction');
    if isempty(ed)||isempty(ed.getBaseRoot)||ed.getBaseRoot.Children.Count==0||...
        (nargin==0&&exportAction.enabled)
        return;
    end

    st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorExportInProgressStatusMsg'));
    exportAll=true;
    exportWithRelatedObjects=false;
    curRoot=curTreeNode;
    curNode=curRoot;

    if nargin==3
        curNode=curTreeNode;
        exportWithRelatedObjects=varargin{1};
        exportAll=false;
    end

    try
        selectedNodes='';



        lc=ed.getListComp;
        filterText=lc.imSpreadSheetComponent.getFilterText;






        if isempty(filterText)
            visibleChildrenNodes=curRoot.Children.values;
            visibleChildren=[visibleChildrenNodes{:}];
            visibleChildren={visibleChildren.Name};
        else
            visibleChildren=cellfun(@(child)child.Name,lc.imSpreadSheetComponent.getChildrenItems(curRoot),'UniformOutput',false);
        end

        if isequal(curNode,curRoot)
            selectedNodes=Simulink.typeeditor.app.Editor.getCurrentListNode;
            if isempty(selectedNodes)||(length(selectedNodes)==length(visibleChildren))
                exportAll=true;
            end
        end

        if~exportAll
            if~isempty(selectedNodes)
                objectsToExport=cellfun(@(selNode)selNode.Name,selectedNodes,'UniformOutput',false);
            else
                objectsToExport={curNode.Name};
            end
            if exportWithRelatedObjects
                allObjectsToExport=cellfun(@(nodeName)getDepTypes(curRoot.find(nodeName)),objectsToExport,'UniformOutput',false);
                objectsToExport=unique(vertcat(objectsToExport,allObjectsToExport{:}),'stable');
            end
        else
            objectsToExport=cellstr(char(visibleChildren));
        end
        if(length(objectsToExport)==1)&&isempty(objectsToExport{1})
            objectsToExport={};
        end
        if~isempty(objectsToExport)
            Simulink.typeeditor.utils.exportObjects(objectsToExport,type);
        end
    catch ME
        Simulink.typeeditor.utils.reportError(ME.message);
    end
    st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));

    function depTypes=getDepTypes(objNode)
        depTypes={};
        if objNode.IsBus
            srcObj=objNode.SourceObject;
            if curRoot.hasDictionaryConnection
                if objNode.IsConnectionType
                    clsName=Simulink.typeeditor.app.Editor.AdditionalBaseType;
                else
                    clsName=Simulink.typeeditor.app.Editor.DefaultBaseType;
                end
                eval([clsName,'.getDependentTypesWrtSLDD(objNode.Name, objNode.getRoot.NodeConnection.filespec, true)']);
            else
                depTypes=srcObj.getDependentTypesWrtBaseWS(true);
            end
        else
            typeStrs=split(objNode.getPropValue('Type'),':');
            typeVar=strtrim(typeStrs{end});
            if objNode.doesVariableExistInWorkspace(typeVar)
                depTypes=typeVar;
            end
        end
    end
end