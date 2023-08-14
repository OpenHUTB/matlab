classdef Source<Simulink.typeeditor.app.Node





    properties(Hidden)
NodeConnection
NodeDataAccessor
IsDictionary
        Call_slGetUserDataTypesFromWSDD=false
WorkspaceCache
InvalidTypeCache




        FilterEntriesFromInterfaceDictionary(1,1)logical=true


        MarkForRefresh logical=false
    end

    events
BusElementChanged
BusElementAdded
BusElementRemoved
BusElementMoved
BusObjectRenamed
BusObjectRemoved
    end

    properties(NonCopyable,Hidden)



        RefDictionaryListener event.listener
    end

    methods(Hidden,Access={?Simulink.typeeditor.app.Root,...
        ?Simulink.typeeditor.app.EventData,...
        ?sl.interface.dictionaryApp.source.Source})
        function this=Source(varargin)
            narginchk(0,1);
            if nargin>0
                this.IsDictionary=true;
                filePath=varargin{1};
                this.NodeConnection=Simulink.dd.open(filePath);
                this.NodeDataAccessor=Simulink.data.DataAccessor.createForOutputData(filePath,...
                Section='Design Data');
                if this.useSourceSLDDListener()
                    this.RefDictionaryListener=addlistener(this.getEditor.getSource,'ReferencedSLDDChanged',@this.refDDChangedCB);
                end
            else
                this.NodeConnection=Simulink.data.BaseWorkspace;
                this.NodeDataAccessor=Simulink.data.DataAccessor.createWithNoContext;
                this.IsDictionary=false;
            end
            this.Children=containers.Map;
            this.InvalidTypeCache=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods(Hidden)
        function isDD=hasDictionaryConnection(this)
            isDD=this.IsDictionary;
        end

        function delete(this)
            if this.hasDictionaryConnection
                this.NodeConnection.close;
                this.NodeDataAccessor.delete;
                delete(this.RefDictionaryListener);
            end
            if~isempty(this.Children)
                objs=this.Children.values;
                if~isempty(objs)
                    this.Children.remove(this.Children.keys);
                    delete([objs{:}]);
                end
            end
        end


        function refDDChangedCB(this,~,eventData)
            changedSLDD=eventData.mSourceName;
            if any(strcmp(this.NodeConnection.Dependencies,changedSLDD))
                this.MarkForRefresh=true;
            end
        end



        function notifySLDDChanged(this)
            if this.hasDictionaryConnection
                eventType='ReferencedSLDDChanged';
                eventData=Simulink.typeeditor.app.EventData(eventType,SourceName=this.NodeConnection.filespec);
                root=this.getEditor.getSource;
                if~isempty(root)&&isvalid(root)
                    root.notify(eventType,eventData);
                end
            end
        end


        function refreshDataSourceChildren(this,objName)
            if this.hasDictionaryConnection
                dataSourceDDName=this.getObjectDataSource(objName);
                if strcmp(dataSourceDDName,this.Name)
                    return;
                else
                    ed=this.getEditor;
                    edRoot=ed.getSource;
                    sourceNames={edRoot.Children.Name};
                    referencedNodePresent=strcmp(dataSourceDDName,sourceNames);
                    if~any(referencedNodePresent)
                        return;
                    else
                        referencedNode=edRoot.Children(referencedNodePresent);
                        if~any(strcmp(referencedNode.NodeConnection.filespec,this.NodeConnection.Dependencies))
                            return;
                        else
                            referencedNode.MarkForRefresh=true;
                        end
                    end
                end
            end
        end

        function objDataSourceName=getObjectDataSource(this,objName)
            if this.hasDictionaryConnection
                varID=this.NodeDataAccessor.identifyByName(objName);
                if length(varID)>1
                    [~,objDataSourceName,~]=fileparts(this.NodeConnection.filespec);
                else
                    objDataSource=varID.getDataSourceFriendlyName;
                    objDataSourceNames=split(objDataSource,'.sldd');
                    objDataSourceName=objDataSourceNames{1};
                end
            else
                objDataSourceName='';
            end
        end

        function ch=getChildren(this,~)
            if~isempty(this.Children)
                if this.MarkForRefresh
                    st=this.getEditor.getStudio;
                    statusMsgOld=st.getStatusBarMessage;
                    this.refresh(true);
                    st.setStatusBarMessage(statusMsgOld);
                    this.MarkForRefresh=false;
                end

                ch=this.Children.values;
            else
                this.insertNode('');
                ch=this.Children.values;
            end
            ch=[ch{:}];
        end

        function res=find(this,objName)
            if this.Children.isKey(objName)
                res=this.Children(objName);
            else
                res=Simulink.typeeditor.app.Object.empty;
            end
        end

        function resIdx=findIdx(this,childName)
            resIdx=find(strcmp(childName,{this.Children.keys}));
        end

        function root=getRoot(this)
            root=this;
        end

        function items=getContextMenuItems(this)
            template=struct('label','','checkable',false,'checked',false,'command','','accel','','enabled',true,'icon','');
            if this.hasDictionaryConnection
                closeItem=template;
                closeItem.label=DAStudio.message('Simulink:utility:CloseButton');
                closeItem.command=['Simulink.typeeditor.actions.closeDictionary(''',this.Name,''');'];
                closeItem.accel='Ctrl+Q';
                closeItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('close_16.png');
                closeItem.tag='closeSLDD';
                items=closeItem;

                changesPresent=this.hasDictionaryConnection&&this.NodeConnection.hasUnsavedChanges;
                saveItem=template;
                saveItem.label=DAStudio.message('SLDD:sldd:ContextSaveChanges_Label');
                saveItem.command=['Simulink.typeeditor.actions.saveDictionary(''',this.Name,''');'];
                saveItem.accel='Ctrl+S';
                saveItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('saveExistingDictionary_16.png');
                saveItem.enabled=changesPresent;
                saveItem.tag='saveSLDD';
                items(end+1)=saveItem;

                revertItem=template;
                revertItem.label=DAStudio.message('SLDD:sldd:ShowChangesRevert');
                revertItem.command=['Simulink.typeeditor.actions.revertDictionary(''',this.Name,''');'];
                revertItem.accel='Ctrl+R';
                revertItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('revert_16.png');
                revertItem.enabled=changesPresent;
                revertItem.tag='revertSLDD';
                items(end+1)=revertItem;
            else
                ed=this.getEditor;

                childrenItems=ed.getListComp.imSpreadSheetComponent.getChildrenItems(this);
                if isempty(childrenItems)
                    isEmpty=true;
                    hasConnectionBus=false;
                    hasNonBusTypes=false;
                else
                    isEmpty=false;
                    childRows=[childrenItems{:}];
                    hasConnectionBus=any([childRows.IsConnectionType]);
                    hasNonBusTypes=~all([childRows.IsBus]);
                end

                exportItemSub1=template;
                exportItemSub1.label=DAStudio.message('Simulink:busEditor:ExportMAT');
                exportItemSub1.accel='Ctrl+T';
                exportItemSub1.command='Simulink.typeeditor.actions.exportFromEditor(''MAT'', [])';
                exportItemSub1.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('matFile_16.png');
                exportItemSub1.enabled=~isEmpty;
                exportItemSub1.tag='exportMAT';
                subItems=exportItemSub1;

                exportItemSub2=template;
                exportItemSub2.label=DAStudio.message('Simulink:busEditor:ExportMCell');
                exportItemSub2.accel='Ctrl+L';
                exportItemSub2.command='Simulink.typeeditor.actions.exportFromEditor(''Cell'', [])';
                exportItemSub2.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('mFile_16.png');
                exportItemSub2.enabled=~isEmpty&&~hasConnectionBus&&~hasNonBusTypes;
                exportItemSub2.tag='exportMCell';
                subItems(end+1)=exportItemSub2;

                exportItemSub3=template;
                exportItemSub3.label=DAStudio.message('Simulink:busEditor:ExportMObject');
                exportItemSub3.accel='Ctrl+J';
                exportItemSub3.command='Simulink.typeeditor.actions.exportFromEditor(''Object'', [])';
                exportItemSub3.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('mFile_16.png');
                exportItemSub3.enabled=~isEmpty;
                exportItemSub3.tag='exportMObject';
                subItems(end+1)=exportItemSub3;

                exportItem=template;
                exportItem.label=DAStudio.message('Simulink:busEditor:ExportContext');
                exportItem.command=subItems;
                items=exportItem;
            end
        end

        function label=getDisplayLabel(this)
            label=this.getNodeName(false);
            if(this.hasDictionaryConnection)
                if this.NodeConnection.hasUnsavedChanges
                    label=[label,'*'];
                end
            end
        end

        function label=getNodeName(this,varargin)
            informal=false;

            if nargin>1
                informal=varargin{1};
            end

            if(this.hasDictionaryConnection)
                [~,name,~]=fileparts(this.NodeConnection.filespec);
                label=name;
            else
                if informal
                    label=DAStudio.message('Simulink:busEditor:RootDisplayTitle_informal');
                else
                    label=DAStudio.message('Simulink:busEditor:BaseNodeUntranslated');
                end
            end
        end

        function fileName=getDisplayIcon(this)
            if this.hasDictionaryConnection
                fileName=Simulink.typeeditor.utils.getBusEditorResourceFile('sldd_16.png');
            else
                fileName=fullfile(matlabroot,'toolbox','shared','dastudio','resources','BaseWorkspace.png');
            end
        end

        function dlgStruct=getDialogSchema(~)
            rootEdit.Type='textbrowser';
            if slfeature('TypeEditorStudio')>0
                rootEdit.Text=DAStudio.message('Simulink:busEditor:RootDisplayHelpTypeEditor');
            else
                rootEdit.Text=DAStudio.message('Simulink:busEditor:RootDisplayHelpConnectionBus');
            end
            rootEdit.Tag='NodeDescription';

            dlgStruct.DialogTitle='';
            dlgStruct.Items={rootEdit};
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.DialogMode='Slim';
            dlgStruct.DialogTag='BusEditorSourcePIDialog';
        end

        function propValue=getPropValue(~,propName)
            switch propName
            case 'Name'
                propValue=DAStudio.message('Simulink:busEditor:RootDisplayLabel');
            otherwise
                propValue='N/A';
            end
        end

        function isValid=isValidProperty(~,propName)
            switch propName
            case 'Name'
                isValid=true;
            otherwise
                isValid=false;
            end
        end

        function insertNode(this,names)


            try
                objs=this.getWorkspaceObjects;
                this.WorkspaceCache=objs;
                if~isempty(objs)
                    keys=objs(:,1);
                else
                    keys={};
                end
                addAll=isempty(names);
                if addAll
                    names=keys;
                    for idx=1:length(keys)
                        this.addChild(keys{idx},objs{idx,2});
                    end
                else
                    for idx=1:length(keys)
                        curName=keys{idx};
                        strMatch=strcmp(names,curName);
                        if any(strMatch)
                            this.addChild(curName,objs{idx,2});
                        end
                    end
                end

                for i=1:length(names)
                    if this.Children(names{i}).IsBus
                        if this.InvalidTypeCache.isKey(names{i})
                            this.InvalidTypeCache(names{i})=unique([this.InvalidTypeCache(names{i}),names(i)]);
                        else
                            this.InvalidTypeCache(names{i})=names(i);
                        end

                        if addAll
                            idxInCache=i;
                        else
                            idxInCache=strcmp(names{i},this.WorkspaceCache(:,1));
                        end


                        if this.IsDictionary
                            if this.Children(names{i}).IsConnectionType
                                clsName=Simulink.typeeditor.app.Editor.AdditionalBaseType;
                            else
                                clsName=Simulink.typeeditor.app.Editor.DefaultBaseType;
                            end
                            depTypes=eval([clsName,'.getDependentTypesWrtSLDD(names{i}, this.NodeConnection.filespec, true)']);
                        else
                            depTypes=this.WorkspaceCache{idxInCache,2}.getDependentTypesWrtBaseWS(true);
                        end

                        curChild=this.find(names{i});
                        if any(strcmp(names{i},depTypes))
                            curChild.FlaggedBySource=true;
                        end

                        for j=1:length(depTypes)
                            if this.InvalidTypeCache.isKey(depTypes{j})
                                this.InvalidTypeCache(depTypes{j})=unique([this.InvalidTypeCache(depTypes{j}),names(i)]);
                            else
                                this.InvalidTypeCache(depTypes{j})=names(i);
                            end
                        end
                    end
                end
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function deleteNode(this,names,clearVars)


            try
                if clearVars
                    varStr=join(names,' ');
                    varID=this.NodeDataAccessor.identifyByName(varStr{1});
                    this.NodeDataAccessor.deleteVariable(varID);
                end
                for i=1:length(names)
                    delete(this.Children(names{i}));
                end
                this.Children.remove(names);
                [~,idxs]=ismember(names,this.WorkspaceCache(:,1));
                this.WorkspaceCache(idxs,:)=[];
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function addChild(this,name,obj)


            if this.Children.isKey(name)
                this.deleteChild(name,true,false);
            end
            this.Children(name)=Simulink.typeeditor.app.Object(name,obj,this);
        end

        function workspaceObjects=getWorkspaceObjects(this)



            if slfeature('TypeEditorStudio')>0
                types=Simulink.typeeditor.app.Editor.AcceptableTypes(:,1)';
            else
                types={Simulink.typeeditor.app.Editor.DefaultBaseType,...
                Simulink.typeeditor.app.Editor.AdditionalBaseType};
            end

            isDD=this.hasDictionaryConnection;
            visibleVarIDs=this.NodeDataAccessor.identifyVisibleVariables;
            visibleVarNames={visibleVarIDs.Name};
            visibleVarNames=unique(visibleVarNames,'stable');
            numVars=length(visibleVarNames);
            visibleVars=cell(1,numVars);
            if isDD
                [~,ddName,~]=fileparts(this.NodeConnection.filespec);
                ddName=[ddName,'.sldd'];
            end
            skipCheckForItfSLDD=false(1,numVars);
            for i=1:numVars
                idForVar=this.NodeDataAccessor.identifyByName(visibleVarNames{i});
                numVarsForCurrID=length(idForVar);
                if numVarsForCurrID>1
                    assert(isDD);
                    for j=1:numVarsForCurrID
                        if strcmp(idForVar(j).getDataSourceFriendlyName,ddName)




                            skipCheckForItfSLDD(i)=true;
                            idForVar=idForVar(j);
                            break;
                        end
                    end
                end
                if isscalar(idForVar)
                    varFromID=this.NodeDataAccessor.getVariable(idForVar);
                    if any(cellfun(@(type)isa(varFromID,type),types))
                        visibleVars{i}=this.NodeDataAccessor.getVariable(idForVar);
                    end
                end
            end

            validVars=cellfun(@isempty,visibleVars);
            visibleVarNames=visibleVarNames(~validVars);
            visibleVars=visibleVars(~validVars);
            skipCheckForItfSLDD=skipCheckForItfSLDD(~validVars);

            scalarVars=cellfun(@isscalar,visibleVars);
            visibleVarNames=visibleVarNames(scalarVars);
            visibleVars=visibleVars(scalarVars);
            skipCheckForItfSLDD=skipCheckForItfSLDD(scalarVars);

            if isDD&&~isempty(visibleVarNames)
                [visibleVarNames,visibleVars]=this.filterEntriesFromInterfaceDictionary(visibleVarNames,...
                visibleVars,skipCheckForItfSLDD);
            end

            numVars=length(visibleVarNames);
            if numVars>0
                workspaceObjects=cell(numVars,2);
                for i=1:numVars
                    workspaceObjects{i,1}=visibleVarNames{i};
                    workspaceObjects{i,2}=visibleVars{i};
                end
            else
                workspaceObjects=cell.empty;
            end
        end

        function refresh(this,varargin)
            narginchk(1,2);
            ed=this.getEditor;
            listSelections=ed.getListComp.getSelection;
            st=ed.getStudio;

            if this.shouldPublishStatusMsgOnStudioAppWindow()
                statusMsg=DAStudio.message('Simulink:busEditor:BusEditorLoadingInProgressStatusMsg');
            else
                statusMsg='';
            end

            updateGUI=false;
            if~isempty(this.WorkspaceCache)
                wksCacheNames=this.WorkspaceCache(:,1);
                wksCacheObjs=this.WorkspaceCache(:,2);
            else
                wksCacheNames={};
                wksCacheObjs={};
            end
            wksObjs=this.getWorkspaceObjects;
            if~isempty(wksObjs)
                wksObjsNames=wksObjs(:,1);
            else
                wksObjsNames=cell.empty;
            end

            if~all(ismember(wksCacheNames,wksObjsNames))||...
                (length(wksCacheNames)~=length(wksObjsNames))
                st.setStatusBarMessage(statusMsg);
                addedObjs=setdiff(wksObjsNames,wksCacheNames');
                removedObjs=setdiff(wksCacheNames',wksObjsNames);

                if~isempty(removedObjs)
                    eventType='BusObjectRemoved';
                    for i=1:length(removedObjs)
                        rowName=removedObjs{i};
                        rowObj=this.find(rowName);
                        assert(~isempty(rowObj));
                        rowIsBus=rowObj.IsBus;
                        rowIsConnection=rowObj.IsConnectionType;
                        if rowIsBus
                            eventData=Simulink.typeeditor.app.EventData(eventType,BusName=rowName,IsConnType=rowIsConnection);
                            this.notify(eventType,eventData);
                        end
                    end
                    this.deleteNode(removedObjs,false);
                    updateGUI=true;
                end

                if~isempty(addedObjs)
                    this.insertNode(addedObjs);
                    updateGUI=true;
                end
            end


            modifiedObjs=cell.empty;
            commonObjNames=intersect(wksObjsNames,wksCacheNames','stable');
            objsWithModifiedElems=[];
            for i=1:length(commonObjNames)
                objName=commonObjNames{i};
                objIdx=strcmp(objName,wksCacheNames);
                if~isequal(wksObjs{i,2},wksCacheObjs{objIdx})
                    if isequal(class(wksObjs{i,2}),class(wksCacheObjs{objIdx}))



                        if isa(wksObjs{i,2},Simulink.typeeditor.app.Editor.DefaultBaseType)||...
                            isa(wksObjs{i,2},Simulink.typeeditor.app.Editor.AdditionalBaseType)
                            objsWithModifiedElems(end+1)=~isequal(wksObjs{i,2}.Elements,wksCacheObjs{objIdx}.Elements);%#ok<AGROW>
                        end
                        modifiedObjs(end+1)=wksObjsNames(i);%#ok<AGROW>
                    else

                        this.deleteNode({objName},false);
                        this.insertNode({objName});
                        updateGUI=true;
                    end
                end
            end
            if~isempty(modifiedObjs)
                clsName1=Simulink.typeeditor.app.Editor.DefaultBaseType;
                clsName2=Simulink.typeeditor.app.Editor.AdditionalBaseType;
                st.setStatusBarMessage(statusMsg);
                for i=1:length(modifiedObjs)

                    node=Simulink.typeeditor.utils.getNodeFromPath(this,modifiedObjs{i});
                    if isa(node.SourceObject,'Simulink.data.dictionary.EnumTypeDefinition')
                        if node.Parent.hasDictionaryConnection
                            delete(node.EnumDDGSource);
                            node.EnumDDGSource=Simulink.dd.EntryDDGSource(node.Parent.NodeConnection,['Design_Data.',node.Name],true);
                            node.SourceObject=node.EnumDDGSource.getForwardedObject;
                        else
                            node.SourceObject=Simulink.data.dictionary.EnumTypeDefinition.convertFromEnumTypeSpec(wksObjs{strcmp(modifiedObjs{i},wksObjsNames),2});
                        end
                    else
                        node.SourceObject=wksObjs{strcmp(modifiedObjs{i},wksObjsNames),2};
                    end

                    modifiedObjIdx=strcmp(modifiedObjs{i},this.WorkspaceCache(:,1));
                    oldObj=this.WorkspaceCache{modifiedObjIdx,2};
                    this.WorkspaceCache{modifiedObjIdx,2}=node.SourceObject;
                    if node.IsBus&&objsWithModifiedElems(i)

                        eventType='BusObjectRemoved';
                        eventData=Simulink.typeeditor.app.EventData(eventType,BusName=node.Name,IsConnType=node.IsConnectionType);
                        this.notify(eventType,eventData);


                        wksObjElems=node.SourceObject.Elements;
                        numElems=length(wksObjElems);
                        delete(node.Children);
                        node.Children=Simulink.typeeditor.app.Element.empty;
                        for j=1:numElems
                            node.Children(j)=Simulink.typeeditor.app.Element(wksObjElems(j),node,false);

                            eventType='BusElementAdded';
                            eventData=Simulink.typeeditor.app.EventData(eventType,BusName=node.Name,ElemName=node.Children(j).Name,...
                            ElemIdx=j-1,IsConnType=node.IsConnectionType,ElemObj=node.Children(j).SourceObject);
                            this.notify(eventType,eventData);
                        end


                        if this.hasDictionaryConnection
                            if node.IsConnectionType
                                clsName=clsName2;
                            else
                                clsName=clsName1;
                            end
                            if isa(oldObj,clsName1)||...
                                isa(oldObj,clsName2)
                                tmpVar='default';
                                ddFlag=this.NodeConnection.hasUnsavedChanges;
                                tmpVarID=this.NodeDataAccessor.createVariableAsLocalData(tmpVar,oldObj);
                                depTypesOld=eval([clsName,'.getDependentTypesWrtSLDD(''',tmpVar,''', this.NodeConnection.filespec, true)']);
                                this.NodeDataAccessor.deleteVariable(tmpVarID);
                                if~ddFlag
                                    this.NodeConnection.discardChanges;
                                end
                            else
                                depTypesOld=cell.empty;
                            end
                            depTypesNew=eval([clsName,'.getDependentTypesWrtSLDD(node.Name, this.NodeConnection.filespec, true)']);
                        else
                            if isa(oldObj,clsName1)||...
                                isa(oldObj,clsName2)
                                depTypesOld=oldObj.getDependentTypesWrtBaseWS(true);
                            else
                                depTypesOld=cell.empty;
                            end
                            depTypesNew=node.SourceObject.getDependentTypesWrtBaseWS(true);
                        end

                        if any(strcmp(node.Name,depTypesNew))
                            node.FlaggedBySource=true;
                        end

                        addedDepTypes=setdiff(depTypesNew,depTypesOld);
                        removedDepTypes=setdiff(depTypesOld,depTypesNew);
                        if~isempty(addedDepTypes)
                            for j=addedDepTypes
                                if this.InvalidTypeCache.isKey(j{1})
                                    this.InvalidTypeCache(j{1})=unique([this.InvalidTypeCache(j{1}),{node.Name}]);
                                else
                                    this.InvalidTypeCache(j{1})={node.Name};
                                end
                            end
                        end
                        if~isempty(removedDepTypes)
                            for k=removedDepTypes
                                assert(this.InvalidTypeCache.isKey(k{1}));
                                vals=this.InvalidTypeCache(k{1});
                                this.InvalidTypeCache(k{1})=vals(~strcmp(vals,node.Name));
                            end
                        end
                    end
                end
                updateGUI=true;
            end
            overrideUpdate=false;
            if nargin>1
                overrideUpdate=varargin{1};
            end
            if updateGUI&&~overrideUpdate&&~this.skipGUIUpdateOnRefresh()
                if ed.hasTreeComp()
                    ed.getTreeComp.update(true);
                end
                lc=ed.getListComp;
                lc.update(true);


                if~isempty(listSelections)
                    lc.view(listSelections(isvalid([listSelections{:}])));
                else
                    lc.view([]);
                end
                dlg=ed.getDialogHandle;
                if~isempty(dlg)&&ishandle(dlg)
                    dlg.refresh;
                end
                srcChildren=this.Children.values;
                srcChildrenArr=[srcChildren{:}];
                [srcChildrenArr.NeverExpanded]=deal(true);
            end



            this.MarkForRefresh=false;
        end
    end

    methods(Access=public)
        function useSourceSLDDListener=useSourceSLDDListener(~)


            useSourceSLDDListener=true;
        end
    end

    methods(Access=protected)
        function val=getValueForName(this)
            val=this.getNodeName;
        end

        function shouldSkip=skipGUIUpdateOnRefresh(~)


            shouldSkip=false;
        end

        function shouldPublish=shouldPublishStatusMsgOnStudioAppWindow(~)


            shouldPublish=true;
        end
    end


    methods(Hidden)

        function out=getPropertySchema(this)
            out=this;
        end

        function s=getObjectName(this)
            s=this.getNodeName(false);
        end

        function objType=getObjectType(this)
            objType='';
            if this.hasDictionaryConnection
                objType=DAStudio.message('Simulink:busEditor:SLDDText');
            end
        end

        function tf=supportTabView(~)
            tf=false;
        end

        function mode=rootNodeViewMode(~,rootProp)
            mode='Undefined';
            if isempty(rootProp)||strcmp(rootProp,'Simulink:Model:Properties')
                mode='SlimDialogView';
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='Simulink:Model:Properties';
            end
        end

        function showPropertyHelp(~,prop)
            if isempty(prop)
                slprophelp('buseditor');
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'Simulink:Model:Properties')
                label=getString(message('Slvnv:slreq:Details'));
            end
        end
    end

    methods(Access=private)
        function[objectNames,entries]=filterEntriesFromInterfaceDictionary(this,objectNames,entries,skipCheck)
            if~this.FilterEntriesFromInterfaceDictionary


                return;
            end



            numObjsToFilter=length(objectNames);
            entryDataSources=cell(1,numObjsToFilter);
            for i=1:numObjsToFilter
                if~skipCheck(i)
                    varID=this.NodeDataAccessor.identifyByName(objectNames{i});
                    entryDataSources{i}=varID.getDataSourceFriendlyName;
                end
            end
            emptySources=cellfun('isempty',entryDataSources);
            entryDataSources=entryDataSources(~emptySources);




            uniqueDataSources=unique(entryDataSources,'stable');
            isEntryFromInterfaceDictionary=false(1,length(uniqueDataSources));
            for srcIdx=1:length(uniqueDataSources)
                curSource=uniqueDataSources{srcIdx};
                ddConn=Simulink.data.dictionary.open(curSource);
                isEntryFromInterfaceDictionary(srcIdx)=...
                sl.interface.dict.api.isInterfaceDictionary(ddConn.filepath);
            end


            interfaceDictSources=uniqueDataSources(isEntryFromInterfaceDictionary);
            entriesFromInterfaceDict=ismember(entryDataSources,interfaceDictSources);
            entries(entriesFromInterfaceDict)=[];
            objectNames(entriesFromInterfaceDict)=[];
        end
    end
end



