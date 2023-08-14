classdef Element<Simulink.typeeditor.app.Node




    properties(Hidden)
        IsConnectionType logical=false
        IsBus logical=false
DataTypeForDTA


UDTAssistOpen
UDTIPOpen

MimeData
LoadImmediateChildren
        ReadOnlyElement logical=false






        InRenameForBus=false

        DummyMimeData=GLEE.ByteArrayPair(GLEE.ByteArray('foo'),GLEE.ByteArray('bar'))





        NotifyListener=true
    end

    properties(NonCopyable,Hidden)
        BusElemListener event.listener
    end

    properties(Access=private,Constant,Hidden)

        NameColHeader=DAStudio.message('Simulink:busEditor:PropElementName')
        DataTypeColHeader=DAStudio.message('Simulink:busEditor:PropDataType')
        ComplexityColHeader=DAStudio.message('Simulink:busEditor:PropComplexity')
        DimensionsColHeader=DAStudio.message('Simulink:busEditor:PropDimensions')
        DimensionsModeColHeader=DAStudio.message('Simulink:busEditor:PropDimensionsMode')
        SampleTimeColHeader=DAStudio.message('Simulink:busEditor:PropSampleTime')
        SamplingModeColHeader=DAStudio.message('Simulink:busEditor:PropSamplingMode')
        MinColHeader=DAStudio.message('Simulink:busEditor:PropMin')
        MaxColHeader=DAStudio.message('Simulink:busEditor:PropMax')
        UnitColHeader=DAStudio.message('Simulink:busEditor:PropUnits')
        TypeColHeader=DAStudio.message('Simulink:busEditor:PropType')
        DescriptionColHeader=DAStudio.message('Simulink:busEditor:PropDescription')
    end

    properties(Access=private,Hidden)
        CachedDataTypeItems struct
    end

    methods(Static,Hidden)
        function props=getColumnProperties
            if slfeature('TypeEditorStudio')==0
                props={Simulink.typeeditor.app.Element.NameColHeader,...
                Simulink.typeeditor.app.Element.DataTypeColHeader,...
                Simulink.typeeditor.app.Element.TypeColHeader,...
                Simulink.typeeditor.app.Element.ComplexityColHeader,...
                Simulink.typeeditor.app.Element.DimensionsColHeader,...
                Simulink.typeeditor.app.Element.DimensionsModeColHeader,...
                Simulink.typeeditor.app.Element.MinColHeader,...
                Simulink.typeeditor.app.Element.MaxColHeader,...
                Simulink.typeeditor.app.Element.UnitColHeader,...
                Simulink.typeeditor.app.Element.DescriptionColHeader};
            else
                props={Simulink.typeeditor.app.Element.NameColHeader,...
                Simulink.typeeditor.app.Element.TypeColHeader,...
                Simulink.typeeditor.app.Element.ComplexityColHeader,...
                Simulink.typeeditor.app.Element.DimensionsColHeader,...
                Simulink.typeeditor.app.Element.DimensionsModeColHeader,...
                Simulink.typeeditor.app.Element.MinColHeader,...
                Simulink.typeeditor.app.Element.MaxColHeader,...
                Simulink.typeeditor.app.Element.UnitColHeader,...
                Simulink.typeeditor.app.Element.DescriptionColHeader};
            end
        end

        function props=getColumnPropertiesForSS
            if slfeature('TypeEditorStudio')==0
                props={Simulink.typeeditor.app.Element.NameColHeader,...
                Simulink.typeeditor.app.Element.DataTypeColHeader,...
                Simulink.typeeditor.app.Element.TypeColHeader,...
                Simulink.typeeditor.app.Element.ComplexityColHeader,...
                Simulink.typeeditor.app.Element.DimensionsColHeader,...
                Simulink.typeeditor.app.Element.DimensionsModeColHeader,...
                Simulink.typeeditor.app.Element.MinColHeader,...
                Simulink.typeeditor.app.Element.MaxColHeader,...
                Simulink.typeeditor.app.Element.UnitColHeader};
            else
                props={Simulink.typeeditor.app.Element.NameColHeader,...
                Simulink.typeeditor.app.Element.TypeColHeader,...
                Simulink.typeeditor.app.Element.ComplexityColHeader,...
                Simulink.typeeditor.app.Element.DimensionsColHeader,...
                Simulink.typeeditor.app.Element.DimensionsModeColHeader,...
                Simulink.typeeditor.app.Element.MinColHeader,...
                Simulink.typeeditor.app.Element.MaxColHeader,...
                Simulink.typeeditor.app.Element.UnitColHeader};
            end
        end

        function props=getPropertiesForDefaultView
            props={Simulink.typeeditor.app.Element.ComplexityColHeader,...
            Simulink.typeeditor.app.Element.DimensionsColHeader,...
            Simulink.typeeditor.app.Element.DimensionsModeColHeader,...
            Simulink.typeeditor.app.Element.MinColHeader,...
            Simulink.typeeditor.app.Element.MaxColHeader,...
            Simulink.typeeditor.app.Element.UnitColHeader};
        end
    end

    methods(Static)
        function onQuickEdit(~,obj,~)
            obj.LoadImmediateChildren=true;
            ed=Simulink.typeeditor.app.Editor.getInstance;
            ed.getListComp.update(true);
        end
    end

    methods(Access=protected)
        function objCopy=copyElement(obj)

            objCopy=copyElement@matlab.mixin.Copyable(obj);


            objCopy.Children=[];
        end

        function val=getValueForName(this)
            val=this.SourceObject.Name;
        end
    end

    methods(Hidden,Access={?Simulink.typeeditor.app.Editor,...
        ?Simulink.typeeditor.app.Source,...
        ?Simulink.typeeditor.app.Object,...
        ?sl.interface.dictionaryApp.node.typeeditor.ElementAdapter})
        function this=Element(obj,parent,varargin)
            narginchk(2,3);
            if~isempty(obj)
                this.SourceObject=obj;
                this.IsConnectionType=isa(obj,Simulink.typeeditor.app.Editor.AdditionalElement);
                if this.isBusDataType(this.SourceObject.Type)
                    this.IsBus=true;
                end


                if~isempty(parent)
                    this.updateParent(parent);
                end
            end
            if~isempty(varargin)
                this.ReadOnlyElement=varargin{1};
            end
            if~isempty(parent)
                this.ReadOnlyElement=this.ReadOnlyElement||this.Parent.IsDerived;
            end
            this.Children=Simulink.typeeditor.app.Element.empty;
            this.LoadImmediateChildren=false;
            this.DialogTag='BusElementPIDialog';
            if this.IsConnectionType
                dtTag='Type';
            else
                dtTag='DataType';
            end
            templateDTA=struct('tags',{{dtTag}},'status',{{false}});
            this.UDTAssistOpen=templateDTA;
            this.UDTIPOpen=templateDTA;


            kvPairsList=GLEE.ByteArrayList;
            summary=this.DummyMimeData;
            kvPairsList.add(summary);
            this.MimeData=kvPairsList;




        end
    end

    methods(Hidden)
        function updateParent(this,parent)
            if~isempty(parent)
                this.Parent=parent;
                this.Path=[this.Parent.Path,'.',this.Name];
            end
            this.updateListeners;
        end

        function updateListeners(this)
            busEvents={'BusElementChanged','BusElementAdded','BusElementRemoved','BusElementMoved','BusObjectRenamed','BusObjectRemoved'};
            root=this.getRoot;
            if~isempty(this.BusElemListener)
                delete(this.BusElemListener);
                this.BusElemListener=event.listener.empty(0,length(busEvents));
            end
            if this.IsBus
                this.BusElemListener=event.listener.empty(0,length(busEvents));
                this.BusElemListener=cellfun(@(ev)addlistener(root,ev,@this.busElementChangedCB),busEvents);
            end
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
            resIdx=find(strcmp(childName,{this.Children.Name}));
        end

        function delete(this)
            objs=this.Children;
            if~isempty(objs)
                this.Children=Simulink.typeeditor.app.Element.empty;
                delete(objs);
            end
            delete(this.BusElemListener);
            if~isempty(this.mDynamicProps)
                delete(this.mDynamicProps);
            end
        end


        function data=getMimeData(this)
            data=this.MimeData;
        end


        function mimeType=getMimeType(~)
            mimeType='application/buseditor-mimetype';
        end


        function busElementChangedCB(this,~,eventData)
            if this.IsConnectionType~=eventData.mIsConnType
                return;
            end
            if~this.IsBus
                return;
            end
            if~strcmp(['Bus: ',eventData.mBusName],this.getPropValue('Type'))
                return;
            else
                ed=this.getEditor;
                switch(eventData.mOperation)
                case 'BusElementChanged'
                    if~isempty(this.Children)
                        if any(strcmp(eventData.mPropName,{this.DataTypeColHeader,this.TypeColHeader}))
                            if this.isBusDataType(eval(eventData.mPropValue))
                                this.Children(eventData.mElemIdx).IsBus=true;
                            else
                                this.Children(eventData.mElemIdx).IsBus=false;
                            end
                        end

                        eval(['this.Children(eventData.mElemIdx).SourceObject.',eventData.mPropName,' = ',eventData.mPropValue,';']);%#ok<EVLDOT>
                        lc=ed.getListComp;
                        lc.update(this.Children(eventData.mElemIdx));
                    end
                case 'BusElementAdded'
                    if this.LoadImmediateChildren
                        newElemIdx=eventData.mElemIdx;
                        tempElemNodesPrev=this.Children(1:newElemIdx);
                        numElems=length(eventData.mElemObj);
                        for i=1:numElems
                            tempElemNodeNew(i)=Simulink.typeeditor.app.Element(eventData.mElemObj(i),this,true);%#ok<AGROW>
                        end
                        tempElemNodesNext=this.Children(newElemIdx+1:end);
                        this.Children=[tempElemNodesPrev,tempElemNodeNew,tempElemNodesNext];
                    end
                case 'BusElementRemoved'
                    if~isempty(this.Children)
                        elemIdxs=eventData.mElemIdx;
                        elemsToDelete=this.Children(elemIdxs);
                        this.Children(elemIdxs)=[];
                        delete(elemsToDelete);
                    end
                case 'BusElementMoved'
                    if~isempty(this.Children)
                        elemIdxs=eventData.mElemIdx;
                        this.Children=this.Children(elemIdxs);
                    end
                case 'BusObjectRenamed'
                    this.InRenameForBus=true;





                    delete(this.Children);
                    this.Children=Simulink.typeeditor.app.Element.empty;
                    this.InRenameForBus=false;
                case 'BusObjectRemoved'
                    delete(this.Children);
                    this.Children=Simulink.typeeditor.app.Element.empty;
                otherwise
                    assert(false);
                end
            end
        end

        function label=getDisplayLabel(this)






            label=this.SourceObject.Name;

        end

        function fileName=getDisplayIcon(this)
            if this.IsBus
                if(slfeature('CUSTOM_BUSES')==1)&&this.IsConnectionType
                    fileName=Simulink.typeeditor.utils.getBusEditorResourceFile('connection_bus_object.png');
                else
                    fileName=Simulink.typeeditor.utils.getBusEditorResourceFile('bus_object.png');
                end
            else
                if(slfeature('CUSTOM_BUSES')==1)&&this.IsConnectionType
                    fileName=Simulink.typeeditor.utils.getBusEditorResourceFile('connection_bus_element.png');
                else
                    fileName=Simulink.typeeditor.utils.getBusEditorResourceFile('bus_element.png');
                end
            end
        end

        function getPropertyStyle(this,propName,propStyleObj)
            typeProp=DAStudio.message('Simulink:busEditor:PropType');
            if strcmp(propName,typeProp)&&~this.IsConnectionType
                propStyleObj.Tooltip=[this.getPropValue(typeProp),' (',this.DataTypeColHeader,')'];
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
            if this.IsBus&&any(strcmp(propName,{this.DataTypeColHeader,this.TypeColHeader}))
                propStyleObj.Bold=true;
            end
            if this.ReadOnlyElement||this.isReadonlyProperty(propName)
                propStyleObj.Italic=true;
                bg=double(propStyleObj.BackgroundColor);
                bg(1:3)=0.95*ones(1,3);
                propStyleObj.BackgroundColor=bg;
            end
            if~this.isValidProperty(propName)
                bg=double(propStyleObj.BackgroundColor);
                bg(1:3)=0.95*ones(1,3);
                propStyleObj.BackgroundColor=bg;
            end













        end

        function dlgStruct=getDialogSchema(this)
            try
                enableDialog=~this.isInMultiselect;

                descGroup.Name=DAStudio.message('Simulink:busEditor:DDGProperties');
                descGroup.Type='togglepanel';
                descGroup.Expand=true;
                descGroup.Items={};

                rowidx=1;
                busnameEdit.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
                busnameEdit.Type='edit';
                busnameEdit.RowSpan=[rowidx,rowidx];
                busnameEdit.ColSpan=[1,4];
                busnameEdit.Value=this.SourceObject.Name;
                busnameEdit.Tag='Name';
                busnameEdit.Enabled=~this.isReadonlyProperty('Name');
                busnameEdit.Mode=true;
                busnameEdit.ObjectProperty=this.NameColHeader;
                busnameEdit.Graphical=true;
                descGroup.Items{end+1}=busnameEdit;



                isConnType=this.IsConnectionType;
                if isConnType
                    DTTag='Type';
                else
                    DTTag='DataType';
                end

                isValueType=~isConnType&&startsWith(this.SourceObject.Type,'ValueType: ');

                rowidx=rowidx+1;

                minimum.Tag='Min';
                maximum.Tag='Max';
                dtype=this.createDTAwidget(DTTag,minimum,maximum);
                dtype.RowSpan=[rowidx,rowidx];
                dtype.ColSpan=[1,4];

                descGroup.Items{end+1}=dtype;


                if isConnType
                    rowidx=rowidx+1;

                    physmodHyperlink.Name=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLink');
                    physmodHyperlink.Type='hyperlink';
                    physmodHyperlink.Tag='physmodHyperlink';
                    physmodHyperlink.MatlabMethod='helpview';
                    physmodHyperlink.MatlabArgs={'simscape','DomainLineStyles'};
                    physmodHyperlink.RowSpan=[rowidx,rowidx];
                    physmodHyperlink.ColSpan=[1,4];
                    physmodHyperlink.Enabled=true;
                    physmodHyperlink.ToolTip=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLinkTooltip');
                    physmodHyperlink.Alignment=1;

                    descGroup.Items{end+1}=physmodHyperlink;
                end

                rowDiff=0;
                if~isConnType&&~isValueType
                    rowidx=rowidx+1;
                    complexity.Name=DAStudio.message('Simulink:dialog:StructelementComplexLblName');
                    complexity.Type='combobox';
                    complexity.Tag='Complexity';
                    complexity.Entries={DAStudio.message('Simulink:dialog:real_CB'),DAStudio.message('Simulink:dialog:complex_CB')};
                    complexity.Value=find(strcmp(this.SourceObject.getPropAllowedValues('Complexity'),this.SourceObject.getPropValue('Complexity'))==1)-1;
                    complexity.RowSpan=[rowidx,rowidx];
                    complexity.ColSpan=[1,2];
                    complexity.Enabled=~this.isReadonlyProperty('Complexity');
                    complexity.Mode=true;
                    complexity.ObjectProperty=this.ComplexityColHeader;
                    complexity.Graphical=true;
                    descGroup.Items{end+1}=complexity;

                    rowidx=rowidx+1;
                    dims.Name=DAStudio.message('dastudio:ddg:WSODimensions');
                    dims.Type='edit';
                    dims.Tag='Dimensions';
                    dims.RowSpan=[rowidx,rowidx];
                    dims.ColSpan=[1,2];
                    dims.Value=mat2str(this.SourceObject.Dimensions);
                    dims.Enabled=~this.isReadonlyProperty('Dimensions');
                    dims.Mode=true;
                    dims.ObjectProperty=this.DimensionsColHeader;
                    dims.Graphical=true;
                    descGroup.Items{end+1}=dims;

                    dimsMode.Name=DAStudio.message('Simulink:dialog:BuselementDimsmodeLblName');
                    dimsMode.Type='combobox';
                    dimsMode.Tag='DimensionsMode';
                    dimsMode.Entries={DAStudio.message('Simulink:dialog:Fixed_CB'),DAStudio.message('Simulink:dialog:Variable_CB')};
                    dimsMode.Value=find(strcmp(this.SourceObject.getPropAllowedValues('DimensionsMode'),this.SourceObject.getPropValue('DimensionsMode'))==1)-1;
                    dimsMode.RowSpan=[rowidx,rowidx];
                    dimsMode.ColSpan=[3,4];
                    dimsMode.Enabled=~this.isReadonlyProperty('DimensionsMode');
                    dimsMode.Mode=true;
                    dimsMode.ObjectProperty=this.DimensionsModeColHeader;
                    dimsMode.Graphical=true;
                    descGroup.Items{end+1}=dimsMode;

                    doublePrecision=16;

                    rowidx=rowidx+1;



                    if(slfeature('BusElSampleTimeDep')==1)&&(this.SourceObject.SampleTime(1)==-1)
                        rowDiff=1;
                    else
                        stime.Name=DAStudio.message('Simulink:dialog:BuselementSamptimeLblName');
                        stime.Tag='SampleTime';
                        stime.Type='edit';
                        stime.RowSpan=[rowidx,rowidx];
                        stime.ColSpan=[1,2];
                        stime.Value=mat2str(this.SourceObject.SampleTime,doublePrecision);
                        stime.Enabled=~this.isReadonlyProperty('SampleTime');
                        stime.Mode=true;
                        stime.ObjectProperty=this.SampleTimeColHeader;
                        stime.Graphical=true;
                        descGroup.Items{end+1}=stime;
                    end


                    rowidx=rowidx+1;
                    minimum.Name=DAStudio.message('Simulink:dialog:DataMinimumPrompt');
                    minimum.Type='edit';
                    minimum.RowSpan=[rowidx-rowDiff,rowidx-rowDiff];
                    minimum.ColSpan=[1,2];
                    minimum.Value=mat2str(this.SourceObject.Min,doublePrecision);
                    minimum.Enabled=~this.isReadonlyProperty('Min');
                    minimum.Mode=true;
                    minimum.ObjectProperty=this.MinColHeader;
                    minimum.Graphical=true;
                    descGroup.Items{end+1}=minimum;

                    maximum.Name=DAStudio.message('Simulink:dialog:DataMaximumPrompt');
                    maximum.Type='edit';
                    maximum.RowSpan=[rowidx-rowDiff,rowidx-rowDiff];
                    maximum.ColSpan=[3,4];
                    maximum.Value=mat2str(this.SourceObject.Max,doublePrecision);
                    maximum.Enabled=~this.isReadonlyProperty('Max');
                    maximum.Mode=true;
                    maximum.ObjectProperty=this.MaxColHeader;
                    maximum.Graphical=true;
                    descGroup.Items{end+1}=maximum;

                    rowidx=rowidx+1;

                    unitEdit.Name=DAStudio.message('Simulink:dialog:DataUnitPrompt');
                    unitEdit.Type='edit';
                    unitEdit.RowSpan=[rowidx-rowDiff,rowidx-rowDiff];
                    unitEdit.ColSpan=[1,4];


                    unitEdit.Value=this.SourceObject.getPropValue(this.UnitColHeader);
                    unitEdit.Tag=this.UnitColHeader;
                    unitEdit.AutoCompleteType='Custom';
                    symbolPromptStr=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnSymbolPrompt'),'            '];
                    namePromptStr=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnNamePrompt'),'                                  '];
                    unitEdit.AutoCompleteViewColumn={' ',symbolPromptStr,namePromptStr};
                    unitEdit.AutoCompleteCompletionMode='UnfilteredPopupCompletion';
                    unitEdit.Enabled=~this.isReadonlyProperty(this.UnitColHeader);
                    unitEdit.Mode=true;
                    unitEdit.ObjectProperty=this.UnitColHeader;
                    unitEdit.Graphical=true;
                    descGroup.Items{end+1}=unitEdit;
                end

                if~isValueType
                    rowidx=rowidx+1;

                    descEdit.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
                    descEdit.Type='editarea';
                    descEdit.RowSpan=[rowidx-rowDiff,rowidx];
                    descEdit.ColSpan=[1,4];
                    descEdit.Value=this.SourceObject.getPropValue(this.DescriptionColHeader);
                    descEdit.Tag=this.DescriptionColHeader;
                    descEdit.Enabled=~this.isReadonlyProperty(this.DescriptionColHeader);
                    descEdit.Mode=true;
                    descEdit.ObjectProperty=this.DescriptionColHeader;
                    descEdit.Graphical=true;
                    descGroup.Items{end+1}=descEdit;
                end

                descGroup.LayoutGrid=[rowidx,1];
                descGroup.RowSpan=[1,1];
                descGroup.ColSpan=[1];%#ok
                descGroup.RowStretch=[zeros(1,(rowidx-1)),1];



                custompanel.Name='Custom';
                custompanel.Type='panel';
                custompanel.RowSpan=[2,2];
                custompanel.ColSpan=[1];%#ok





                [grpUserData,tabUserData]=sldialogs('get_userdata_prop_grp',this.SourceObject);




                dlgStruct.DialogTitle='';
                dlgStruct.Source=this;

                if(isempty(grpUserData.Items))
                    dlgStruct.Items={descGroup,custompanel};
                    dlgStruct.LayoutGrid=[2,1];
                    if isValueType
                        dlgStruct.RowStretch=[0,1];
                    else
                        dlgStruct.RowStretch=[1,0];
                    end
                    dlgStruct.ColStretch=[1];%#ok
                else




                    tab1.Name=descGroup.Name;
                    tab1.LayoutGrid=[2,1];
                    tab1.RowStretch=[1,0];
                    tab1.ColStretch=[1];%#ok
                    tab1.Items={descGroup,custompanel};
                    tab1.Tag='TabOne';

                    tabcont.Type='tab';
                    tabcont.Tabs={tab1,tabUserData};
                    tabcont.Tag='Tabcont';

                    dlgStruct.Items={tabcont};
                    dlgStruct.Items=sldialogs('remove_duplicate_widget_tags',dlgStruct.Items);
                end
                dlgStruct.EmbeddedButtonSet={''};
                dlgStruct.StandaloneButtonSet={''};
                dlgStruct.DialogMode='Slim';
                dlgStruct.DialogTag=this.DialogTag;

                if~enableDialog||this.ReadOnlyElement
                    dlgStruct=this.setDisabled(dlgStruct);
                end
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case 'DataTypeForDTA'
                propValue=this.SourceObject.Type;
            otherwise
                propValue=this.SourceObject.getPropValues(propName);
            end
        end

        function propValue=isHierarchyReadonly(this)
            if this.ReadOnlyElement
                propValue=true;
            else
                propValue=false;
            end
        end

        function allowed=isDragAllowed(this)%#ok<MANU>
            allowed=true;
        end

        function allowed=isDropAllowed(this)%#ok<MANU>
            allowed=true;
        end

        function items=getContextMenuItems(this)
            template=struct('label','','tag','','checkable',false,'checked',false,'command','','accel','','enabled',true,'icon','');

            sepItem=template;
            sepItem.tag='sepTag';
            sepItem.label='separator';




            ed=this.getEditor;
            typeChain=ed.getStudioWindow.getContextObject.TypeChain;
            commandStrProvider=ed.getCommandStrProvider();

            clear items;
            rowIdx=1;
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
            assert(ed.isVisible);
            pasteItem.enabled=~this.ReadOnlyElement&&any(strcmp('pasteActionEnable',typeChain))&&~isempty(ed.getClipboard.contents);
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
            deleteItem.enabled=~this.ReadOnlyElement&&any(strcmp('deleteActionEnable',typeChain));
            items(rowIdx)=deleteItem;
            rowIdx=rowIdx+1;

            if length(ed.getCurrentListNode)==1
                if this.ReadOnlyElement
                    resolvesToType=true;
                    dtStr=Simulink.typeeditor.utils.stripBusPrefix(this.Parent.SourceObject.Type);
                    gotoType=[dtStr,'.',this.Name];
                else
                    gotoTypeWithPrefix=split(this.getPropValue('Type'),':');
                    gotoType=strtrim(gotoTypeWithPrefix{end});
                    resolvesToType=this.doesVariableExistInWorkspace(gotoType);
                end

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
                end
            end
        end











        function isValid=isValidProperty(this,propName)
            if strcmp(propName,'DataTypeForDTA')
                isValid=true;
                return;
            end
            if this.IsConnectionType
                isValid=any(strcmp({this.NameColHeader,...
                this.TypeColHeader,...
                this.DescriptionColHeader},propName));
            else
                if startsWith(this.SourceObject.DataType,'ValueType: ')
                    isValid=any(strcmp({this.NameColHeader,...
                    this.DataTypeColHeader,...
                    this.TypeColHeader,},propName));
                else
                    if slfeature('TypeEditorStudio')==0
                        isValid=any(strcmp({this.NameColHeader,...
                        this.DataTypeColHeader,...
                        this.ComplexityColHeader,...
                        this.DimensionsColHeader,...
                        this.DimensionsModeColHeader,...
                        this.SampleTimeColHeader,...
                        this.MinColHeader,...
                        this.MaxColHeader,...
                        this.UnitColHeader,...
                        this.DescriptionColHeader},propName));
                    else
                        isValid=any(strcmp({this.NameColHeader,...
                        this.DataTypeColHeader,...
                        this.TypeColHeader,...
                        this.ComplexityColHeader,...
                        this.DimensionsColHeader,...
                        this.DimensionsModeColHeader,...
                        this.SampleTimeColHeader,...
                        this.MinColHeader,...
                        this.MaxColHeader,...
                        this.UnitColHeader,...
                        this.DescriptionColHeader},propName));
                    end
                end
            end
        end

        function isEditable=isEditableProperty(this,propName)
            if strcmp(propName,'DataTypeForDTA')
                isEditable=true;
                return;
            end
            if this.IsConnectionType
                isEditable=any(strcmp({this.NameColHeader,...
                this.TypeColHeader,...
                this.DescriptionColHeader},propName));
            else
                isEditable=any(strcmp({this.NameColHeader,...
                this.DataTypeColHeader,...
                this.TypeColHeader,...
                this.ComplexityColHeader,...
                this.DimensionsColHeader,...
                this.DimensionsModeColHeader,...
                this.SampleTimeColHeader,...
                this.MinColHeader,...
                this.MaxColHeader,...
                this.UnitColHeader,...
                this.DescriptionColHeader,...
                this.TypeColHeader},propName));
            end
        end

        function propValue=isReadonlyProperty(this,propName)
            if this.ReadOnlyElement
                propValue=true;
            else
                propValue=false;
                if this.IsBus
                    if any(strcmp(propName,{this.DimensionsModeColHeader,this.ComplexityColHeader,this.SamplingModeColHeader,...
                        this.SampleTimeColHeader,this.MinColHeader,this.MaxColHeader,this.UnitColHeader}))
                        propValue=true;
                    end
                end
                if startsWith(this.SourceObject.Type,'ValueType: ')
                    if any(strcmp(propName,{this.DimensionsColHeader,this.DimensionsModeColHeader,this.ComplexityColHeader,...
                        this.SamplingModeColHeader,this.SampleTimeColHeader,this.MinColHeader,...
                        this.MaxColHeader,this.UnitColHeader,this.DescriptionColHeader}))
                        propValue=true;
                    end
                end
            end
        end

        function propDT=getPropDataType(this,propName)
            if strcmp(propName,'DataTypeForDTA')
                propDT='string';
                return;
            end

            propDT=this.SourceObject.getPropDataTypes(propName);
        end

        function ch=getChildren(this,~)
            if~isempty(this.Children)

                ch=this.Children;
                return;
            else
                ch=[];
                if this.IsBus&&this.LoadImmediateChildren
                    subBusName=Simulink.typeeditor.utils.stripBusPrefix(this.getPropValue('Type'));
                    node=Simulink.typeeditor.utils.getNodeFromPath(this.getRoot,subBusName);
                    if~isempty(node)
                        if node.IsConnectionType==this.IsConnectionType
                            if isempty(node.Children)
                                node.ChildrenLoadedBeforeQuery=true;
                            end
                            node.LoadImmediateChildren=true;
                            nodeChildren=node.getChildren;
                            node.LoadImmediateChildren=false;

                            ch=Simulink.typeeditor.app.Element.empty;
                            for i=1:length(nodeChildren)
                                ch(i)=Simulink.typeeditor.app.Element(nodeChildren(i).SourceObject,this,true);
                            end
                        end
                    end
                end
                this.Children=ch;
            end
        end

        function ch=getHierarchicalChildren(this)
            ch=this.getChildren;
        end

        function propValues=getPropAllowedValues(this,propName)
            propValues={};

            if isempty(this.SourceObject)
                return;
            end

            rootNode=this.getRoot;
            context=rootNode.NodeConnection;

            if any(strcmpi(propName,{'datatype','type'}))



                dtaItems=this.getDataTypeItems;

                if isa(context,'Simulink.dd.Connection')
                    slprivate('slUpdateDataTypeListSource','set',context);
                end

                propValues=Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dtaItems,this);

                if isa(context,'Simulink.dd.Connection')
                    slprivate('slUpdateDataTypeListSource','clear');
                end
            elseif strcmp(propName,'NonBusDataType')
                if isa(context,'Simulink.dd.Connection')
                    slprivate('slUpdateDataTypeListSource','set',context);
                end



                propValues=rootNode.buselementbasictypes;

                if isa(context,'Simulink.dd.Connection')
                    slprivate('slUpdateDataTypeListSource','clear');
                end


                for k=length(propValues):-1:1
                    if this.isBusDataType(propValues{k})
                        propValues(k)=[];
                    end
                end
            else
                propValues=this.SourceObject.getPropAllowedValues(propName);
            end
        end


        function setPropValue(this,propName,propValue)




            try
                if strcmp(propName,'DataTypeForDTA')||...
                    strcmp(propName,this.TypeColHeader)
                    if this.IsConnectionType
                        propName=this.TypeColHeader;
                    else
                        propName=this.DataTypeColHeader;
                    end
                end
                currentPropValue=this.SourceObject.(propName);
                if slfeature('SLDataDictionarySetUserData')>0&&~isempty(this.SourceObject.TargetUserData)
                    [token,rem]=strtok(propName,'.');%#ok
                    if strcmp(token,'TargetUserData')
                        currentPropValue=this.getPropValue(propName);
                    end
                end
                assert(ischar(propValue));
                if isnumeric(currentPropValue)
                    charCurrentPropValue=mat2str(currentPropValue);
                else
                    charCurrentPropValue=currentPropValue;
                end
                if strcmp(charCurrentPropValue,propValue)
                    return;
                end

                propValue=strtrim(propValue);
                if~this.isValidPropValue(propName,propValue)
                    return;
                end
                this.updateWorkspace(propName,propValue);

                root=this.getRoot;
                if root.hasDictionaryConnection
                    ed=this.getEditor;
                    if ed.hasTreeComp
                        ed.getTreeComp.update(true);
                    end
                    if root.useSourceSLDDListener()


                        root.notifySLDDChanged;
                    end
                    root.refreshDataSourceChildren(this.Parent.Name);
                end
            catch ME
                Simulink.typeeditor.utils.reportError(ME.message);
            end
        end

        function valid=isValidPropValue(this,propName,propValue)
            valid=true;
            try
                isConnType=this.IsConnectionType;
                dtStr=this.TypeColHeader;
                if ismember(propName,{this.TypeColHeader,this.DataTypeColHeader})
                    tempPropValue=Simulink.typeeditor.utils.stripBusPrefix(propValue);
                    objNames=this.getRoot.Children.keys;
                    if ismember(tempPropValue,objNames)

                        if~ismember(tempPropValue,Simulink.typeeditor.utils.stripBusPrefix(this.getPropAllowedValues(dtStr)))
                            if this.IsConnectionType
                                errorID='Simulink:busEditor:InvalidTypeSpecified';
                            else
                                errorID='Simulink:busEditor:InvalidDataTypeSpecified';
                            end
                            errorStr=DAStudio.message(errorID);


                            ed=this.getEditor;
                            if isa(ed,'Simulink.typeeditor.app.Editor')
                                if slfeature('TypeEditorStudio')>0
                                    this.reportErrorFromContext(errorID,errorStr,propName,'Error');
                                else
                                    this.reportPIError(errorID,errorStr,propName,'Error');
                                end
                            end
                            valid=false;
                            return;
                        end
                    end
                end



                if~isConnType
                    if ismember(propName,{this.DimensionsColHeader,this.SampleTimeColHeader})
                        tempVar=eval(propValue);%#ok
                    end
                end


                if strcmpi(propName,'name')
                    elemNames=cellfun(@(elem)elem.Name,{this.Parent.Children.SourceObject},'UniformOutput',false);
                    if ismember(propValue,elemNames)
                        errorID='Simulink:busEditor:GenericAlreadyExistsByName';
                        errorMsg=DAStudio.message(errorID,[this.Parent.Name,'.',propValue]);
                        if slfeature('TypeEditorStudio')>0
                            this.reportErrorFromContext(errorID,errorMsg,propName,'Error');
                        else
                            this.reportPIError(errorID,errorMsg,propName,'Error');
                        end
                    end
                end
                if slfeature('TypeEditorStudio')>0
                    this.reportErrorFromContext;
                else
                    this.reportPIError(propName);
                end
            catch ME
                ERR=ME;
                valid=false;
                if strcmp(ME.identifier,'MATLAB:UndefinedFunction')...
                    &&strcmp('Dimensions',propName)...
                    &&doesVariableExistInWorkspace(this,propValue)
                    msg=DAStudio.message('Simulink:busEditor:InvalidNonCharArrayMatlabVariableName',propName);
                    ERR=MException('Simulink:busEditor:InvalidNonCharArrayMatlabVariableName',msg);
                end
                if slfeature('TypeEditorStudio')>0
                    this.reportErrorFromContext(ERR.identifier,ERR.message,propName,'Error');
                else
                    this.reportPIError(ERR.identifier,ERR.message,propName,'Error');
                end
                return;
            end
        end

        function updateWorkspace(this,propName,propValue)
            try
                elemNames=cellfun(@(elem)elem.Name,{this.Parent.Children.SourceObject},'UniformOutput',false);
                idx=find(strcmp(elemNames,this.SourceObject.Name),1);
                root=this.getRoot;
                idxInParent=this.Parent.findIdx(this.Name);
                ed=this.getEditor();
                lc=ed.getListComp;


                pv=this.addQuoteIfNonNumericString(propValue,propName);
                oldVariableID=root.NodeDataAccessor.identifyByName(this.Parent.Name);
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
                oldPropVal=oldVariable.Elements(idx).(propName);
                if slfeature('SLDataDictionarySetUserData')>0&&~isempty(this.SourceObject.TargetUserData)
                    token=strtok(propName,'.');
                    if strcmp(token,'TargetUserData')
                        val=propValue;
                        switch getPropDataType(this.Parent.SourceObject.Elements(idx),propName)
                        case 'enum'
                        case{'string','asciiString'}
                            val=DAStudio.MxStringConversion.convertToString(propValue);
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
                        oldVariable.Elements(idx).setPropValue(propName,val);
                    else
                        oldVariable.Elements(idx).(propName)=eval(pv);
                    end
                else
                    oldVariable.Elements(idx).(propName)=eval(pv);
                end
                success=root.NodeDataAccessor.updateVariable(oldVariableID,oldVariable);
                assert(success,'Property update failed');

                if~this.InRenameForBus&&~strcmp(oldPropVal,propValue)&&this.NotifyListener


                    assert(~this.ReadOnlyElement);
                    thisIdx=this.Parent.findIdx(this.Name);
                    eventType='BusElementChanged';
                    eventData=Simulink.typeeditor.app.EventData(eventType,BusName=this.Parent.Name,ElemName=this.Name,...
                    ElemIdx=thisIdx,IsConnType=this.IsConnectionType,PropName=propName,PropValue=pv);
                    this.getRoot.notify(eventType,eventData);
                end

                lastwarn('');

                eval(['this.SourceObject.',propName,' = ',pv,';']);%#ok<EVLDOT>


                if ismember(propName,{this.DataTypeColHeader,this.MinColHeader,this.MaxColHeader})
                    [msg,warnID]=lastwarn;
                    if~isempty(msg)
                        if slfeature('TypeEditorStudio')>0
                            this.reportErrorFromContext(warnID,msg,propName,'Warning');
                        else
                            this.reportPIError(warnID,msg,propName,'Warning');
                        end
                        lastwarn('');
                        lc.update(this);
                    else
                        if slfeature('TypeEditorStudio')>0
                            this.reportErrorFromContext;
                        else
                            this.reportPIError(propName);
                            this.reportPIError(this.MinColHeader);
                            this.reportPIError(this.MaxColHeader);
                        end
                    end
                end

                this.Parent.SourceObject.Elements(idxInParent)=this.SourceObject;

                refreshSS=false;
                if ismember(propName,{this.DataTypeColHeader,this.TypeColHeader})
                    refreshSS=true;
                    if this.isBusDataType(oldPropVal)
                        oldTypeName=Simulink.typeeditor.utils.stripBusPrefix(oldPropVal);
                        parentDepTypes=unique([this.Parent.getDependentTypes',this.Parent.getLeafElementsWithBusSpec]);
                        if~any(strcmp(oldTypeName,parentDepTypes))&&this.NotifyListener
                            oldTypeInvalidTypes=root.InvalidTypeCache(oldTypeName);
                            oldTypeInvalidTypes(strcmp(this.Parent.Name,oldTypeInvalidTypes))=[];
                            root.InvalidTypeCache(oldTypeName)=oldTypeInvalidTypes;
                        end
                    end
                    newPropVal=this.SourceObject.(propName);
                    if this.isBusDataType(newPropVal)
                        this.IsBus=true;
                        objs=this.Children;
                        this.Children=Simulink.typeeditor.app.Element.empty;
                        delete(objs);
                        if~this.InRenameForBus
                            this.LoadImmediateChildren=true;
                            this.getChildren;
                        end
                        typeName=Simulink.typeeditor.utils.stripBusPrefix(propValue);
                        if root.InvalidTypeCache.isKey(typeName)
                            root.InvalidTypeCache(typeName)=unique([root.InvalidTypeCache(typeName),{this.Parent.Name}]);
                        else
                            root.InvalidTypeCache(typeName)={this.Parent.Name};
                        end
                        this.updateListeners;
                    else
                        this.IsBus=false;
                        objs=this.Children;
                        this.Children=[];
                        delete(objs);
                    end
                end

                parentIdxInCache=strcmp(this.Parent.Name,root.WorkspaceCache(:,1));
                tempObj=root.WorkspaceCache{parentIdxInCache,2};
                tempObj.Elements(idxInParent)=this.SourceObject;
                root.WorkspaceCache{parentIdxInCache,2}=tempObj;

                if strcmpi(propName,'name')
                    oldPath=this.Path;
                    newPath=[this.Parent.Path,'.',this.Name];
                    this.Path=newPath;
                    if~strcmp(newPath,oldPath)
                        try %#ok<TRYNC>
                            Simulink.ModelManagement.Project.Buses.displayRename(oldPath,newPath);
                        end
                    end
                end
            catch ME
                if slfeature('TypeEditorStudio')>0
                    this.reportErrorFromContext(ME.identifier,ME.message,propName,'Error');
                else
                    this.reportPIError(ME.identifier,ME.message,propName,'Error');
                end
                return;
            end
            if refreshSS
                lc.update;
            else
                lc.update(this);
            end
            dlg=this.getDASDialogHandle;
            ed.update;
            if~isempty(dlg)&&ishandle(dlg)
                dlg.refresh;
                if this.IsConnectionType
                    dtTag='Type';
                else
                    dtTag='DataType';
                end
                Simulink.DataTypePrmWidget.callbackDataTypeWidget('valueChangeEvent',dlg,dtTag);
            end



            if isa(ed,'Simulink.typeeditor.app.Editor')
                ed.clearRowHighlights;
                this.highlightReferencedTypes;
            end
        end
    end

    methods
        function fObj=getForwardedObject(this)
            fObj=this;
        end



        function data=getAutoCompleteData(~,~,partialText)
            data=Simulink.UnitPrmWidget.getUnitSuggestions(partialText,[],false);
        end
    end

    methods
        function dtVars=validateDataTypeList(this,dtVars)



            if~this.ReadOnlyElement
                invalidTypes=cellfun(@(elem)['Bus: ',elem],this.getRoot.InvalidTypeCache(this.Parent.Name),'UniformOutput',false);
                [~,validIdxs]=setdiff({dtVars.name},invalidTypes);
                dtVars=dtVars(validIdxs);
            end
        end
    end

    methods(Access=private,Sealed)
        function typeWidget=createDTAwidget(this,tag,varargin)





            isConnType=this.IsConnectionType;
            if isConnType
                dtPrompt=[DAStudio.message('Simulink:busEditor:PropType'),':'];
            else
                dtPrompt=DAStudio.message('Simulink:dialog:StructelementDatatypeLblName');
            end
            dtStr=tag;
            dtName='DataTypeForDTA';
            dtTag=tag;
            dtVal=this.SourceObject.getPropValue(dtStr);
            dtaOn=false;

            this.DataTypeForDTA=dtVal;

            dtaItems=this.getDataTypeItems;

            if nargin>3
                minimum=varargin{1};
                maximum=varargin{2};
                dtaItems.scalingMinTag={minimum.Tag};
                dtaItems.scalingMaxTag={maximum.Tag};
            end

            root=this.getRoot;
            context=root.NodeConnection;
            if root.hasDictionaryConnection
                slprivate('slUpdateDataTypeListSource','set',context);
            end

            if this.getRoot.Call_slGetUserDataTypesFromWSDD
                slprivate('slGetUserDataTypesFromWSDD',this,[],[],true);
                this.getRoot.Call_slGetUserDataTypesFromWSDD=false;
            end

            typeWidget=Simulink.DataTypePrmWidget.getDataTypeWidget(this,dtName,...
            dtPrompt,dtTag,dtVal,dtaItems,dtaOn);
            typeWidget.Name='TypeWidget';
            typeWidgetItems=typeWidget.Items;
            DTComboboxIdx=strcmp(cellfun(@(elem)elem.Tag,typeWidgetItems,'UniformOutput',false),dtStr);
            DTAGroupIdx=strcmp(cellfun(@(elem)elem.Tag,typeWidgetItems,'UniformOutput',false),[dtStr,'|UDTDataTypeAssistGrp']);

            typeWidget.Items{DTComboboxIdx}.ToolTip='';
            typeWidget.Items{DTComboboxIdx}.Enabled=~this.isReadonlyProperty(this.TypeColHeader);










            if isConnType
                typeWidget.Items{DTAGroupIdx}.Name=erase(typeWidget.Items{DTAGroupIdx}.Name,'Data ');
                DTAOpenIdx=strcmp(cellfun(@(elem)elem.Tag,typeWidgetItems,'UniformOutput',false),[dtStr,'|UDTShowDataTypeAssistBtn']);
                typeWidget.Items{DTAOpenIdx}.ToolTip=erase(typeWidget.Items{DTAOpenIdx}.ToolTip,'data ');
                DTACloseIdx=strcmp(cellfun(@(elem)elem.Tag,typeWidgetItems,'UniformOutput',false),[dtStr,'|UDTHideDataTypeAssistBtn']);
                typeWidget.Items{DTACloseIdx}.ToolTip=erase(typeWidget.Items{DTACloseIdx}.ToolTip,'data ');
            end

            if root.hasDictionaryConnection
                slprivate('slUpdateDataTypeListSource','clear');
            end

            typeWidget=this.setImmediate(typeWidget);














        end

        function dtaItems=getDataTypeItems(this)





            persistent builtins;


            if~isempty(this.CachedDataTypeItems)
                dtaItems=this.CachedDataTypeItems;
            else


                if isempty(builtins)
                    builtins=Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');
                end

                isConnType=this.IsConnectionType;
                dtaItems.inheritRules={};
                dtaItems.extras=[];
                if~isConnType
                    dtaItems.builtinTypes=builtins;
                    dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode','UDTBestPrecisionMode'};
                    dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};

                    dtaItems.supportsEnumType=true;
                    dtaItems.supportsStringType=true;
                    dtaItems.supportsBusType=true;
                    dtaItems.supportsValueTypeType=true;
                end


                if isConnType
                    dtaItems.supportsConnectionType=true;
                    dtaItems.supportsConnectionBusType=true;
                end

                this.CachedDataTypeItems=dtaItems;
            end
        end

        function immediateVisibleDTAGroupItems=makeDTAImmediate(this,visibleDTAGroupItems,dtStr)
            if this.IsConnectionType
                switch(visibleDTAGroupItems{2}.Tag)
                case[dtStr,'|UDTConnTypeEdit']
                    visibleDTAGroupItems{2}.Mode=true;
                    visibleDTAGroupItems{2}.Graphical=true;
                case[dtStr,'|UDTConnBusTypeGrp']
                    if strcmp(visibleDTAGroupItems{2}.Items{1}.Tag,[dtStr,'|UDTConnBusTypeEdit'])
                        visibleDTAGroupItems{2}.Items{1}.Mode=true;
                        visibleDTAGroupItems{2}.Items{1}.Graphical=true;
                    end
                case[dtStr,'|UDTExprEdit']
                    visibleDTAGroupItems{2}.Mode=true;
                    visibleDTAGroupItems{2}.Graphical=true;
                end
            else
                switch(visibleDTAGroupItems{2}.Tag)
                case[dtStr,'|UDTBuiltinRadio']
                    idxsForImmediate=2;
                    if strcmp(visibleDTAGroupItems{4}.Tag,[dtStr,'|UDTDTOBuiltinCombo'])
                        idxsForImmediate(end+1)=4;
                    end
                    for i=1:length(idxsForImmediate)
                        visibleDTAGroupItems{idxsForImmediate(i)}.Mode=true;
                        visibleDTAGroupItems{idxsForImmediate(i)}.Graphical=true;
                    end
                case[dtStr,'|UDTFixedPointGrp']
                    immediateTags={'UDTSignRadio','UDTWordLengthEdit','UDTScalingModeRadio','UDTFractionLengthEdit',...
                    'UDTDTOBinaryPointCombo','UDTSlopeEdit','UDTBiasEdit','UDTDTOSlopeBiasCombo','UDTDTOBestPrecCombo'};
                    idxsForImmediate=[2,4,6,8,10,13,15,17,20];
                    if all(arrayfun(@(i)isequal(visibleDTAGroupItems{2}.Items{idxsForImmediate(i)}.Tag,...
                        [dtStr,'|',immediateTags{i}]),1:length(idxsForImmediate)))
                        for i=1:length(idxsForImmediate)
                            visibleDTAGroupItems{2}.Items{idxsForImmediate(i)}.Mode=true;
                            visibleDTAGroupItems{2}.Items{idxsForImmediate(i)}.Graphical=true;
                        end
                    end
                case[dtStr,'|UDTEnumTypeEdit']
                    visibleDTAGroupItems{2}.Mode=true;
                    visibleDTAGroupItems{2}.Graphical=true;
                case[dtStr,'|UDTBusTypeGrp']
                    if strcmp(visibleDTAGroupItems{2}.Items{1}.Tag,[dtStr,'|UDTBusTypeEdit'])
                        visibleDTAGroupItems{2}.Items{1}.Mode=true;
                        visibleDTAGroupItems{2}.Items{1}.Graphical=true;
                    end
                case[dtStr,'|UDTValueTypeTypeGrp']
                    if strcmp(visibleDTAGroupItems{2}.Items{1}.Tag,[dtStr,'|UDTValueTypeTypeEdit'])
                        visibleDTAGroupItems{2}.Items{1}.Mode=true;
                        visibleDTAGroupItems{2}.Items{1}.Graphical=true;
                    end
                case[dtStr,'|UDTExprEdit']
                    visibleDTAGroupItems{2}.Mode=true;
                    visibleDTAGroupItems{2}.Graphical=true;
                end
            end
            immediateVisibleDTAGroupItems=visibleDTAGroupItems;
        end

        function tf=isBusDataType(~,dtStr)


            if startsWith(dtStr,'Bus: ')
                tf=true;
                return;
            end
            tf=false;







        end
    end

    methods(Hidden)

        function out=getPropertySchema(this)
            out=this;
        end

        function s=getObjectName(this)
            s=this.SourceObject.Name;
        end

        function objType=getObjectType(this)
            objType=class(this.SourceObject);
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
                if this.IsConnectionType
                    helpKey='simulink_connection_element';
                else
                    helpKey='simulink_bus_element';
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
end












