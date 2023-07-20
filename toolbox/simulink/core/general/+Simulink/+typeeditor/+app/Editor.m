classdef Editor<handle




    properties(Access=private)
StudioWindow
CloseListener
TreeComp
ListComp
DialogComp
Root
        StudioServices DAS.StudioEventService
        StudioListeners uint32
        FocusCounter=0
UIClipboard
        ColumnPrefs{mustBeText(ColumnPrefs)}={}
ListNodeToSelectAtOpen
        ColumnView='Simulink:busEditor:ColumnsDefaultView'
        HighlightedRows Simulink.typeeditor.app.Object
        ErroredRowsSS Simulink.typeeditor.app.Node
        DisableImportForBase logical=false
    end

    properties(Hidden)
        FilterTextCache char
    end

    properties(Constant,Hidden)
        PluginPath=fullfile(matlabroot,'toolbox','simulink','core',...
        'general','+Simulink','+typeeditor','typeEditorPlugin')
        DefaultTypePrefix='BusObject'
        DefaultElementPrefix='a'
        DefaultBaseType='Simulink.Bus'
        AdditionalBaseType='Simulink.ConnectionBus'
        DefaultElement='Simulink.BusElement'
        AdditionalElement='Simulink.ConnectionElement'
        AcceptableTypes={Simulink.typeeditor.app.Editor.DefaultBaseType,Simulink.typeeditor.app.Editor.DefaultTypePrefix;...
        Simulink.typeeditor.app.Editor.AdditionalBaseType,Simulink.typeeditor.app.Editor.DefaultTypePrefix;...
        'Simulink.AliasType','Alias';...
        'Simulink.NumericType','Numeric';...
        'Simulink.ValueType','ValueType';...
        'Simulink.data.dictionary.EnumTypeDefinition','Enum'}
        WindowTag='TypeEditorStudio'
        WidthRatioPI=0.44
        WidthRatioSources=0.17;
    end

    methods(Static,Hidden)
        function obj=getInstance
            mlock;
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=Simulink.typeeditor.app.Editor;
            end
            instance.addlistener('ObjectBeingDestroyed',@(~,~)munlock);
            obj=instance;
        end

        function obj=getEditor
            obj=Simulink.typeeditor.app.Editor.getInstance;
            if~obj.isVisible
                obj.open;
            else
                obj.getStudio.show;
            end
        end

        function node=getCurrentTreeNode
            obj=Simulink.typeeditor.app.Editor.getInstance;
            if~obj.isVisible
                node=[];
            else
                node=obj.getTreeComp.getSelection;
            end
        end

        function node=getCurrentListNode
            obj=Simulink.typeeditor.app.Editor.getInstance;
            if~obj.isVisible
                node=[];
            else
                node=obj.getListComp.getSelection;
            end
        end

        function setCurrentTreeNode(node)
            obj=Simulink.typeeditor.app.Editor.getInstance;
            if obj.isVisible
                obj.getTreeComp.view(node);
            end
        end

        function setCurrentListNode(nodes)
            obj=Simulink.typeeditor.app.Editor.getInstance;
            if obj.isVisible
                obj.getListComp.view(nodes);
            end
        end

        function colList=getHeterogeneousColumns
            colList=unique(horzcat(Simulink.typeeditor.app.Element.getColumnPropertiesForSS,...
            Simulink.typeeditor.app.Object.getColumnProperties),'stable');
        end

        function propList=getColumnsForView(view)
            propList={};
            switch view
            case 'Simulink:busEditor:ColumnsDefaultView'
                propList=Simulink.typeeditor.app.Editor.getHeterogeneousColumns;
            case 'Simulink:busEditor:ColumnsAtomicTypeView'
                propList=Simulink.typeeditor.app.Element.getColumnProperties;
            case 'Simulink:busEditor:ColumnsDataTypeView'
                propList=Simulink.typeeditor.app.Object.getColumnProperties;
            otherwise
                assert(false);
            end
        end

        function props=getPropertiesForDefaultView




            endChar='_';
            atomicProps=Simulink.typeeditor.app.Element.getPropertiesForDefaultView;
            dataTypeProps=Simulink.typeeditor.app.Object.getPropertiesForDefaultView;
            commonProps={DAStudio.message('Simulink:busEditor:PropType'),...
            DAStudio.message('Simulink:busEditor:PropDescription')};
            props=unique(horzcat(commonProps,...
            [endChar,DAStudio.message('Simulink:busEditor:ColumnsAtomicTypeViewUpperCase'),endChar],...
            atomicProps,...
            [endChar,DAStudio.message('Simulink:busEditor:ColumnsDataTypeViewUpperCase'),endChar],...
            dataTypeProps),'stable');
        end
    end

    methods(Static,Access=private)








        function result=onDrag(~,source,destination,location,~)
            try
                ed=Simulink.typeeditor.app.Editor.getInstance;
                parentNode=destination.Parent;


                if~isa(parentNode,'Simulink.typeeditor.app.Object')
                    result=false;
                    return;
                else
                    allChildren=parentNode.Children;


                    isReadOnly=any(arrayfun(@(row)row.ReadOnlyElement,[source{:}]));
                    if isReadOnly
                        result=false;
                        return;
                    end



                    if destination.ReadOnlyElement
                        if parentNode.ReadOnlyElement
                            result=false;
                            return;
                        else
                            switch(location)
                            case{'before','on'}
                                result=false;
                                return;
                            case 'after'
                                idxInParent=find(destination==allChildren);
                                if idxInParent<length(allChildren)
                                    result=false;
                                    return;
                                end
                            otherwise
                                assert(false);
                            end
                        end
                    end


                    ss=ed.getListComp.imSpreadSheetComponent;
                    if destination.IsBus&&ss.isExpanded(destination)&&strcmp(location,'after')
                        result=false;
                        return;
                    end


                    if length(source)>1
                        lenSource=length(source);
                        idxArray=arrayfun(@(sourceObj)find(allChildren==sourceObj{1}),source);
                        isTopDown=issorted(idxArray,'strictascend');
                        if~isTopDown
                            idxArray=sort(idxArray,'ascend');
                        end
                        isContiguous=isequal(diff(idxArray),ones(lenSource-1,1));
                        if~isContiguous
                            result=false;
                            return;
                        end
                        lc=ed.getListComp;
                        assert(isfield(lc.getComponentUserData,'Multiselection'));
                        lc.setComponentUserData(struct('Multiselection',idxArray));
                    end
                    result=true;
                end
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function result=onDrop(~,source,destination,location,action)
            try
                isCopy=strcmp(action,'copy');
                parentNode=destination.Parent;
                allChildren=parentNode.Children;
                dstRefNodeIdx=find(allChildren==destination);
                newChildren=allChildren;
                if length(source)>1



                    userData=Simulink.typeeditor.app.Editor.getInstance.getListComp.getComponentUserData;
                    assert(isfield(userData,'Multiselection')&&...
                    ~isempty(userData.Multiselection));
                    idxArray=userData.Multiselection;
                else
                    idxArray=find(allChildren==source{1});
                end
                if isCopy
                    sourceArr=allChildren(idxArray);
                    sourceNames=arrayfun(@(elem)elem.SourceObject.Name,sourceArr,'UniformOutput',false);
                    elemNodesToCopy=cellfun(@(name)parentNode.find(name),sourceNames);
                    newChildNames=Simulink.typeeditor.utils.getUniqueChildName(parentNode,sourceNames);
                    newElemNodes=elemNodesToCopy;
                    for i=1:length(elemNodesToCopy)
                        newElemNodes(i)=Simulink.typeeditor.app.Element(elemNodesToCopy(i).SourceObject,parentNode,elemNodesToCopy(i).ReadOnlyElement);
                        newElemNodes(i).SourceObject.Name=newChildNames{i};
                    end
                end
                if length(source)>1
                    lenSource=length(source);
                    srcNodeIdx=idxArray(1);
                    if srcNodeIdx<dstRefNodeIdx
                        if any(strcmp(location,{'on','after'}))
                            if isCopy
                                if strcmp(location,'on')
                                    dstNodeIdx=dstRefNodeIdx;
                                else
                                    dstNodeIdx=dstRefNodeIdx+1;
                                end
                            else
                                dstNodeIdx=dstRefNodeIdx-lenSource+1;
                            end
                        else
                            assert(strcmp(location,'before'));
                            if isCopy
                                dstNodeIdx=dstRefNodeIdx;
                            else
                                dstNodeIdx=dstRefNodeIdx-lenSource;
                            end
                        end
                        if isCopy
                            newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=newElemNodes;
                            newChildren(dstNodeIdx+lenSource:length(allChildren)+lenSource)=allChildren(dstNodeIdx:end);
                        else
                            newChildren(srcNodeIdx:dstNodeIdx-1)=allChildren(srcNodeIdx+lenSource:dstNodeIdx+lenSource-1);
                            newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=allChildren(idxArray);
                        end
                    elseif srcNodeIdx>dstRefNodeIdx
                        if any(strcmp(location,{'on','before'}))
                            dstNodeIdx=dstRefNodeIdx;
                        else
                            assert(strcmp(location,'after'));
                            dstNodeIdx=dstRefNodeIdx+1;
                        end
                        if isCopy
                            newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=newElemNodes;
                            newChildren(dstNodeIdx+lenSource:length(allChildren)+lenSource)=allChildren(dstNodeIdx:end);
                        else
                            newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=allChildren(idxArray);
                            newChildren(dstNodeIdx+lenSource:srcNodeIdx+lenSource-1)=allChildren(dstNodeIdx:srcNodeIdx-1);
                        end
                    else
                        return;
                    end
                else
                    srcNodeIdx=idxArray;
                    if srcNodeIdx<dstRefNodeIdx
                        if any(strcmp(location,{'on','after'}))
                            if isCopy
                                if strcmp(location,'on')
                                    dstNodeIdx=dstRefNodeIdx;
                                else
                                    dstNodeIdx=dstRefNodeIdx+1;
                                end
                            else
                                dstNodeIdx=dstRefNodeIdx;
                            end
                        else
                            assert(strcmp(location,'before'));
                            if isCopy
                                dstNodeIdx=dstRefNodeIdx;
                            else
                                dstNodeIdx=dstRefNodeIdx-1;
                            end
                        end
                        if isCopy
                            newChildren(dstNodeIdx)=newElemNodes;
                            newChildren(dstNodeIdx+1:length(allChildren)+1)=allChildren(dstNodeIdx:end);
                        else
                            newChildren(srcNodeIdx:dstNodeIdx-1)=allChildren(srcNodeIdx+1:dstNodeIdx);
                            newChildren(dstNodeIdx)=source{1};
                        end
                    elseif srcNodeIdx>dstRefNodeIdx
                        if any(strcmp(location,{'on','before'}))
                            dstNodeIdx=dstRefNodeIdx;
                        else
                            assert(strcmp(location,'after'));
                            dstNodeIdx=dstRefNodeIdx+1;
                        end
                        if isCopy
                            newChildren(dstNodeIdx)=newElemNodes;
                            newChildren(dstNodeIdx+1:length(allChildren)+1)=allChildren(dstNodeIdx:end);
                        else
                            newChildren(dstNodeIdx)=source{1};
                            newChildren(dstNodeIdx+1:srcNodeIdx)=allChildren(dstNodeIdx:srcNodeIdx-1);
                        end
                    else
                        return;
                    end
                end
                ed=Simulink.typeeditor.app.Editor.getInstance;
                root=parentNode.getRoot;
                parentNode.Children=newChildren;
                ed.getListComp.update(true);
                tempObject=parentNode.SourceObject;
                tempObject.Elements=[newChildren.SourceObject];
                parentNode.SourceObject=tempObject;
                parentIdxInCache=strcmp(parentNode.Name,root.WorkspaceCache(:,1));
                root.WorkspaceCache{parentIdxInCache,2}=tempObject;
                parentVarID=root.NodeDataAccessor.identifyByName(parentNode.Name);
                if root.hasDictionaryConnection
                    numVarIDs=length(parentVarID);
                    if numVarIDs>1
                        [~,ddName,~]=fileparts(root.NodeConnection.filespec);
                        ddName=[ddName,'.sldd'];
                        for j=1:numVarIDs
                            if strcmp(parentVarID(j).getDataSourceFriendlyName,ddName)
                                parentVarID=parentVarID(j);
                                break;
                            end
                        end
                    end
                end
                root.NodeDataAccessor.updateVariable(parentVarID,tempObject);
                result=true;
                if isCopy
                    eventType='BusElementAdded';
                    newSrcObjs=[newElemNodes.SourceObject];
                    eventData=Simulink.typeeditor.app.EventData(eventType,BusName=parentNode.Name,ElemName={newSrcObjs.Name},ElemIdx=dstNodeIdx-1,...
                    IsConnType=parentNode.IsConnectionType,ElemObj=newSrcObjs);
                    root.notify(eventType,eventData);
                    ed.getListComp.view(newElemNodes);
                else
                    [~,~,newOrder]=intersect(newChildren,allChildren,'stable');
                    eventType='BusElementMoved';
                    eventData=Simulink.typeeditor.app.EventData(eventType,BusName=parentNode.Name,ElemIdx=newOrder,IsConnType=parentNode.IsConnectionType);
                    root.notify(eventType,eventData);
                end
                root.notifySLDDChanged;
                root.refreshDataSourceChildren(parentNode.Name);
                ed.update;
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end
    end

    methods(Access=public,Hidden)
        function root=getSource(this)
            root=this.Root;
        end

        function root=getBaseRoot(this)
            editorSource=this.getSource;
            contexts=editorSource.getChildren;
            root=contexts(1);
        end

        function cb=getClipboard(this)
            cb=this.UIClipboard;
        end

        function tf=isVisible(this)
            tf=false;
            studio=this.getStudio;
            if~isempty(studio)
                tf=studio.isStudioVisible;
            end
        end

        function st=getStudio(this)
            st=[];
            if~isempty(this.StudioWindow)&&isvalid(this.StudioWindow)
                st=this.StudioWindow.getStudio();
            end
        end

        function sw=getStudioWindow(this)
            sw=[];
            if~isempty(this.StudioWindow)&&isvalid(this.StudioWindow)
                sw=this.StudioWindow;
            end
        end

        function delete(this)
            delete(this.getSource);
            if~isempty(this.StudioListeners)
                this.unregisterStudioListeners;
            end
            if~isempty(this.StudioWindow)&&isvalid(this.StudioWindow)
                delete(this.CloseListener);
                this.close;
            end
            Simulink.typeeditor.app.ContentsTitle.getInstance.delete;
            Simulink.typeeditor.app.ImportDialog.getInstance.delete;
        end

        function open(this,varargin)



            narginchk(1,3);

            treeNodeToSelect=[];
            if nargin>1
                treeNodeToSelect=varargin{1};
                if nargin>2
                    this.ListNodeToSelectAtOpen=varargin{2};
                end
            end


            if isempty(this.StudioWindow)||~isvalid(this.TreeComp)
                constructUI(this);
                sourcesSize=this.TreeComp.getWidget.position;
                piSize=this.DialogComp.getInspector.position;
                studioSize=this.getStudio.getStudioPosition;
                this.TreeComp.setPreferredSize(this.WidthRatioSources*studioSize(3),sourcesSize(4));
                this.DialogComp.setPreferredSize(this.WidthRatioPI*studioSize(3),piSize(4));
            end
            this.StudioWindow.show;

            if isempty(treeNodeToSelect)
                if isempty(this.TreeComp.getSelection)
                    this.TreeComp.view(this.Root.Children(1));
                end
            else
                this.TreeComp.view(treeNodeToSelect);
            end



            if isempty(this.StudioListeners)
                this.registerStudioListeners;
            end
        end

        function close(this,~)
            this.clearEditor;
            if~isempty(this.StudioWindow)&&isvalid(this.StudioWindow)
                this.StudioWindow.close();
                delete(this.StudioWindow);
            end
            hangingStudios=studio.Window.getAllStudios(this.WindowTag);
            arrayfun(@(window)window.close,hangingStudios);

        end

        function onWindowClose(this,~,~)
            this.clearEditor;
        end

        function hasTree=hasTreeComp(~)
            hasTree=true;
        end

        function treeComp=getTreeComp(this)
            treeComp=this.TreeComp;
        end

        function listComp=getListComp(this)
            listComp=this.ListComp;
        end

        function piComp=getDialogComp(this)
            piComp=this.DialogComp;
        end

        function dlg=getDialogHandle(~)
            dlgs=DAStudio.ToolRoot.getOpenDialogs;
            dlg=dlgs.find('dialogTag','BusObjectPIDialog');
            if isempty(dlg)
                dlg=dlgs.find('dialogTag','BusElementPIDialog');
                if isempty(dlg)
                    dlg=dlgs.find('dialogTag','BusEditorSourcePIDialog');
                end
            end
        end

        function update(this)

            this.updateToolstripActions;
        end

        function onFocus(this,~)
            try
                st=this.getStudio;
                statusMsgOld=st.getStatusBarMessage;
                if this.FocusCounter~=0
                    sources=this.getSource.Children;
                    arrayfun(@(src)src.refresh,sources);
                end
                this.FocusCounter=this.FocusCounter+1;
                st.setStatusBarMessage(statusMsgOld);
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function commandStrProvider=getCommandStrProvider(~)
            commandStrProvider=Simulink.typeeditor.utils.CommandStrProvider();
        end

        function columnView=getColumnView(this)
            columnView=this.ColumnView;
        end

        function setColumnView(this,columnView)
            this.ColumnView=columnView;
        end

        function rows=getHighlightedRows(this)
            rows=this.HighlightedRows;
        end

        function setHighlightedRows(this,rows)
            if isempty(rows)
                this.HighlightedRows=Simulink.typeeditor.app.Object.empty;
            else
                this.HighlightedRows=rows;
            end
        end

        function rows=getErroredRowsSS(this)
            rows=this.ErroredRowsSS;
        end

        function setErroredRowsSS(this,rows)
            if isempty(rows)
                this.ErroredRowsSS=Simulink.typeeditor.app.Node.empty;
            else
                this.ErroredRowsSS(end+1)=rows;
            end
        end

        function clearRowHighlights(this)
            highlightedRows=this.getHighlightedRows;
            if~isempty(highlightedRows)&&isvalid(highlightedRows)
                highlightedRows.HighlightMode=false;
            end
            this.ListComp.update(highlightedRows);
            this.setHighlightedRows([]);
        end

        function clearRowErrors(this)
            erroredRows=this.getErroredRowsSS;
            for i=1:length(erroredRows)
                if~isempty(erroredRows(i))&&isvalid(erroredRows(i))
                    erroredRows(i).resetSSErrorState;
                end
            end
            this.ListComp.update(num2cell(erroredRows));
            this.setErroredRowsSS([]);
        end

        function dlgResponse=getImportDialogPrompt(this,sourceName)
            [dlgResponse,showAgain]=Simulink.typeeditor.app.ImportDialog.getInstance.questdlg(sourceName);
            this.DisableImportForBase=~showAgain&&...
            (isempty(dlgResponse)||strcmp(dlgResponse,DAStudio.message('Simulink:busEditor:NoText')));
        end

        function tf=isImportForBaseDisabled(this)
            tf=this.DisableImportForBase;
        end
    end

    methods(Access=private)
        function this=Editor()


            if~isSimulinkStarted
                start_simulink;
            end
        end

        function constructUI(this)
            if~isempty(this.StudioWindow)&&isvalid(this.StudioWindow)
                this.StudioWindow.delete();
            end
            currentStudio=studio.Window.getAllStudios(this.WindowTag);
            if~isempty(currentStudio)
                for i=1:length(currentStudio)
                    currentStudio(i).close;
                end
            end

            addpath(this.PluginPath);
            confObj=studio.WindowConfiguration;
            if slfeature('TypeEditorStudio')>0
                confObj.Title=DAStudio.message('Simulink:busEditor:TypeEditorTitle');
            else
                confObj.Title=DAStudio.message('Simulink:busEditor:BusEditorStudioTitle');
            end
            confObj.Icon=Simulink.typeeditor.utils.getBusEditorResourceFile('buseditor.png');
            confObj.ToolstripConfigurationName='typeEditor';
            confObj.ToolstripConfigurationPath=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+typeeditor','typeEditorPlugin');
            confObj.ToolstripName='typeEditorToolStrip';
            confObj.ToolstripContext='Simulink.typeeditor.app.ToolstripContext';
            confObj.Tag=this.WindowTag;

            sw=studio.Window(confObj);

            this.CloseListener=addlistener(sw,'Closed',@this.onWindowClose);


            this.TreeComp=GLUE2.SpreadSheetComponent(DAStudio.message('Simulink:busEditor:SourcesPane'));
            this.TreeComp.setColumns({DAStudio.message('Simulink:busEditor:PropElementName')},'','',false);
            this.TreeComp.enableHierarchicalView(true);
            this.TreeComp.UserMoveable=false;
            this.TreeComp.UserFloatable=false;
            sw.addComponent(this.TreeComp,'left');

            this.TreeComp.onSelectionChange=@this.onTreeSelectionChanged;
            this.TreeComp.onContextMenuRequest=@this.onContextMenuRequest;


            treeConfigOpts=struct("hidecolumns",true,"regexinfilter",true,"enablesort",false,...
            "enablecolumnreordering",false,"enablegrouping",false,"showgrid",false,"enablemultiselect",false);
            this.TreeComp.setConfig(jsonencode(treeConfigOpts));

            this.Root=Simulink.typeeditor.app.Root;
            this.TreeComp.setSource(this.Root);


            this.ListComp=GLUE2.SpreadSheetComponent(DAStudio.message('Simulink:busEditor:ContentsPane'));
            if isempty(this.ColumnPrefs)
                listProps=Simulink.typeeditor.app.Editor.getHeterogeneousColumns;
            else
                listProps=this.ColumnPrefs;
                this.ColumnPrefs={};
            end
            colMenuProps=listProps(~strcmp(DAStudio.message('Simulink:busEditor:PropElementName'),listProps));
            this.ListComp.setColumns(listProps,'','',false);
            this.ListComp.setColumnMenu(colMenuProps);
            this.ListComp.enableHierarchicalView(true);
            this.ListComp.HideTitle=false;
            this.ListComp.UserMoveable=false;
            this.ListComp.UserFloatable=false;
            this.ListComp.setSource(this.getBaseRoot);
            sw.addComponent(this.ListComp,'center');
            this.ListComp.setComponentUserData(struct('Multiselection',[]));
            this.ListComp.setTitleViewSource(Simulink.typeeditor.app.ContentsTitle.getInstance);

            this.ListComp.onSelectionChange=@this.onListSelectionChanged;
            this.ListComp.onContextMenuRequest=@this.onContextMenuRequest;
            this.ListComp.onLoadingComplete=@this.onSpreadSheetLoadingComplete;
            listConfigOpts=struct("regexinfilter",true,"enablesort",false,"enablecolumnreordering",true,"enablegrouping",false,...
            "showgrid",false);
            this.ListComp.setConfig(jsonencode(listConfigOpts));
            this.ListComp.setMultiFilter(true);
            this.ListComp.setConfig('{"columns":[{"name":"Name","width":100}]}');


            this.ListComp.setDragCursor('move',Simulink.typeeditor.utils.getBusEditorResourceFile('move_cursor.png'));
            this.ListComp.setDragCursor('copy',Simulink.typeeditor.utils.getBusEditorResourceFile('copy_cursor.png'));

            this.ListComp.setAcceptedMimeTypes({'application/buseditor-mimetype'});


            this.ListComp.onDrag=@Simulink.typeeditor.app.Editor.onDrag;
            this.ListComp.onDrop=@Simulink.typeeditor.app.Editor.onDrop;


            this.DialogComp=GLUE2.PropertyInspectorComponent(DAStudio.message('Simulink:busEditor:PropertiesPane'));
            this.DialogComp.updateSource('',this.getBaseRoot);
            this.DialogComp.UserMoveable=false;
            this.DialogComp.UserFloatable=false;
            sw.addComponent(this.DialogComp,'right');


            this.StudioWindow=sw;
            this.getStudio.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
            this.UIClipboard=Simulink.typeeditor.app.Clipboard;
            this.update;
        end

        function clearEditor(this)

            if~isempty(this.ListComp)&&isvalid(this.ListComp)
                colConfig=this.ListComp.getColumnWidths;
                colNames={jsondecode(colConfig).columns.name};
                this.ColumnPrefs=colNames;
            end


            if contains(path,this.PluginPath)
                rmpath(this.PluginPath);
            end
            this.FocusCounter=0;
            this.unregisterStudioListeners;
            delete(this.Root);
            delete(this.CloseListener);
            delete(this.UIClipboard);
            delete(this.TreeComp);
            delete(this.ListComp);
            delete(this.DialogComp);
        end

        function registerStudioListeners(this)
            this.StudioServices(1)=this.getStudio.getService('WindowActivatedEvents');
            this.StudioListeners(1)=this.StudioServices(1).registerServiceCallback(@this.onFocus);




        end

        function unregisterStudioListeners(this)
            if~isempty(this.StudioListeners)
                for i=1:length(this.StudioServices)
                    this.StudioServices(i).unRegisterServiceCallback(this.StudioListeners(i));
                end
            end
            this.StudioListeners=uint32.empty;
        end

        function result=onTreeSelectionChanged(this,~,sel,~)
            if isempty(sel)
                this.TreeComp.view(this.getBaseRoot);
            else
                assert(length(sel)==1);
                selRow=sel{end};
                this.ListComp.setSource(selRow);






                this.DialogComp.updateSource('',selRow);

            end




            this.update;
            result=true;
        end

        function result=onListSelectionChanged(this,~,sel,~)
            this.clearRowHighlights;
            this.clearRowErrors;
            if~isempty(sel)
                selRow=sel{end};



                dlg=this.getDialogHandle;
                this.DialogComp.updateSource('',selRow);
                if~isempty(dlg)&&ishandle(dlg)&&length(sel)>1
                    dlg.setSource(selRow);
                end

                if isa(selRow,'Simulink.typeeditor.app.Element')||isa(selRow,'Simulink.typeeditor.app.Object')

                    kvPairsList=GLEE.ByteArrayList;
                    summary=GLEE.ByteArrayPair(GLEE.ByteArray('foo'),GLEE.ByteArray('bar'));
                    kvPairsList.add(summary);
                    this.getListComp.setMimeInfo(selRow,selRow.getMimeType,selRow.getMimeData);


                    srcObj=[];
                    lengthSel=length(sel);
                    rowHasChildren=false;
                    rowIsBusOrElement=false;
                    if isa(selRow,'Simulink.typeeditor.app.Element')&&selRow.IsBus
                        busStr=Simulink.typeeditor.utils.stripBusPrefix(selRow.getPropValue('Type'));
                        rt=selRow.getRoot;
                        if rt.Children.isKey(busStr)
                            obj=rt.Children(busStr);
                            srcObj=obj.SourceObject;
                        end
                        rowHasChildren=(lengthSel==1)&&isempty(selRow.Children);
                        rowIsBusOrElement=true;
                    elseif isa(selRow,'Simulink.typeeditor.app.Object')
                        srcObj=selRow.SourceObject;
                        rowIsBusOrElement=selRow.IsBus;
                        rowHasChildren=rowIsBusOrElement&&(lengthSel==1)&&(isempty(selRow.Children)||selRow.ChildrenLoadedBeforeQuery);
                    end
                    srcHasChildren=rowIsBusOrElement&&~isempty(srcObj)&&~isempty(srcObj.Elements);

                    filterText=this.ListComp.imSpreadSheetComponent.getFilterText;
                    filterOff=isempty(filterText);
                    updateComp=rowHasChildren&&srcHasChildren&&filterOff;


                    if updateComp
                        selRow.LoadImmediateChildren=true;
                        if isa(selRow,'Simulink.typeeditor.app.Object')
                            selRow.ChildrenLoadedBeforeQuery=false;
                        end
                    end



                    if lengthSel==1
                        selRow.highlightReferencedTypes;
                    end


                    if updateComp
                        this.FilterTextCache=filterText;
                        this.ListComp.update(true);
                        this.ListComp.expand(selRow,true);
                    end
                end
            else
                selRowTreeComp=this.getCurrentTreeNode;
                if~isempty(selRowTreeComp)&&(length(selRowTreeComp)==1)
                    this.DialogComp.updateSource('',selRowTreeComp{1});
                end
            end
            this.update;
            result=true;
        end

        function onSpreadSheetLoadingComplete(this,~,~)
            if~isempty(this.FilterTextCache)
                this.ListComp.imSpreadSheetComponent.setFilterText(this.FilterTextCache);
                this.FilterTextCache='';
            end
            if~isempty(this.ListNodeToSelectAtOpen)
                this.ListComp.view(this.ListNodeToSelectAtOpen);
                this.ListNodeToSelectAtOpen=[];
            end
        end

        function result=onContextMenuRequest(this,~,sel)
            result=[];
            selForContext=sel;
            listSel=this.ListComp.getSelection;
            numSelected=length(listSel);
            isHomogeneous=true;
            if numSelected>1
                listSelTypes=cellfun(@class,listSel,'UniformOutput',false);
                isHomogeneous=isequal(listSelTypes{:});
            end
            if isHomogeneous
                if(numSelected>1)&&isa(sel,'Simulink.typeeditor.app.Object')
                    listSelArr=[listSel{:}];
                    listSelBus=[listSelArr.IsBus];
                    if all(listSelBus)
                        listSelBusConnection=[listSelArr.IsConnectionType];
                        if any(listSelBusConnection)
                            connectionBusRows=listSelArr(listSelBusConnection);
                            selForContext=connectionBusRows(1);
                        end
                    else
                        nonBusRows=listSelArr(~listSelBus);
                        selForContext=nonBusRows(1);
                    end
                end
                result=selForContext.getContextMenuItems;
            end
        end






























        function updateToolstripActions(this)
            try
                typeChain={};
                treeSel=this.getCurrentTreeNode;
                listSel=this.getCurrentListNode;
                if isempty(treeSel)
                    typeChain{end+1}='addBusActionDisable';
                    typeChain{end+1}='addBusPopupActionDisable';
                    typeChain{end+1}='addConnBusPopupActionDisable';
                    typeChain{end+1}='addBusElementActionDisable';
                    typeChain{end+1}='addConnectionElementActionDisable';
                    typeChain{end+1}='createSimulinkParameterActionDisable';
                    typeChain{end+1}='createMATLABStructActionDisable';
                    typeChain{end+1}='moveUpActionDisable';
                    typeChain{end+1}='moveDownActionDisable';
                    typeChain{end+1}='cutActionDisable';
                    typeChain{end+1}='copyActionDisable';
                    typeChain{end+1}='deleteActionDisable';
                    typeChain{end+1}='importActionDisable';
                    typeChain{end+1}='exportMATActionDisable';
                    typeChain{end+1}='exportCellActionDisable';
                    typeChain{end+1}='exportObjectActionDisable';
                    typeChain{end+1}='pasteActionDisable';
                    typeChain{end+1}='gotoActionDisable';
                    typeChain{end+1}='closeActionDisable';
                    typeChain{end+1}='revertActionDisable';
                    typeChain{end+1}='addEnumTypeActionDisable';
                else





                    assert(length(treeSel)==1);
                    treeSelRow=treeSel{1};
                    typeChain{end+1}='gotoActionDisable';
                    if treeSelRow.hasDictionaryConnection
                        typeChain{end+1}='importActionDisable';
                        typeChain{end+1}='exportActionDisable';
                        typeChain{end+1}='closeActionEnable';
                        if treeSelRow.NodeConnection.hasUnsavedChanges
                            typeChain{end+1}='saveSLDDEnable';
                            typeChain{end+1}='revertActionEnable';
                        else
                            typeChain{end+1}='saveSLDDDisable';
                            typeChain{end+1}='revertActionDisable';
                        end
                        typeChain{end+1}='addEnumTypeActionEnable';
                    else
                        if this.DisableImportForBase
                            typeChain{end+1}='importActionDisable';
                        else
                            typeChain{end+1}='importActionEnable';
                        end
                        typeChain{end+1}='exportMATActionEnable';
                        typeChain{end+1}='exportObjectActionEnable';
                        typeChain{end+1}='addEnumTypeActionDisable';

                        childrenItems=treeSelRow.Children.values;
                        if isempty(childrenItems)||...
                            any(cellfun(@isempty,childrenItems))
                            childrenItems=treeSelRow.Children.values;
                            if isempty(childrenItems)
                                hasConnectionBus=false;
                            else
                                hasConnectionBus=hasConnectionOrNonBusCheck;
                            end
                        else
                            hasConnectionBus=hasConnectionOrNonBusCheck;
                        end
                        if hasConnectionBus
                            typeChain{end+1}='exportCellActionDisable';
                        else
                            typeChain{end+1}='exportCellActionEnable';
                        end
                    end
                    if isempty(listSel)
                        typeChain{end+1}='addBusElementActionDisable';
                        typeChain{end+1}='addConnectionElementActionDisable';
                        typeChain{end+1}='createSimulinkParameterActionDisable';
                        typeChain{end+1}='createMATLABStructActionDisable';
                        typeChain{end+1}='cutActionDisable';
                        typeChain{end+1}='copyActionDisable';
                        typeChain{end+1}='deleteActionDisable';
                        typeChain{end+1}='moveUpActionDisable';
                        typeChain{end+1}='moveDownActionDisable';
                        clipboardContents=this.UIClipboard.contents;
                        anyEnum=strcmp(this.UIClipboard.type,'object')&&any(cellfun(@(item)item.IsEnum,clipboardContents));
                        if~isempty(clipboardContents)&&...
                            strcmp(this.UIClipboard.type,'object')&&...
                            (treeSelRow.hasDictionaryConnection||~anyEnum)
                            typeChain{end+1}='pasteActionEnable';
                        else
                            typeChain{end+1}='pasteActionDisable';
                        end
                    else
                        if length(listSel)==1
                            listSelRow=listSel{1};
                            if listSelRow.IsConnectionType
                                typeChain{end+1}='addBusElementActionDisable';
                                typeChain{end+1}='addConnectionElementActionEnable';
                                typeChain{end+1}='createSimulinkParameterActionDisable';
                                typeChain{end+1}='createMATLABStructActionDisable';
                                if isa(listSelRow,'Simulink.typeeditor.app.Object')
                                    typeChain{end+1}='moveUpActionDisable';
                                    typeChain{end+1}='moveDownActionDisable';
                                    typeChain{end+1}='cutActionEnable';
                                    typeChain{end+1}='copyActionEnable';
                                    typeChain{end+1}='deleteActionEnable';
                                end
                            else
                                typeChain{end+1}='addConnectionElementActionDisable';
                                if isa(listSelRow,'Simulink.typeeditor.app.Object')
                                    if listSelRow.IsBus
                                        typeChain{end+1}='addBusElementActionEnable';
                                        typeChain{end+1}='createSimulinkParameterActionEnable';
                                        typeChain{end+1}='createMATLABStructActionEnable';
                                    else
                                        typeChain{end+1}='addBusElementActionDisable';
                                        typeChain{end+1}='createSimulinkParameterActionDisable';
                                        typeChain{end+1}='createMATLABStructActionDisable';
                                    end
                                    typeChain{end+1}='moveUpActionDisable';
                                    typeChain{end+1}='moveDownActionDisable';
                                    if listSelRow.IsEnum&&~treeSelRow.hasDictionaryConnection
                                        typeChain{end+1}='cutActionDisable';
                                        typeChain{end+1}='deleteActionDisable';
                                    else
                                        typeChain{end+1}='cutActionEnable';
                                        typeChain{end+1}='deleteActionEnable';
                                    end
                                    typeChain{end+1}='copyActionEnable';
                                end
                            end
                            considerPaste=true;
                            if isa(listSelRow,'Simulink.typeeditor.app.Element')
                                if listSelRow.ReadOnlyElement
                                    typeChain{end+1}='addBusElementActionDisable';
                                    typeChain{end+1}='addConnectionElementActionDisable';
                                    typeChain{end+1}='moveUpActionDisable';
                                    typeChain{end+1}='moveDownActionDisable';
                                    typeChain{end+1}='cutActionDisable';
                                    typeChain{end+1}='deleteActionDisable';
                                    typeChain{end+1}='pasteActionDisable';
                                    typeChain{end+1}='gotoActionEnable';
                                    considerPaste=false;
                                else
                                    numSiblings=length(listSelRow.Parent.Children);
                                    if numSiblings==1
                                        typeChain{end+1}='moveUpActionDisable';
                                        typeChain{end+1}='moveDownActionDisable';
                                    else
                                        idxInParent=listSelRow.Parent.findIdx(listSelRow.SourceObject.Name);
                                        if idxInParent==1
                                            typeChain{end+1}='moveUpActionDisable';
                                            typeChain{end+1}='moveDownActionEnable';
                                        elseif idxInParent==numSiblings
                                            typeChain{end+1}='moveUpActionEnable';
                                            typeChain{end+1}='moveDownActionDisable';
                                        else
                                            typeChain{end+1}='moveUpActionEnable';
                                            typeChain{end+1}='moveDownActionEnable';
                                        end
                                    end
                                    typeChain{end+1}='cutActionEnable';
                                    typeChain{end+1}='copyActionEnable';
                                    typeChain{end+1}='deleteActionEnable';
                                end

                                typeChain{end+1}='createSimulinkParameterActionDisable';
                                typeChain{end+1}='createMATLABStructActionDisable';
                            elseif isa(listSelRow,'Simulink.typeeditor.app.Object')
                                if~listSelRow.IsBus
                                    gotoTypeWithPrefix=split(listSelRow.getPropValue('Type'),':');
                                    gotoType=strtrim(gotoTypeWithPrefix{end});
                                    resolvesToType=listSelRow.doesVariableExistInWorkspace(gotoType);
                                    if resolvesToType
                                        typeChain{end+1}='gotoActionEnable';
                                    end
                                end
                            end
                            clipboardContents=this.UIClipboard.contents;
                            if~isempty(clipboardContents)&&considerPaste
                                if strcmp(this.UIClipboard.type,'element')
                                    clipboardItems=[this.UIClipboard.contents{:}];
                                    clipboardItemsType=all([clipboardItems.IsConnectionType]);
                                    if~(isequal(clipboardItemsType,listSelRow.IsConnectionType)&&...
                                        ((isa(listSelRow,'Simulink.typeeditor.app.Object')&&listSelRow.IsBus)||...
                                        isa(listSelRow,'Simulink.typeeditor.app.Element')))
                                        typeChain{end+1}='pasteActionDisable';
                                    else
                                        typeChain{end+1}='pasteActionEnable';
                                    end
                                else
                                    anyEnum=any(cellfun(@(item)item.IsEnum,clipboardContents));
                                    if treeSelRow.hasDictionaryConnection||~anyEnum
                                        typeChain{end+1}='pasteActionEnable';
                                    else
                                        typeChain{end+1}='pasteActionDisable';
                                    end
                                end
                            else
                                typeChain{end+1}='pasteActionDisable';
                            end
                        else
                            listSelTypes=cellfun(@class,listSel,'UniformOutput',false);
                            isHomogeneous=isequal(listSelTypes{:});
                            clipboardContents=this.UIClipboard.contents;
                            if isempty(clipboardContents)
                                anyEnumCB=false;
                            else
                                anyEnumCB=any(cellfun(@(item)isa(item,'Simulink.typeeditor.app.Object')&&item.IsEnum,clipboardContents));
                            end
                            anyEnumSel=any(cellfun(@(item)isa(item,'Simulink.typeeditor.app.Object')&&item.IsEnum,listSel));
                            if~isHomogeneous
                                typeChain{end+1}='addBusElementActionDisable';
                                typeChain{end+1}='addConnectionElementActionDisable';
                                typeChain{end+1}='createSimulinkParameterActionDisable';
                                typeChain{end+1}='createMATLABStructActionDisable';
                                typeChain{end+1}='moveUpActionDisable';
                                typeChain{end+1}='moveDownActionDisable';
                                typeChain{end+1}='cutActionDisable';
                                typeChain{end+1}='copyActionDisable';
                                typeChain{end+1}='deleteActionDisable';
                                if isempty(clipboardContents)||...
                                    strcmp(this.UIClipboard.type,'element')
                                    typeChain{end+1}='pasteActionDisable';
                                else
                                    if~treeSelRow.hasDictionaryConnection&&anyEnumCB
                                        typeChain{end+1}='pasteActionDisable';
                                    else
                                        typeChain{end+1}='pasteActionEnable';
                                    end
                                end
                            else
                                listSelRow=listSel{1};
                                if isa(listSelRow,'Simulink.typeeditor.app.Element')
                                    allChildren=listSelRow.Parent.Children;
                                    selParents=cellfun(@(sel)sel.Parent,listSel,'UniformOutput',false);

                                    equalFn=@(item)strcmp(item.Name,selParents{1}.Name)&&...
                                    strcmp(class(item),class(selParents{1}));
                                    sameParent=any(arrayfun(@(sel)equalFn(sel),[selParents{2:end}]));

                                    isContiguous=true;
                                    isReadOnly=false;
                                    if sameParent
                                        isReadOnly=any(arrayfun(@(row)row.ReadOnlyElement,[listSel{:}]));
                                        if~isReadOnly
                                            lenSource=length(listSel);
                                            idxArray=arrayfun(@(sourceObj)find(allChildren==sourceObj{1}),listSel);
                                            isTopDown=issorted(idxArray,'strictascend');
                                            if~isTopDown
                                                idxArray=sort(idxArray,'ascend');
                                            end
                                            isContiguous=isequal(diff(idxArray),ones(lenSource-1,1));
                                        end
                                        if isReadOnly
                                            if listSelRow.IsConnectionType
                                                typeChain{end+1}='addConnectionElementActionEnable';
                                                typeChain{end+1}='addBusElementActionDisable';
                                            else
                                                typeChain{end+1}='addConnectionElementActionDisable';
                                                typeChain{end+1}='addBusElementActionEnable';
                                            end
                                        end
                                        if isempty(clipboardContents)
                                            typeChain{end+1}='pasteActionDisable';
                                        elseif strcmp(this.UIClipboard.type,'element')
                                            clipboardItems=[clipboardContents{:}];
                                            clipboardItemsType=all([clipboardItems.IsConnectionType]);
                                            if~isequal(clipboardItemsType,selParents{1}.IsConnectionType)
                                                typeChain{end+1}='pasteActionDisable';
                                            else
                                                typeChain{end+1}='pasteActionEnable';
                                            end
                                        end
                                    else
                                        typeChain{end+1}='addConnectionElementActionDisable';
                                        typeChain{end+1}='addBusElementActionDisable';
                                        if isempty(clipboardContents)||strcmp(this.UIClipboard.type,'element')
                                            typeChain{end+1}='pasteActionDisable';
                                        else
                                            typeChain{end+1}='pasteActionEnable';
                                        end
                                    end
                                    numChildren=length(allChildren);
                                    if~sameParent||isReadOnly||~isContiguous||(numChildren==1)||(length(listSel)==numChildren)
                                        if~sameParent
                                            typeChain{end+1}='cutActionDisable';
                                            typeChain{end+1}='copyActionDisable';
                                            typeChain{end+1}='pasteActionDisable';
                                            typeChain{end+1}='deleteActionDisable';
                                        else
                                            if isReadOnly
                                                typeChain{end+1}='addBusElementActionDisable';
                                                typeChain{end+1}='addConnectionElementActionDisable';
                                                typeChain{end+1}='cutActionDisable';
                                                typeChain{end+1}='pasteActionDisable';
                                                typeChain{end+1}='deleteActionDisable';
                                            else
                                                if listSelRow.IsConnectionType
                                                    typeChain{end+1}='addConnectionElementActionEnable';
                                                    typeChain{end+1}='addBusElementActionDisable';
                                                else
                                                    typeChain{end+1}='addConnectionElementActionDisable';
                                                    typeChain{end+1}='addBusElementActionEnable';
                                                end
                                                typeChain{end+1}='cutActionEnable';
                                                typeChain{end+1}='copyActionEnable';
                                            end
                                        end
                                        typeChain{end+1}='moveUpActionDisable';
                                        typeChain{end+1}='moveDownActionDisable';
                                    else
                                        if listSelRow.IsConnectionType
                                            typeChain{end+1}='addConnectionElementActionEnable';
                                            typeChain{end+1}='addBusElementActionDisable';
                                        else
                                            typeChain{end+1}='addConnectionElementActionDisable';
                                            typeChain{end+1}='addBusElementActionEnable';
                                        end

                                        idxInParent=listSelRow.Parent.findIdx(listSelRow.SourceObject.Name);
                                        if idxInParent==1
                                            typeChain{end+1}='moveUpActionDisable';
                                            typeChain{end+1}='moveDownActionEnable';
                                        elseif idxInParent==numChildren
                                            typeChain{end+1}='moveUpActionEnable';
                                            typeChain{end+1}='moveDownActionDisable';
                                        else
                                            typeChain{end+1}='moveUpActionEnable';
                                            typeChain{end+1}='moveDownActionEnable';
                                        end
                                        typeChain{end+1}='cutActionEnable';
                                        typeChain{end+1}='copyActionEnable';
                                        typeChain{end+1}='deleteActionEnable';
                                    end

                                    typeChain{end+1}='createSimulinkParameterActionDisable';
                                    typeChain{end+1}='createMATLABStructActionDisable';
                                elseif isa(listSelRow,'Simulink.typeeditor.app.Object')
                                    typeChain{end+1}='addConnectionElementActionDisable';
                                    typeChain{end+1}='addBusElementActionDisable';
                                    typeChain{end+1}='createSimulinkParameterActionDisable';
                                    typeChain{end+1}='createMATLABStructActionDisable';
                                    typeChain{end+1}='moveUpActionDisable';
                                    typeChain{end+1}='moveDownActionDisable';
                                    if~treeSelRow.hasDictionaryConnection&&anyEnumSel
                                        typeChain{end+1}='deleteActionDisable';
                                        typeChain{end+1}='cutActionDisable';
                                    else
                                        typeChain{end+1}='deleteActionEnable';
                                        typeChain{end+1}='cutActionEnable';
                                    end
                                    typeChain{end+1}='copyActionEnable';
                                    if isempty(clipboardContents)||strcmp(this.UIClipboard.type,'element')
                                        typeChain{end+1}='pasteActionDisable';
                                    else
                                        if~treeSelRow.hasDictionaryConnection&&anyEnumCB
                                            typeChain{end+1}='pasteActionDisable';
                                        else
                                            typeChain{end+1}='pasteActionEnable';
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if treeSelRow.hasDictionaryConnection
                        this.TreeComp.update(true);
                    end
                end
                typeChain{end+1}='accelerators';
                Simulink.typeeditor.app.ContentsTitle.updateTitle;

                ctx=this.getStudioWindow.getContextObject;
                ctx.TypeChain=typeChain;
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end

            function flag=hasConnectionOrNonBusCheck
                childItems=[childrenItems{:}];
                flag=any([childItems.IsConnectionType])||...
                any(~[childItems.IsBus]);
            end
        end
    end
end