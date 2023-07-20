classdef QosLibrary<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mData;
        mProfilesSource;
        mQosSource;
        mGetListFunc;
    end

    properties(Constant,Hidden)
        HIDDENPROPS={'Name','QosProfiles','Base','Default','Annotations'};
    end

    methods
        function this=QosLibrary(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end
        function refresh(this)
            this.mRefreshChildren=true;
        end

        function setGetChildrenFunc(this,getListFunc)
            this.mGetListFunc=getListFunc;
        end

        function dlgstruct=getDialogSchema(this,arg)

            row=1;

            profiles.Type='spreadsheet';
            profiles.Tag='ssProfiles';
            profiles.Columns={' ','Name'};

            if isempty(this.mProfilesSource)
                this.mProfilesSource=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary(this.mMdl,this.mTree,this.mNode);
                this.mProfilesSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.getProfileList');
            else
                this.mProfilesSource.refresh();
            end
            profiles.Source=this.mProfilesSource;
            profiles.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.onSelectionChanged(tag,sels,dlg);


            if this.getShowActions()
                dupBtn.Type='pushbutton';
                dupBtn.Tag='DupBtn';
                dupBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                dupBtn.ToolTip=message('dds:ui:DupProfileTooltip').getString;
                dupBtn.RowSpan=[row,row];
                dupBtn.ColSpan=[2,2];
                dupBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.duplicateWidgetRow';
                dupBtn.MatlabArgs={'%dialog',profiles.Tag,this.mMdl};
                dupBtn.Enabled=false;

                delBtn.Type='pushbutton';
                delBtn.Tag='DelBtn';
                delBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delBtn.ToolTip=message('dds:ui:DelProfileTooltip').getString;
                delBtn.RowSpan=[row,row];
                delBtn.ColSpan=[3,3];
                delBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.removeWidgetRow';
                delBtn.MatlabArgs={'%dialog',profiles.Tag,this.mMdl};
                delBtn.Enabled=false;

                row=row+1;
            end


            profiles.RowSpan=[row,3];
            profiles.ColSpan=[1,4];

            profilesGrp.Type='group';
            profilesGrp.Flat=0;
            profilesGrp.Name=message('dds:ui:ProfilesGroup').getString;
            profilesGrp.RowStretch=[0,0,1];
            profilesGrp.ColStretch=[0,0,0,1];
            profilesGrp.LayoutGrid=[3,4];
            profilesGrp.RowSpan=[1,3];
            profilesGrp.ColSpan=[1,3];
            if this.getShowActions()
                profilesGrp.Items={dupBtn,delBtn,profiles};
            else
                profilesGrp.Items={profiles};
            end


            row=1;

            qos.Type='spreadsheet';
            qos.Tag='ssQos';
            qos.Columns={' ','Name','QosType'};
            if isempty(this.mQosSource)
                this.mQosSource=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary(this.mMdl,this.mTree,this.mNode);
                this.mQosSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.getQosList');
            else
                this.mQosSource.refresh();
            end
            qos.Source=this.mQosSource;
            qos.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.onSelectionChanged(tag,sels,dlg);


            if this.getShowActions()
                dupQosBtn.Type='pushbutton';
                dupQosBtn.Tag='DupQosBtn';
                dupQosBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                dupQosBtn.ToolTip=message('dds:ui:DupQosTooltip').getString;
                dupQosBtn.RowSpan=[row,row];
                dupQosBtn.ColSpan=[2,2];
                dupQosBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.duplicateWidgetRow';
                dupQosBtn.MatlabArgs={'%dialog',qos.Tag,this.mMdl};
                dupQosBtn.Enabled=false;

                delQosBtn.Type='pushbutton';
                delQosBtn.Tag='DelQosBtn';
                delQosBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delQosBtn.ToolTip=message('dds:ui:DelQosTooltip').getString;
                delQosBtn.RowSpan=[row,row];
                delQosBtn.ColSpan=[3,3];
                delQosBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.removeWidgetRow';
                delQosBtn.MatlabArgs={'%dialog',qos.Tag,this.mMdl};
                delQosBtn.Enabled=false;

                row=row+1;
            end


            qos.RowSpan=[row,3];
            qos.ColSpan=[1,4];

            qosGrp.Type='group';
            qosGrp.Flat=0;
            qosGrp.Name=message('dds:ui:QosGroup').getString;
            qosGrp.RowStretch=[0,0,1];
            qosGrp.ColStretch=[0,0,0,1];
            qosGrp.LayoutGrid=[3,4];
            qosGrp.RowSpan=[3,5];
            qosGrp.ColSpan=[1,3];
            if this.getShowActions()
                qosGrp.Items={dupQosBtn,delQosBtn,qos};
            else
                qosGrp.Items={qos};
            end

            panel.Type='panel';
            panel.LayoutGrid=[5,3];
            panel.RowStretch=[0,1,0,0,2];
            panel.ColStretch=[0,0,1];
            panel.Items={profilesGrp,qosGrp};

            dlgstruct.Items={panel};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function children=getChildren(this)
            if isempty(this.mData)||this.mRefreshChildren
                this.mRefreshChildren=false;
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function children=generateChildren(this)
            children=[];
            [childNameList,childObjList]=feval(this.mGetListFunc,this.mNode);
            if isempty(childNameList)
                return;
            end

            childObj=childObjList{1};
            dataClass=['dds.internal.simulink.ui.internal.',class(childObj)];
            children=feval(dataClass,this.mMdl,this.mTree,childObj);
            for i=2:numel(childNameList)
                childObj=childObjList{i};
                children(i)=feval(dataClass,this.mMdl,this.mTree,childObj);
            end
        end

        function domainLibObj=duplicate(this)
            qosLibs=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.getQosLibraries(this.mTree);
            txn=this.mMdl.beginTransaction;
            qosLibObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,qosLibs,this.mNode,'');
            systemInModel=dds.internal.getSystemInModel(this.mMdl);
            systemInModel.QosLibraries.add(qosLibObj);
            txn.commit;
        end

        function typeChain=getTypeChain(this)
            typeChain={'Qos'};
        end
    end


    methods(Static,Access=public)

        function qosLibs=getQosLibraries(ddsTree)
            qosLibs=ddsTree.System.QosLibraries.keys;
        end

        function[profiles,profileObjs]=getProfileList(qosLibNode)
            profiles={};
            profileObjs={};
            if any(ismember(properties(qosLibNode),'QosProfiles'))
                keys=qosLibNode.QosProfiles.keys;
                for i=1:qosLibNode.QosProfiles.Size
                    elem=qosLibNode.QosProfiles{keys{i}};
                    profiles{end+1}=elem.Name;
                    profileObjs{end+1}=elem;
                end
            end
        end

        function[qoses,qosObjs]=getQosList(qosLibNode)
            qoses={};
            qosObjs={};
            props=properties(qosLibNode);

            idxs=ismember(props,dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.HIDDENPROPS);
            props(idxs,:)=[];
            for idx=1:numel(props)
                item=qosLibNode.(props{idx});
                for keyidx=1:numel(item.keys)
                    qoses{end+1}=item.keys{keyidx};%#ok<AGROW> 
                    qosObjs{end+1}=item{item.keys{keyidx}};%#ok<AGROW> 
                end
            end
        end

        function qosSection=findSection(qosLibNode,qosObj)
            qosSection=[];
            props=properties(qosLibNode);
            for idx=1:numel(props)
                item=qosLibNode.(props{idx});
                if any(strcmp(methods(item),'toArray'))
                    list=item.toArray;
                    if~isempty(list)
                        if isequal(class(list(1)),class(qosObj))
                            qosSection=item;
                            break;
                        end
                    end
                end
            end
        end

        function r=onSelectionChanged(tag,sels,dlg)
            if isequal(tag,'ssProfiles')
                delBtn='DelBtn';
                dupBtn='DupBtn';
            elseif isequal(tag,'ssQos')
                delBtn='DelQosBtn';
                dupBtn='DupQosBtn';
            end
            if~isempty(delBtn)
                dlg.setEnabled(delBtn,~isempty(sels));
            end
            if~isempty(dupBtn)
                dlg.setEnabled(dupBtn,~isempty(sels));
            end
        end

        function removeWidgetRow(dlg,wTag,ddsMdl)
            ssWidget=dlg.getWidgetInterface(wTag);
            selection=ssWidget.getSelection;
            dds.internal.simulink.ui.internal.DDSLibraryUI.deleteSelection(ddsMdl,selection);
        end

        function duplicateWidgetRow(dlg,wTag,ddsMdl)
            ssWidget=dlg.getWidgetInterface(wTag);
            selection=ssWidget.getSelection;
            for i=1:numel(selection)
                selection{i}.duplicate();
            end
        end

    end



    methods(Access=private)


    end
end


