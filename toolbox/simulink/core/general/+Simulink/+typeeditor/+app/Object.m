classdef Object<Simulink.typeeditor.app.Node




    properties(Hidden)
        IsBus logical=true
        IsConnectionType logical=false
        IsEnum logical=false
MimeData
        LoadImmediateChildren logical=true
        ChildrenLoadedBeforeQuery logical=false
        NeverExpanded logical=true
        FlaggedBySource logical=false
        EnumDDGSource Simulink.dd.EntryDDGSource


UDTAssistOpen
UDTIPOpen
        DataTypeProp meta.DynamicProperty

        HighlightMode logical=false
        IsDerived logical=false

        ReferencedSLDDConnection Simulink.dd.Connection=Simulink.dd.Connection.empty
    end

    properties(NonCopyable,Hidden)
        BusElemListener event.listener
    end

    properties(Access=private,Constant,Hidden)



        NameColHeader=DAStudio.message('Simulink:busEditor:PropElementName')
        DataScopeColHeader=DAStudio.message('Simulink:busEditor:PropDataScope')
        HeaderFileColHeader=DAStudio.message('Simulink:busEditor:PropHeaderFile')
        AlignmentColHeader=DAStudio.message('Simulink:busEditor:PropAlignment')
        PreserveElementDimensionsColHeader=DAStudio.message('Simulink:busEditor:PropPreserveElementDimensions')
        DescriptionColHeader=DAStudio.message('Simulink:busEditor:PropDescription')
        BaseTypeColHeader=DAStudio.message('Simulink:busEditor:PropBaseType')
        DataTypeModeColHeader=DAStudio.message('Simulink:busEditor:PropDataTypeMode')
        TypeColHeader=DAStudio.message('Simulink:busEditor:PropType')
        IsAliasColHeader=DAStudio.message('Simulink:busEditor:PropIsAlias')




        HighlightColor=[0.5882,0.0471,0.4549,0.149]
    end

    properties(Access=private)
        BusesRenamed;
    end

    methods(Static,Hidden)
        function props=getColumnProperties
            if slfeature('TypeEditorStudio')>0
                props={Simulink.typeeditor.app.Object.NameColHeader,...
                Simulink.typeeditor.app.Object.TypeColHeader,...
                Simulink.typeeditor.app.Object.DataScopeColHeader,...
                Simulink.typeeditor.app.Object.HeaderFileColHeader,...
                Simulink.typeeditor.app.Object.AlignmentColHeader,...
                Simulink.typeeditor.app.Object.PreserveElementDimensionsColHeader,...
                Simulink.typeeditor.app.Object.DescriptionColHeader};
            else
                props={Simulink.typeeditor.app.Object.NameColHeader,...
                Simulink.typeeditor.app.Object.DataScopeColHeader,...
                Simulink.typeeditor.app.Object.HeaderFileColHeader,...
                Simulink.typeeditor.app.Object.AlignmentColHeader,...
                Simulink.typeeditor.app.Object.PreserveElementDimensionsColHeader,...
                Simulink.typeeditor.app.Object.DescriptionColHeader};
            end
        end

        function props=getPropertiesForDefaultView
            props={Simulink.typeeditor.app.Object.DataScopeColHeader,...
            Simulink.typeeditor.app.Object.HeaderFileColHeader,...
            Simulink.typeeditor.app.Object.AlignmentColHeader,...
            Simulink.typeeditor.app.Object.PreserveElementDimensionsColHeader};
        end
    end

    methods(Static)
        function onQuickEdit(~,obj,~)
            obj.LoadImmediateChildren=true;
            obj.ChildrenLoadedBeforeQuery=false;
            ed=Simulink.typeeditor.app.Editor.getInstance;
            ed.getListComp.update(true);
        end
    end

    methods(Access=protected)
        function objCopy=copyElement(obj)

            objCopy=copyElement@matlab.mixin.Copyable(obj);


            if~isempty(obj.Children)
                objCopy.Children=copy(obj.Children);
            end
        end

        function saveEnumEntry(this,dlg)

            this.EnumDDGSource.saveEntry(dlg,this);
        end

        function setEnumPropValue(this,propName,propValue)

            this.EnumDDGSource.setPropValue(propName,propValue);
        end
    end

    methods(Hidden,Access={?Simulink.typeeditor.app.Source,...
        ?sl.interface.dictionaryApp.node.typeeditor.ObjectAdapter})
        function this=Object(name,obj,parent)
            this.Name=name;
            this.Path=this.Name;
            this.IsConnectionType=isa(obj,Simulink.typeeditor.app.Editor.AdditionalBaseType);
            this.IsBus=isa(obj,Simulink.typeeditor.app.Editor.DefaultBaseType)||this.IsConnectionType;
            this.IsEnum=~this.IsBus&&isa(obj,'Simulink.data.dictionary.EnumTypeDefinition');
            if this.IsEnum
                if parent.hasDictionaryConnection
                    nodeConnForEnum=parent.NodeConnection;
                    this.EnumDDGSource=Simulink.dd.EntryDDGSource(nodeConnForEnum,['Design_Data.',this.Name],true);
                    this.SourceObject=this.EnumDDGSource.getForwardedObject;
                else
                    this.SourceObject=Simulink.data.dictionary.EnumTypeDefinition.convertFromEnumTypeSpec(obj);
                end
            else
                this.SourceObject=obj;
            end

            if parent.hasDictionaryConnection
                nodeConn=parent.NodeConnection;
                slddFile=nodeConn.filespec;
                entries=Simulink.dd.getEntryInfoFromDictionaries({slddFile},'Design Data','Name',{this.Name});
                if length(entries)>1
                    currSrcIdx=strcmp(slddFile,{entries.DataSource});
                    entryID=entries(currSrcIdx).EntryID;
                else
                    entryID=entries.EntryID;
                end
                this.IsDerived=nodeConn.getIsEntryDerived(entryID);
            end

            this.Children=Simulink.typeeditor.app.Element.empty;
            this.updateRoot(parent);
            this.getRoot.Call_slGetUserDataTypesFromWSDD=true;
            this.DialogTag='BusObjectPIDialog';
            if~this.IsBus
                dtTag=this.getPropNameForType;
                templateDTA=struct('tags',{{dtTag}},'status',{{false}});
                this.UDTAssistOpen=templateDTA;
                this.UDTIPOpen=templateDTA;
                if isa(this.SourceObject,'Simulink.ValueType')
                    this.DataTypeProp=addprop(this,'DataType');
                    this.DataTypeProp.Hidden=true;
                    this.DataTypeProp.SetMethod=@(this,val)setDataTypeForVT(this,val);
                    this.DataTypeProp.GetMethod=@(this)getDataTypeForVT(this);
                end
            end
            this.BusesRenamed=containers.Map('KeyType','char','ValueType','char');


            kvPairsList=GLEE.ByteArrayList;
            summary=GLEE.ByteArrayPair(GLEE.ByteArray('foo'),GLEE.ByteArray('bar'));
            kvPairsList.add(summary);
            this.MimeData=kvPairsList;
        end
    end

    methods(Hidden)
        function setDataTypeForVT(this,val)
            this.SourceObject.DataType=val;
        end

        function val=getDataTypeForVT(this)
            val=this.SourceObject.DataType;
        end

        function updateRoot(this,sourceObj)

            this.Parent=sourceObj;


            if~isempty(this.BusElemListener)&&this.IsBus
                delete(this.BusElemListener);
            end

        end

        function delete(this)
            objs=this.Children;
            if~isempty(objs)
                this.Children=[];
                delete(objs);
            end
            delete(this.BusElemListener);
            if isa(this.SourceObject,'Simulink.ValueType')
                delete(this.DataTypeProp);
            end
            if~isempty(this.ReferencedSLDDConnection)
                if this.ReferencedSLDDConnection.isOpen
                    this.ReferencedSLDDConnection.close;
                end
                delete(this.ReferencedSLDDConnection);
            end
        end


        function data=getMimeData(this)
            data=this.MimeData;
        end


        function mimeType=getMimeType(~)
            mimeType='application/buseditor-mimetype';
        end

        function nestedBusRenamedCB(this,~,eventData)
            if~isempty(this.Children)||(this.IsConnectionType~=eventData.mIsConnType)||strcmp(this.Name,eventData.mElemName)
                return;
            end
            this.BusesRenamed(eventData.mBusName)=eventData.mElemName;
        end

        function label=getDisplayLabel(this)
            label=this.Name;
        end

        function fileName=getDisplayIcon(this)
            if this.IsBus
                if this.IsConnectionType
                    iconName='connection_bus_object.png';
                else
                    iconName='bus_object.png';
                end
            else
                if isa(this.SourceObject,'Simulink.AliasType')
                    iconName='typeSimAlias_16.png';
                elseif isa(this.SourceObject,'Simulink.NumericType')
                    iconName='typeSimNumeric_16.png';
                elseif this.IsEnum
                    iconName='typeEnum_16.png';
                else
                    assert(isa(this.SourceObject,'Simulink.ValueType'));
                    fileName=this.SourceObject.getDisplayIcon;
                    return;
                end
            end
            fileName=Simulink.typeeditor.utils.getBusEditorResourceFile(iconName);
        end

        function getPropertyStyle(this,propName,propStyleObj)
            typeProp=DAStudio.message('Simulink:busEditor:PropType');
            if strcmp(propName,typeProp)
                if this.isValidProperty(typeProp)
                    typePropName=this.getPropNameForType;
                    propStyleObj.Tooltip=[this.getPropValue(typePropName),' (',typePropName,')'];
                end
            end
            if this.InErrorOrWarning.Mode
                errPropName=this.InErrorOrWarning.Property;
                if strcmp(propName,errPropName)
                    errType=this.InErrorOrWarning.State;
                    errMsg=this.InErrorOrWarning.Message;
                    propStyleObj.Tooltip=errMsg;
                    if strcmp(errType,'Error')
                        propStyleObj.Icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','error_16.png');
                    else
                        propStyleObj.Icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning_16.png');
                    end
                    propStyleObj.IconAlignment='right';
                end
            end
            if this.HighlightMode
                propStyleObj.BackgroundColor=this.HighlightColor;
            else
                if~this.isValidProperty(propName)
                    bg=double(propStyleObj.BackgroundColor);
                    bg(1:3)=0.95*ones(1,3);
                    propStyleObj.BackgroundColor=bg;
                    return;
                end
                if this.isReadonlyProperty(propName)||this.IsDerived
                    bg=double(propStyleObj.BackgroundColor);
                    bg(1:3)=0.95*ones(1,3);
                    propStyleObj.BackgroundColor=bg;
                    propStyleObj.Italic=true;
                    return;
                end






            end
        end

        function dlgStruct=getDialogSchema(this)
            if this.IsBus
                enableDialog=~this.isInMultiselect;

                busnameEdit.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
                busnameEdit.Type='edit';
                busnameEdit.RowSpan=[1,1];
                busnameEdit.ColSpan=[1,1];
                busnameEdit.Value=this.Name;
                busnameEdit.Enabled=enableDialog;
                busnameEdit.Tag='Name';



                busnameEdit.Mode=true;
                busnameEdit.ObjectProperty=this.NameColHeader;
                busnameEdit.Graphical=true;

                isConnType=this.IsConnectionType;

                if~isConnType
                    grpCodeGen.Items={};

                    dataScopeEdit.Name=DAStudio.message('Simulink:dialog:StructtypeDataScopeLblName');
                    dataScopeEdit.Type='combobox';
                    dataScopeEdit.Entries={DAStudio.message('Simulink:dialog:Auto_CB'),DAStudio.message('Simulink:dialog:Exported_CB'),DAStudio.message('Simulink:dialog:Imported_CB')};
                    dataScopeEdit.RowSpan=[1,1];
                    dataScopeEdit.ColSpan=[1,3];
                    dataScopeEdit.Value=find(strcmp(this.SourceObject.getPropAllowedValues('DataScope'),this.SourceObject.getPropValue('DataScope'))==1)-1;
                    dataScopeEdit.Tag='DataScope';
                    dataScopeEdit.Mode=true;
                    dataScopeEdit.ObjectProperty=this.DataScopeColHeader;
                    dataScopeEdit.Graphical=true;
                    dataScopeEdit.Enabled=enableDialog;

                    grpCodeGen.Items{1}=dataScopeEdit;

                    headerEdit.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
                    headerEdit.Type='edit';
                    headerEdit.RowSpan=[2,2];
                    headerEdit.ColSpan=[1,3];
                    headerEdit.Value=this.SourceObject.HeaderFile;
                    headerEdit.Tag='HeaderFile';
                    headerEdit.Mode=true;
                    headerEdit.ObjectProperty=this.HeaderFileColHeader;
                    headerEdit.Graphical=true;
                    headerEdit.Enabled=enableDialog;

                    grpCodeGen.Items{2}=headerEdit;

                    alignmentEdit.Name=[DAStudio.message('Simulink:dialog:StructtypeAlignmentLblName'),': '];
                    alignmentEdit.Type='edit';
                    alignmentEdit.RowSpan=[3,3];
                    alignmentEdit.ColSpan=[1,3];
                    alignmentEdit.Value=num2str(this.SourceObject.Alignment);
                    alignmentEdit.Tag='Alignment';
                    alignmentEdit.Mode=true;
                    alignmentEdit.ObjectProperty=this.AlignmentColHeader;
                    alignmentEdit.Graphical=true;
                    alignmentEdit.Enabled=enableDialog;

                    grpCodeGen.Items{3}=alignmentEdit;

                    if slfeature('NdIndexingBusUI')==1
                        preserveDimsCheckbox.Name=DAStudio.message('Simulink:dialog:StructtypePreserveDimsLblName');
                        preserveDimsCheckbox.Type='checkbox';
                        preserveDimsCheckbox.RowSpan=[4,4];
                        preserveDimsCheckbox.ColSpan=[1,3];
                        preserveDimsCheckbox.Value=this.SourceObject.PreserveElementDimensions;
                        preserveDimsCheckbox.Tag='PreserveElementDimensions';
                        preserveDimsCheckbox.Mode=true;
                        preserveDimsCheckbox.ObjectProperty=this.PreserveElementDimensionsColHeader;
                        preserveDimsCheckbox.Graphical=true;
                        preserveDimsCheckbox.Enabled=enableDialog;

                        grpCodeGen.Items{4}=preserveDimsCheckbox;
                        grpCodeGen.LayoutGrid=[5,2];
                        grpCodeGen.RowStretch=[0,0,0,0,1];
                    else
                        grpCodeGen.LayoutGrid=[4,2];
                        grpCodeGen.RowStretch=[0,0,0,1];
                    end

                    grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
                    grpCodeGen.RowSpan=[1,1];
                    grpCodeGen.ColSpan=[1,3];
                    grpCodeGen.Tag='grpCodeGen_tag';
                    grpCodeGen.Type='togglepanel';
                    grpCodeGen.Expand=false;
                end

                descEdit.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
                descEdit.Type='editarea';
                descEdit.RowSpan=[2,2];
                descEdit.ColSpan=[1,1];
                descEdit.Value=this.SourceObject.Description;
                descEdit.Tag='Description';
                descEdit.Mode=true;
                descEdit.ObjectProperty=this.DescriptionColHeader;
                descEdit.Graphical=true;
                descEdit.Enabled=enableDialog;

                grpDesc.Name=DAStudio.message('Simulink:busEditor:DDGProperties');
                grpDesc.Items={busnameEdit,descEdit};
                grpDesc.ColStretch=[1];%#ok<NBRAK>
                grpDesc.LayoutGrid=[2,1];
                grpDesc.Type='togglepanel';
                grpDesc.Expand=true;
                grpDesc.Tag='descGrptag';





                [grpUserData,~]=sldialogs('get_userdata_prop_grp',this.SourceObject);




                dlgStruct.DialogTitle='';

                outerPanel.Type='panel';
                outerPanel.Tag='Tabcont';
                if isempty(grpUserData.Items)
                    if isConnType
                        outerPanel.Items={grpDesc};
                    else
                        outerPanel.Items={grpDesc,grpCodeGen};
                    end
                else
                    outerPanel.Items={grpDesc,grpCodeGen,grpUserData};


                    dlgStruct.Items=sldialogs('remove_duplicate_widget_tags',dlgStruct.Items);
                end
                dlgStruct.Items={outerPanel};
            else
                if this.IsEnum
                    if this.Parent.hasDictionaryConnection
                        enumVarID=this.Parent.NodeDataAccessor.identifyByName(this.Name);
                        if this.Parent.hasDictionaryConnection
                            numVarIDs=length(enumVarID);
                            if numVarIDs>1
                                [~,ddName,~]=fileparts(this.Parent.NodeConnection.filespec);
                                ddName=[ddName,'.sldd'];
                                for j=1:numVarIDs
                                    if strcmp(enumVarID(j).getDataSourceFriendlyName,ddName)
                                        enumVarID=enumVarID(j);
                                        break;
                                    end
                                end
                            end
                        end
                        enumVar=this.Parent.NodeDataAccessor.getVariable(enumVarID);


                        if~isequal(this.SourceObject,enumVar)
                            dlg=this.getDASDialogHandle;
                            assert(~isempty(dlg)&&ishandle(dlg));
                            this.saveEnumEntry(dlg);
                            ed=this.getEditor;
                            if ed.hasTreeComp()
                                ed.getTreeComp.update(this.Parent);
                            end
                            ed.update;
                        end
                        dlgStruct=this.EnumDDGSource.getDialogSchema;
                    else
                        dlgStruct=Simulink.dd.enumtypeddg(this,this.SourceObject,this.Name);
                        dlgStruct.DisableDialog=true;
                    end









                    if isfield(dlgStruct,'CloseMethod')
                        dlgStruct=rmfield(dlgStruct,'CloseMethod');
                        dlgStruct=rmfield(dlgStruct,'CloseMethodArgs');
                        dlgStruct=rmfield(dlgStruct,'CloseMethodArgsDT');
                    end

                    dlgStruct.Items{1}.Type='panel';
                    if this.Parent.hasDictionaryConnection
                        dlgStruct.Items{1}.Items=dlgStruct.Items{1}.Items{1}.Tabs;
                    else
                        dlgStruct.Items{1}.Items=dlgStruct.Items{1}.Tabs;
                    end
                    dlgStruct.Items{1}.Items{1}.Type='togglepanel';
                    dlgStruct.Items{1}.Items{1}.Expand=true;
                    dlgStruct.Items{1}.Items{2}.Type='togglepanel';
                    dlgStruct.Items{1}.Items{2}.Expand=false;

                    if length(dlgStruct.Items)==2
                        nestedItems=dlgStruct.Items(2);
                        dlgStruct.Items{2}.Type='panel';
                        dlgStruct.Items{2}.Items=nestedItems;
                        dlgStruct.Items{2}=rmfield(dlgStruct.Items{2},'LayoutGrid');
                        dlgStruct.Items{2}=rmfield(dlgStruct.Items{2},'RowSpan');
                        dlgStruct.Items{2}=rmfield(dlgStruct.Items{2},'ColSpan');
                    end

                    outerPanel.Type='panel';
                    outerPanel.Items=dlgStruct.Items;
                    if isfield(dlgStruct,'LayoutGrid')
                        outerPanel.LayoutGrid=dlgStruct.LayoutGrid;
                        dlgStruct=rmfield(dlgStruct,'LayoutGrid');
                    end

                    if isfield(dlgStruct,'RowStretch')
                        outerPanel.RowStretch=dlgStruct.RowStretch;
                        dlgStruct=rmfield(dlgStruct,'RowStretch');
                    end

                    if isfield(dlgStruct,'ColStretch')
                        outerPanel.ColStretch=dlgStruct.ColStretch;
                        dlgStruct=rmfield(dlgStruct,'ColStretch');
                    end

                    dlgStruct.Items={outerPanel};
                    if~this.Parent.hasDictionaryConnection
                        dlgStruct=this.setDisabled(dlgStruct);
                    end
                else













                    if isa(this.SourceObject,'Simulink.AliasType')
                        if this.Parent.hasDictionaryConnection
                            slprivate('slUpdateDataTypeListSource','set',this.Parent.NodeConnection);
                        end
                        dlgStruct=aliastypeddg(this.SourceObject,this.Name,this);
                        if this.Parent.hasDictionaryConnection
                            slprivate('slUpdateDataTypeListSource','clear');
                        end
                    elseif isa(this.SourceObject,'Simulink.NumericType')
                        dlgStruct=numerictypeddg(this.SourceObject,this.Name,this);
                    else
                        assert(isa(this.SourceObject,'Simulink.ValueType'));
                        if this.Parent.hasDictionaryConnection
                            slprivate('slUpdateDataTypeListSource','set',this.Parent.NodeConnection);
                        end
                        dlgStruct=this.SourceObject.valueTypeGetDialogSchema(this.Name,this);
                        if this.Parent.hasDictionaryConnection
                            slprivate('slUpdateDataTypeListSource','clear');
                        end
                    end
                end
                dlgStruct=this.setImmediate(dlgStruct);
                dlgStruct.DialogTitle='';
            end
            spacer=struct('Type','text','Name','');

            dlgStruct.Source=this;
            dlgStruct.Items=[dlgStruct.Items,spacer];
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.DialogMode='Slim';
            dlgStruct.DialogTag=this.DialogTag;

            if this.isInMultiselect||this.IsDerived
                dlgStruct=this.setDisabled(dlgStruct);
            end
        end


        function userData=getUserData(this)
            userData=[];
            if this.IsEnum&&this.Parent.hasDictionaryConnection
                userData=this.EnumDDGSource.getUserData;
            end
        end

        function setUserData(this,userData)
            if this.IsEnum&&this.Parent.hasDictionaryConnection
                this.EnumDDGSource.setUserData(userData);
            end
        end

        function obj=getForwardedObject(this)
            obj=this;
            if this.IsEnum&&this.Parent.hasDictionaryConnection
                obj=this.EnumDDGSource.getForwardedObject;
            end
        end

        function isValid=isValidSourceForEnum(this)
            if this.Parent.hasDictionaryConnection
                isValid=false;
            else
                isValid=true;
            end
        end




        function data=getAutoCompleteData(~,~,partialText)
            data=Simulink.UnitPrmWidget.getUnitSuggestions(partialText,[],false);
        end

        function propValue=getPropValue(this,propName)
            if strcmp(propName,this.NameColHeader)
                propValue=this.Name;
            else
                if this.IsBus
                    propValue=this.SourceObject.getPropValues(propName);
                else
                    if strcmp(propName,'Type')
                        propName=this.getPropNameForType;
                    end
                    if this.IsEnum&&this.Parent.hasDictionaryConnection
                        propValue=this.EnumDDGSource.getPropValue(propName);
                    else
                        propValue=this.SourceObject.getPropValue(propName);
                    end
                end
            end
        end

        function items=getContextMenuItems(this)
            template=struct('label','','tag','','checkable',false,'checked',false,'command','',...
            'accel','','enabled',true,'icon','','visible',true);

            sepItem=template;
            sepItem.tag='sepTag';
            sepItem.label='separator';




            ed=this.getEditor;
            typeChain=ed.getStudioWindow.getContextObject.TypeChain;
            commandStrProvider=ed.getCommandStrProvider();

            clear items;
            rowIdx=1;
            notDDOrEnum=~this.getRoot.hasDictionaryConnection&&~this.IsEnum;

            exportItemSub1=template;
            exportItemSub1.label=DAStudio.message('Simulink:busEditor:ExportMAT');
            exportItemSub1.command='Simulink.typeeditor.actions.exportFromEditor(''MAT'', [], false)';
            exportItemSub1.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('matFile_16.png');
            exportItemSub1.enabled=notDDOrEnum;
            exportItemSub1.tag='exportMAT';
            subItems=exportItemSub1;

            exportItemSub2=template;
            exportItemSub2.label=DAStudio.message('Simulink:busEditor:ExportMCell');
            exportItemSub2.command='Simulink.typeeditor.actions.exportFromEditor(''Cell'', [], false)';
            exportItemSub2.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('mFile_16.png');
            exportItemSub2.enabled=notDDOrEnum&&~this.IsConnectionType&&this.IsBus;
            exportItemSub2.tag='exportMCell';
            subItems(end+1)=exportItemSub2;

            exportItemSub3=template;
            exportItemSub3.label=DAStudio.message('Simulink:busEditor:ExportMObject');
            exportItemSub3.command='Simulink.typeeditor.actions.exportFromEditor(''Object'', [], false)';
            exportItemSub3.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('mFile_16.png');
            exportItemSub3.enabled=notDDOrEnum;
            exportItemSub3.tag='exportMObj';
            subItems(end+1)=exportItemSub3;

            exportItem=template;
            exportItem.label=DAStudio.message('Simulink:busEditor:ExportContext');
            if notDDOrEnum
                exportItem.command=subItems;
                exportItem.enabled=true;
            else
                exportItem.enabled=false;
            end
            items(rowIdx)=exportItem;
            rowIdx=rowIdx+1;

            exportDepItem=template;
            if slfeature('TypeEditorStudio')>0
                exportDepItem.label=DAStudio.message('Simulink:busEditor:ExportWithDependentTypesContext');
            else
                exportDepItem.label=DAStudio.message('Simulink:busEditor:ExportWithDependentsContext');
            end
            if notDDOrEnum
                exportDepItem.command=subItems;
                exportDepItem.command(1).tag=[exportDepItem.command(1).tag,'_Dep'];
                exportDepItem.command(2).tag=[exportDepItem.command(2).tag,'_Dep'];
                exportDepItem.command(3).tag=[exportDepItem.command(3).tag,'_Dep'];
                exportDepItem.command(1).command='Simulink.typeeditor.actions.exportFromEditor(''MAT'', [], true)';
                exportDepItem.command(2).command='Simulink.typeeditor.actions.exportFromEditor(''Cell'', [], true)';
                exportDepItem.command(3).command='Simulink.typeeditor.actions.exportFromEditor(''Object'', [], true)';
                exportDepItem.enabled=true;
            else
                exportDepItem.enabled=false;
            end
            items(rowIdx)=exportDepItem;
            rowIdx=rowIdx+1;

            items(rowIdx)=sepItem;
            rowIdx=rowIdx+1;

            if~(this.IsBus||this.IsEnum)&&(length(ed.getCurrentListNode)==1)
                gotoTypeWithPrefix=split(this.getPropValue('Type'),':');
                gotoType=strtrim(gotoTypeWithPrefix{end});
                resolvesToType=this.doesVariableExistInWorkspace(gotoType);
                if resolvesToType
                    items(rowIdx)=sepItem;
                    rowIdx=rowIdx+1;

                    gotoItem=template;

                    gotoItem.label=[DAStudio.message('Simulink:busEditor:GotoTextNew'),' ''',gotoType,''''];
                    gotoItem.command=['Simulink.typeeditor.actions.goto(''',gotoType,''')'];
                    gotoItem.accel='Ctrl+K';
                    gotoItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('goto.png');
                    gotoItem.tag='gotoAction';
                    items(rowIdx)=gotoItem;
                    rowIdx=rowIdx+1;

                    items(rowIdx)=sepItem;
                    rowIdx=rowIdx+1;
                end
            end

            isRegularBus=~this.IsConnectionType&&this.IsBus;

            slParamItem=template;
            slParamItem.label=DAStudio.message('Simulink:busEditor:CreateSimulinkParameterContext');
            slParamItem.command='Simulink.typeeditor.actions.createObjects(''Parameter'')';
            slParamItem.accel='Ctrl+P';
            slParamItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('simulink_parameter_16.png');
            slParamItem.enabled=isRegularBus;
            slParamItem.tag='slParamAction';
            items(rowIdx)=slParamItem;
            rowIdx=rowIdx+1;

            mlStructItem=template;
            mlStructItem.label=DAStudio.message('Simulink:busEditor:CreateMATLABStructContext');
            mlStructItem.command='Simulink.typeeditor.actions.createObjects(''Struct'')';
            mlStructItem.accel='Ctrl+M';
            mlStructItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('matlab_struct_16.png');
            mlStructItem.enabled=isRegularBus;
            mlStructItem.tag='mlStructAction';
            items(rowIdx)=mlStructItem;
            rowIdx=rowIdx+1;

            items(rowIdx)=sepItem;
            rowIdx=rowIdx+1;

            cutItem=template;
            cutItem.tag='cutAction';
            cutItem.label=DAStudio.message('Simulink:busEditor:Cut');
            cutItem.command=commandStrProvider.getCommandStr('cut');
            cutItem.accel='Ctrl+X';
            cutItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('cut_action_16.png');
            cutItem.enabled=any(strcmp('cutActionEnable',typeChain));
            items(rowIdx)=cutItem;
            rowIdx=rowIdx+1;

            copyItem=template;
            copyItem.tag='copyAction';
            copyItem.label=DAStudio.message('Simulink:busEditor:Copy');
            copyItem.command=commandStrProvider.getCommandStr('copy');
            copyItem.accel='Ctrl+C';
            copyItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('copy_action_16.png');
            copyItem.enabled=any(strcmp('copyActionEnable',typeChain));
            items(rowIdx)=copyItem;
            rowIdx=rowIdx+1;

            pasteItem=template;
            pasteItem.tag='pasteAction';
            pasteItem.label=DAStudio.message('Simulink:busEditor:Paste');
            pasteItem.command=commandStrProvider.getCommandStr('paste');
            pasteItem.accel='Ctrl+V';
            pasteItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('paste_action_16.png');
            ed=this.getEditor;
            assert(ed.isVisible);
            pasteItem.enabled=any(strcmp('pasteActionEnable',typeChain))&&~isempty(ed.getClipboard.contents);
            items(rowIdx)=pasteItem;
            rowIdx=rowIdx+1;

            items(rowIdx)=sepItem;
            rowIdx=rowIdx+1;

            deleteItem=template;
            deleteItem.tag='deleteAction';
            deleteItem.label=DAStudio.message('Simulink:busEditor:Delete');
            deleteItem.command=commandStrProvider.getCommandStr('deleteEntry');
            deleteItem.accel='DEL';
            deleteItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('delete_action_16.png');
            deleteItem.enabled=any(strcmp('deleteActionEnable',typeChain));
            items(rowIdx)=deleteItem;
        end

        function propValues=getPropAllowedValues(this,propName)

            updateDTListSource=false;
            if~this.IsBus&&(strcmp(propName,'Type'))
                propName=this.getPropNameForType;
                if isa(this.SourceObject,'Simulink.AliasType')||...
                    isa(this.SourceObject,'Simulink.ValueType')
                    updateDTListSource=true;
                end
            end

            if updateDTListSource
                if this.Parent.hasDictionaryConnection
                    slprivate('slUpdateDataTypeListSource','set',this.Parent.NodeConnection);
                end
            end

            if this.IsEnum&&this.Parent.hasDictionaryConnection
                propValues=this.EnumDDGSource.getPropAllowedValues(propName);
            else
                if isa(this.SourceObject,'Simulink.AliasType')
                    propValues=this.SourceObject.getPropAllowedValues(propName,this.Name);
                else
                    propValues=this.SourceObject.getPropAllowedValues(propName);
                end
            end

            if updateDTListSource
                if this.Parent.hasDictionaryConnection
                    slprivate('slUpdateDataTypeListSource','clear');
                end
            end
        end

        function propDT=getPropDataType(this,propName)


            if strcmp(propName,this.PreserveElementDimensionsColHeader)
                propDT='bool';
            else

                if this.IsBus
                    propDT=this.SourceObject.getPropDataTypes(propName);
                else
                    if this.IsEnum&&this.Parent.hasDictionaryConnection
                        propDT=this.EnumDDGSource.getPropDataType(propName);
                        return;
                    elseif strcmp(propName,'Type')
                        propName=this.getPropNameForType;
                    end
                    propDT=this.SourceObject.getPropDataType(propName);
                end
            end
        end

        function isValid=isValidProperty(this,propName)
            if this.IsBus
                if this.IsConnectionType
                    isValid=any(strcmp({this.NameColHeader,...
                    this.DescriptionColHeader},propName));
                else
                    isValid=any(strcmp({this.NameColHeader,...
                    this.DataScopeColHeader,...
                    this.HeaderFileColHeader,...
                    this.AlignmentColHeader,...
                    this.PreserveElementDimensionsColHeader,...
                    this.DescriptionColHeader},propName));
                end
            else
                isValid=strcmp(propName,this.NameColHeader)||...
                (~this.IsEnum&&strcmp(propName,DAStudio.message('Simulink:busEditor:PropType')))||...
                (this.IsEnum&&this.Parent.hasDictionaryConnection&&this.EnumDDGSource.isValidProperty(propName))||...
                this.SourceObject.isValidProperty(propName);
            end
        end

        function isEditable=isEditableProperty(this,propName)
            if this.IsBus
                if this.IsConnectionType
                    isEditable=any(strcmp({this.NameColHeader,...
                    this.DescriptionColHeader},propName));
                else
                    isEditable=any(strcmp({this.NameColHeader,...
                    this.DataScopeColHeader,...
                    this.HeaderFileColHeader,...
                    this.AlignmentColHeader,...
                    this.PreserveElementDimensionsColHeader,...
                    this.DescriptionColHeader},propName));
                end
            else
                if this.IsEnum&&this.Parent.hasDictionaryConnection
                    isEditable=this.isValidProperty(propName);
                else
                    isEditable=strcmp(propName,DAStudio.message('Simulink:busEditor:PropType'))||...
                    this.SourceObject.isEditableProperty(propName);
                end
            end
        end

        function isRO=isReadonlyProperty(this,propName)
            if this.IsBus
                if this.IsConnectionType
                    isRO=~any(strcmp({this.NameColHeader,...
                    this.DescriptionColHeader},propName));
                else
                    isRO=~any(strcmp({this.NameColHeader,...
                    this.DataScopeColHeader,...
                    this.HeaderFileColHeader,...
                    this.AlignmentColHeader,...
                    this.PreserveElementDimensionsColHeader,...
                    this.DescriptionColHeader},propName));
                end
            else
                if this.IsEnum&&...
                    ~this.Parent.hasDictionaryConnection
                    isRO=true;
                else
                    isRO=this.SourceObject.isReadonlyProperty(propName);
                end
            end
        end

        function ch=getChildren(this,~)
            if this.IsBus
                ed=this.getEditor();
                lc=ed.getListComp;
                firstExpand=false;
                if this.NeverExpanded
                    if lc.imSpreadSheetComponent.isExpanded(this)
                        firstExpand=true;
                        this.NeverExpanded=false;
                    end
                end

                if~isempty(this.Children)&&~this.ChildrenLoadedBeforeQuery
                    if firstExpand&&this.FlaggedBySource
                        isChildBus=[this.Children.IsBus];
                        childBuses=this.Children(isChildBus);
                        if this.IsConnectionType
                            propName='Type';
                            resetValue='Connection: <domain name>';
                            warnID='Simulink:busEditor:ChangedCyclicDependencyMsgForConnection';
                            warnTitle=DAStudio.message('Simulink:busEditor:ChangedCyclicDependencyTitleForConnection');
                        else
                            propName='DataType';
                            resetValue='double';
                            warnID='Simulink:busEditor:ChangedCyclicDependencyMsg';
                            warnTitle=DAStudio.message('Simulink:busEditor:ChangedCyclicDependencyTitle');
                        end
                        for i=1:length(childBuses)
                            currType=Simulink.typeeditor.utils.stripBusPrefix(childBuses(i).SourceObject.Type);
                            if any(strcmp(this.Name,this.Parent.InvalidTypeCache(currType)))
                                childBuses(i).setPropValue(propName,resetValue);
                                warnStr=DAStudio.message(warnID,childBuses(i).Name,['Bus: ',currType],this.Name);
                                if slfeature('TypeEditorStudio')>0
                                    childBuses(i).reportErrorFromContext(warnID,warnStr,DAStudio.message('Simulink:busEditor:PropType'),'Warning');
                                else
                                    warndlg(warnStr,warnTitle);
                                end
                            end
                        end
                        this.FlaggedBySource=false;
                    end
                    ch=this.Children;
                    return;
                else
                    ch=[];
                    if this.LoadImmediateChildren
                        elements=this.SourceObject.Elements;
                        ch=Simulink.typeeditor.app.Element.empty(0,length(elements));
                        nestedBuses=Simulink.typeeditor.app.Element.empty;
                        for i=1:length(elements)
                            ch(i)=Simulink.typeeditor.app.Element(elements(i),this,false);
                            if ch(i).IsBus
                                nestedBuses(end+1)=ch(i);%#ok<AGROW>
                            end
                        end
                        this.Children=ch;

                        if~isempty(this.BusesRenamed)
                            for i=1:length(nestedBuses)
                                typeName=Simulink.typeeditor.utils.stripBusPrefix(nestedBuses(i).SourceObject.Type);
                                if this.BusesRenamed.isKey(typeName)
                                    nestedBuses(i).setPropValue('Type',['Bus: ',this.BusesRenamed(typeName)]);
                                end
                            end
                            this.BusesRenamed.remove(this.BusesRenamed.keys);
                        end
                    end
                end
            else
                ch=[];
            end
        end

        function ch=getHierarchicalChildren(this)
            ch=this.getChildren;
        end

        function tf=isHierarchical(this)
            tf=this.IsBus;
        end

        function res=find(this,childName)
            resIdx=this.findIdx(childName);
            if isempty(resIdx)
                res=Simulink.typeeditor.app.Element.empty;
            else
                res=this.Children(resIdx);
            end
        end

        function resIdx=findIdx(this,childName)
            if~isempty(this.Children)
                srcObjs=[this.Children.SourceObject];
                resIdx=find(strcmp(childName,{srcObjs.Name}));
            else
                resIdx=[];
            end
        end

        function setPropValue(this,propName,propValue)

            if isequal(this.getPropValue(propName),propValue)
                return;
            end
            try
                if~this.IsBus&&strcmp(propName,'Type')
                    propName=this.getPropNameForType;
                end
                root=this.getRoot;
                ed=this.getEditor;
                lc=ed.getListComp;
                errorID='';
                errorStr='';

                oldVariableID=root.NodeDataAccessor.identifyByName(this.Name);
                if root.hasDictionaryConnection
                    numVarIDs=length(oldVariableID);
                    if numVarIDs>1
                        [~,ddName,~]=fileparts(root.NodeConnection.filespec);
                        ddName=[ddName,'.sldd'];
                        for j=1:numVarIDs
                            if strcmp(oldVariableID(j).getDataSourceFriendlyName,ddName)
                                oldVariableID=oldVariableID(j);
                                break;
                            end
                        end
                    end
                end
                oldVariable=root.NodeDataAccessor.getVariable(oldVariableID);

                if strcmp(propName,this.NameColHeader)
                    builtIns=[Simulink.DataTypePrmWidget.getBuiltinList('NumBool');'auto'];
                    if~isvarname(propValue)
                        errorID='Simulink:busEditor:InvalidMatlabVariableName';
                        errorStr=DAStudio.message(errorID,propValue);
                    elseif root.NodeDataAccessor.hasVariable(propValue)
                        errorID='Simulink:busEditor:VariableAlreadyExistsByName';
                        errorStr=DAStudio.message(errorID,propValue,root.getNodeName(true));
                    elseif~isempty(find(strcmp(propValue,builtIns)==1,1))
                        errorID='Simulink:DataType:BuiltinDataTypeNameNotAllowed';
                        errorStr=DAStudio.message(errorID,propValue);
                    elseif this.IsBus
                        depTypes=unique([this.getDependentTypes,this.getLeafElementsWithBusSpec]);
                        if(this.Parent.InvalidTypeCache.isKey(propValue)&&...
                            ~isempty(intersect(this.Parent.InvalidTypeCache(propValue),depTypes)))||...
                            any(strcmp(propValue,unique([depTypes,this.getLeafElementsWithBusSpec])))
                            errorID='Simulink:busEditor:BusObjectRenameCyclicDependency';
                            errorStr=DAStudio.message(errorID,this.Name,propValue);
                        end
                    end
                    if~isempty(errorStr)
                        if slfeature('TypeEditorStudio')>0
                            this.reportErrorFromContext(errorID,errorStr,propName,'Error');
                        else
                            this.reportPIError(errorID,errorStr,propName,'Error');
                        end
                        return;
                    end

                    shouldSetDataSource=false;
                    if root.hasDictionaryConnection
                        dataSourceDDName=root.getObjectDataSource(this.Name);
                        [~,rootConnName,~]=fileparts(root.NodeConnection.filespec);
                        shouldSetDataSource=~strcmp(rootConnName,dataSourceDDName);
                    end

                    if this.IsEnum
                        root.NodeDataAccessor.createVariableAsLocalData(propValue,this.SourceObject);
                        delete(this.EnumDDGSource);
                        this.EnumDDGSource=Simulink.dd.EntryDDGSource(root.NodeConnection,['Design_Data.',propValue],true);
                        this.SourceObject=this.EnumDDGSource.getForwardedObject;
                    else
                        root.NodeDataAccessor.createVariableAsLocalData(propValue,oldVariable);
                    end

                    if shouldSetDataSource
                        root.NodeConnection.setEntryDataSource(['Design_Data.',propValue],[dataSourceDDName,'.sldd']);
                    end

                    if slfeature('TypeEditorStudio')>0
                        this.reportErrorFromContext;
                    else
                        this.reportPIError(propName);
                    end

                    root.NodeDataAccessor.deleteVariable(oldVariableID);
                    root.Children.remove(this.Name);
                    parentIdxInCache=strcmp(this.Name,root.WorkspaceCache(:,1));
                    oldVal=this.Name;
                    this.Name=propValue;
                    root.Children(this.Name)=this;
                    root.WorkspaceCache{parentIdxInCache,1}=propValue;
                    root.WorkspaceCache{parentIdxInCache,2}=this.SourceObject;
                    this.Path=propValue;


                    if this.IsBus

                        if~root.InvalidTypeCache.isKey(this.Name)
                            root.InvalidTypeCache(this.Name)={this.Name};
                        else
                            root.InvalidTypeCache(this.Name)=unique([root.InvalidTypeCache(this.Name),this.Name]);
                        end


                        depTypes=unique([this.getDependentTypes,this.getLeafElementsWithBusSpec]);
                        for i=1:length(depTypes)
                            values_i=root.InvalidTypeCache(depTypes{i});
                            values_i(strcmp(values_i,oldVal))={this.Name};
                            root.InvalidTypeCache(depTypes{i})=values_i;
                        end

                        eventType='BusObjectRenamed';



                        eventData=Simulink.typeeditor.app.EventData(eventType,BusName=oldVal,ElemName=propValue,IsConnType=this.IsConnectionType);
                        root.notify(eventType,eventData);
                    end


                    if ed.hasTreeComp
                        ed.getTreeComp().setSource(ed.getSource);
                    end
                    filterText=lc.imSpreadSheetComponent.getFilterText;
                    if~isempty(filterText)
                        lc.update(this);
                    else
                        lc.update;
                    end
                    ed.update;
                    dlg=this.getDASDialogHandle;
                    if~isempty(dlg)&&ishandle(dlg)
                        dlg.refresh;
                    end
                    root.notifySLDDChanged;
                    root.refreshDataSourceChildren(this.Name);


                    if~strcmp(oldVal,propValue)&&this.IsBus
                        try %#ok<TRYNC>
                            Simulink.ModelManagement.Project.Buses.displayRename(oldVal,propValue);
                        end
                    end
                    return;
                else
                    if slfeature('SLDataDictionarySetUserData')>0&&~isempty(this.SourceObject.TargetUserData)
                        tokens=split(propName,'.');
                        if numel(tokens)>1&&strcmp(tokens{1},'TargetUserData')
                            val=propValue;
                            switch getPropDataType(this.SourceObject,propName)
                            case 'enum'
                            case{'string','asciiString'}
                                val=strrep(val,'''','''''');
                            otherwise
                                try
                                    propVal=this.SourceObject.(propName);
                                catch E %#ok

                                    propVal=eval(['this.SourceObject.',propName]);%#ok<EVLDOT>
                                end
                                if ischar(propVal)
                                    val=DAStudio.MxStringConversion.convertToString(propValue);
                                    val=strrep(val,'''','''''');
                                end
                            end
                            oldVariable.setPropValue(propName,val);
                        else
                            val=this.formatValues(propName,propValue);
                            if isempty(val)
                                return;
                            end
                        end
                    else







                        if isa(this.SourceObject,'Simulink.ValueType')&&...
                            strcmp(propName,DAStudio.message('Simulink:busEditor:PropDataType'))&&...
                            strcmp(propValue,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))
                            slprivate('slGetUserDataTypesFromWSDD',this,[],[],true);
                            propValue=oldVariable.(propName);
                        end
                        val=this.formatValues(propName,propValue);
                        if isempty(val)
                            return;
                        end
                    end



                    if strcmp(propName,'DataSource')
                        root.refreshDataSourceChildren(this.Name);
                    end


                    if this.IsEnum
                        this.setEnumPropValue(propName,propValue);
                        this.saveEnumEntry(this.getDASDialogHandle);
                        if strcmp(propName,'DataSource')






                            root.NodeConnection.setEntryDataSource(['Design_Data.',this.Name],propValue);
                        end
                    else
                        oldVariable.(propName)=eval(val);
                        root.NodeDataAccessor.updateVariable(oldVariableID,oldVariable);
                        this.SourceObject=oldVariable;
                    end


                    parentIdxInCache=strcmp(this.Name,root.WorkspaceCache(:,1));
                    root.WorkspaceCache{parentIdxInCache,2}=this.SourceObject;

                    if slfeature('TypeEditorStudio')>0
                        this.reportErrorFromContext;
                    else
                        this.reportPIError(propName);
                    end
                    lc.update(this);
                end
                if ed.hasTreeComp
                    ed.getTreeComp().update(true);
                end
                root.notifySLDDChanged;
                root.refreshDataSourceChildren(this.Name);
                ed.update;
                dlg=this.getDASDialogHandle;
                dlg.refresh;

                ed.clearRowHighlights;
                this.highlightReferencedTypes;
            catch ME
                if slfeature('TypeEditorStudio')>0
                    if isa(this.SourceObject,'Simulink.ValueType')
                        if strcmp(propName,DAStudio.message('Simulink:busEditor:PropMin'))
                            propName='Minimum';
                        elseif strcmp(propName,DAStudio.message('Simulink:busEditor:PropMax'))
                            propName='Maximum';
                        end
                    end
                    this.reportErrorFromContext(ME.identifier,ME.message,propName,'Error');
                else
                    this.reportPIError(ME.identifier,ME.message,propName,'Error');
                end
            end
        end

        function addChild(this,childName,loadImmediateChildren,childrenLoadedBeforeQuery)
            ed=this.getEditor;
            if ed.isVisible
                if this.IsConnectionType
                    isConnectionElement=true;
                    elementType=ed.AdditionalElement;
                else
                    isConnectionElement=false;
                    elementType=ed.DefaultElement;
                end
                root=this.getRoot;
                nodeIdxInParent=0;
                busID=root.NodeDataAccessor.identifyByName(this.Name);
                if root.hasDictionaryConnection
                    numVarIDs=length(busID);
                    if numVarIDs>1
                        [~,ddName,~]=fileparts(root.NodeConnection.filespec);
                        ddName=[ddName,'.sldd'];
                        for j=1:numVarIDs
                            if strcmp(busID(j).getDataSourceFriendlyName,ddName)
                                busID=busID(j);
                                break;
                            end
                        end
                    end
                end
                if isempty(this.Children)
                    evaledElem=eval(elementType);
                    tempObject=root.NodeDataAccessor.getVariable(busID);
                    tempObject.Elements=evaledElem;
                    root.NodeDataAccessor.updateVariable(busID,tempObject);
                    newChildren=Simulink.typeeditor.app.Element(evaledElem,this,false);
                else
                    curListNode=ed.getCurrentListNode;
                    if(numel(curListNode)==1)&&isa(curListNode{1},'Simulink.typeeditor.app.Element')
                        nodeIdxInParent=this.findIdx(curListNode{1}.SourceObject.Name);
                    end
                    tempElemNodesPrev=this.Children(1:nodeIdxInParent);
                    newElem=eval(elementType);
                    newElem.Name=childName;
                    tempElemNodeNew=Simulink.typeeditor.app.Element(newElem,this,false);
                    tempElemNodesNext=this.Children(nodeIdxInParent+1:end);
                    newChildren=[tempElemNodesPrev,tempElemNodeNew,tempElemNodesNext];

                    tempObject=this.SourceObject;
                    tempObject.Elements=[newChildren.SourceObject];
                    root.NodeDataAccessor.updateVariable(busID,tempObject);
                end
                parentIdxInCache=strcmp(this.Name,root.WorkspaceCache(:,1));
                root.WorkspaceCache{parentIdxInCache,2}=tempObject;
                this.Children=newChildren;
                this.SourceObject=tempObject;
                eventType='BusElementAdded';
                eventData=Simulink.typeeditor.app.EventData(eventType,BusName=this.Name,ElemName=newChildren(nodeIdxInParent+1).SourceObject.Name,...
                ElemIdx=nodeIdxInParent,IsConnType=isConnectionElement,ElemObj=newChildren(nodeIdxInParent+1).SourceObject);
                root.notify(eventType,eventData);
                this.LoadImmediateChildren=loadImmediateChildren;
                this.ChildrenLoadedBeforeQuery=childrenLoadedBeforeQuery;
                ed.getListComp.update(true);
            end
        end

        function depTypes=getDependentTypes(this)
            assert(this.IsBus,'Non-hierarchical node');
            if this.Parent.IsDictionary
                if this.IsConnectionType
                    clsName=Simulink.typeeditor.app.Editor.AdditionalBaseType;
                else
                    clsName=Simulink.typeeditor.app.Editor.DefaultBaseType;
                end
                depTypes=eval([clsName,'.getDependentTypesWrtSLDD(this.Name, this.Parent.NodeConnection.filespec, true)']);
            else
                depTypes=this.SourceObject.getDependentTypesWrtBaseWS(true);
            end
        end

        function depTypes=getLeafElementsWithBusSpec(this)
            prefix='Bus: ';
            if this.IsConnectionType
                leafElems=this.SourceObject.getLeafConnectionElements;
            else
                leafElems=this.SourceObject.getLeafBusElements;
            end
            if isempty(leafElems)
                depTypes=[];
            else
                leafElemsTypes={leafElems.Type};
                leafElemsBusTypes=unique(leafElemsTypes(contains(leafElemsTypes,prefix)));
                depTypes=cell(1,length(leafElemsBusTypes));
                for i=1:length(leafElemsBusTypes)
                    depTypes{i}=leafElemsBusTypes{i}(length(prefix)+1:end);
                end
            end
        end
    end


    methods(Hidden)

        function out=getPropertySchema(this)
            out=this;
        end

        function s=getObjectName(this)
            s=this.Name;
        end

        function objType=getObjectType(this)
            if this.IsEnum
                objType=DAStudio.message('Simulink:busEditor:SLDDEnumTypeDialogTitle');
            else
                objType=class(this.SourceObject);
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

        function showPropertyHelp(this,prop)
            if isempty(prop)
                if this.IsBus
                    if this.IsConnectionType
                        helpKey='simulink_connection_bus';
                    else
                        helpKey='simulink_bus';
                    end
                else
                    if isa(this.SourceObject,'Simulink.AliasType')
                        helpKey='simulink_alias_type';
                    elseif isa(this.SourceObject,'Simulink.NumericType')
                        helpKey='simulink_numeric_type';
                    elseif isa(this.SourceObject,'Simulink.ValueType')
                        helpKey='simulink_valuetype';
                    else
                        assert(isa(this.IsEnum));
                        helpKey='sldd_enumtypedefinition';
                    end
                end
                helpview(fullfile(docroot,'mapfiles','simulink.map'),helpKey);
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'Simulink:Model:Properties')
                label=getString(message('Slvnv:slreq:Details'));
            end
        end
    end

    methods(Access=private,Hidden)
        function val=formatValues(this,propName,propValue)
            val=this.addQuoteIfNonNumericString(propValue,propName);
            if strcmpi(propName,this.AlignmentColHeader)
                alignVal=int32(str2double(propValue));
                if(alignVal==-1)||((alignVal>0)&&(alignVal<=128)&&(bitand(alignVal,alignVal-1)==0))
                    val=propValue;
                else
                    errorID='Simulink:Data:RTWInfo_InvalidAlignment';
                    errorStr=DAStudio.message(errorID,alignVal);
                    if slfeature('TypeEditorStudio')>0
                        this.reportErrorFromContext(errorID,errorStr,propName,'Error');
                    else
                        this.reportPIError(errorID,errorStr,propName,'Error');
                    end
                    return;
                end
            end
        end

        function propNameType=getPropNameForType(this)
            propNameType='';
            if isa(this.SourceObject,'Simulink.AliasType')
                propNameType=this.BaseTypeColHeader;
            elseif isa(this.SourceObject,'Simulink.NumericType')
                propNameType=this.DataTypeModeColHeader;
            elseif isa(this.SourceObject,'Simulink.ValueType')
                propNameType=DAStudio.message('Simulink:busEditor:PropDataType');
            end
        end
    end
end





