classdef Domain<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mData;
        mRegisteredNamesSource;
        mTopicsSource;
        mGetListFunc;
        mGetObjFunc;
    end

    methods
        function this=Domain(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function setGetChildrenFunc(this,getListFunc,getObjFunc)
            this.mGetListFunc=getListFunc;
            this.mGetObjFunc=getObjFunc;
        end

        function refresh(this)
            this.mRefreshChildren=true;
        end

        function dlgstruct=getDialogSchema(this,arg)
            domainIDLabel.Type='text';
            domainIDLabel.Name=message('dds:ui:DomainID').getString;
            domainIDLabel.RowSpan=[1,1];
            domainIDLabel.ColSpan=[1,1];

            domainID.Type='edit';
            domainID.Tag='DomainID';
            domainID.RowSpan=[1,1];
            domainID.ColSpan=[2,2];
            domainID.Source=this;
            domainID.Mode=1;
            domainID.ObjectProperty='DomainID';


            registerTypes.Type='spreadsheet';
            registerTypes.Tag='ssRegisterTypes';
            registerTypes.Columns={' ','Name','TypeRef'};
            if isempty(this.mRegisteredNamesSource)
                this.mRegisteredNamesSource=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain(this.mMdl,this.mTree,this.mNode);
                this.mRegisteredNamesSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNames',...
                'dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNameObj');
            else
                this.mRegisteredNamesSource.refresh();
            end
            registerTypes.Source=this.mRegisteredNamesSource;
            registerTypes.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.onSelectionChanged(tag,sels,dlg);


            row=1;
            if this.getShowActions()
                addBtn.Type='pushbutton';
                addBtn.Tag='RegTypeBtn';
                addBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','RegisterType_16.png');
                addBtn.ToolTip=message('dds:ui:AddRegTypeTooltip').getString;
                addBtn.RowSpan=[row,row];
                addBtn.ColSpan=[1,1];
                addBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.RegisterType.create';
                addBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                dupBtn.Type='pushbutton';
                dupBtn.Tag='DuplicateBtn';
                dupBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                dupBtn.ToolTip=message('dds:ui:DuplicateRowsTooltip').getString;
                dupBtn.RowSpan=[row,row];
                dupBtn.ColSpan=[2,2];
                dupBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.duplicateWidgetRow';
                dupBtn.MatlabArgs={'%dialog',registerTypes.Tag,this.mMdl};
                dupBtn.Enabled=false;

                delBtn.Type='pushbutton';
                delBtn.Tag='DelBtn';
                delBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delBtn.ToolTip=message('dds:ui:DelRegTypeTooltip').getString;
                delBtn.RowSpan=[row,row];
                delBtn.ColSpan=[4,4];
                delBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.removeWidgetRow';
                delBtn.MatlabArgs={'%dialog',registerTypes.Tag,this.mMdl};
                delBtn.Enabled=false;

                row=row+1;
            end


            registerTypes.RowSpan=[row,3];
            registerTypes.ColSpan=[1,5];

            registerTypeGrp.Type='group';
            registerTypeGrp.Flat=0;
            registerTypeGrp.Name=message('dds:ui:RegTypesGroup').getString;
            registerTypeGrp.RowStretch=[0,0,1];
            registerTypeGrp.ColStretch=[0,0,0,0,1];
            registerTypeGrp.LayoutGrid=[3,5];
            registerTypeGrp.RowSpan=[2,3];
            registerTypeGrp.ColSpan=[1,3];
            if this.getShowActions()
                registerTypeGrp.Items={addBtn,dupBtn,delBtn,registerTypes};
            else
                registerTypeGrp.Items={registerTypes};
            end


            row=1;

            topicsList.Type='spreadsheet';
            topicsList.Tag='ssTopics';
            topicsList.Columns={' ','Name','RegisterTypeRef'};
            if isempty(this.mTopicsSource)
                this.mTopicsSource=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain(this.mMdl,this.mTree,this.mNode);
                this.mTopicsSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getTopicsList',...
                'dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getTopicObj');
            else
                this.mTopicsSource.refresh();
            end
            topicsList.Source=this.mTopicsSource;
            topicsList.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.onSelectionChanged(tag,sels,dlg);


            if this.getShowActions()
                addTopicBtn.Type='pushbutton';
                addTopicBtn.Tag='AddTopicBtn';
                addTopicBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Topic_16.png');
                addTopicBtn.ToolTip=message('dds:ui:AddTopicTooltip').getString;
                addTopicBtn.RowSpan=[row,row];
                addTopicBtn.ColSpan=[1,1];
                addTopicBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Topic.create';
                addTopicBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                duplicateBtn.Type='pushbutton';
                duplicateBtn.Tag='DuplicateTopicBtn';
                duplicateBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                duplicateBtn.ToolTip=message('dds:ui:DuplicateRowsTooltip').getString;
                duplicateBtn.RowSpan=[row,row];
                duplicateBtn.ColSpan=[2,2];
                duplicateBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.duplicateWidgetRow';
                duplicateBtn.MatlabArgs={'%dialog',topicsList.Tag,this.mMdl};
                duplicateBtn.Enabled=false;

                delTopicBtn.Type='pushbutton';
                delTopicBtn.Tag='DelTopicBtn';
                delTopicBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delTopicBtn.ToolTip=message('dds:ui:DelTopicTooltip').getString;
                delTopicBtn.RowSpan=[row,row];
                delTopicBtn.ColSpan=[4,4];
                delTopicBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.removeWidgetRow';
                delTopicBtn.MatlabArgs={'%dialog',topicsList.Tag,this.mMdl};
                delTopicBtn.Enabled=false;
                row=row+1;
            end


            topicsList.RowSpan=[row,3];
            topicsList.ColSpan=[1,5];

            topicsListGrp.Type='group';
            topicsListGrp.Flat=0;
            topicsListGrp.Name=message('dds:ui:TopicsGroup').getString;
            topicsListGrp.RowStretch=[0,0,1];
            topicsListGrp.ColStretch=[0,0,0,0,1];
            topicsListGrp.LayoutGrid=[3,5];
            topicsListGrp.RowSpan=[4,6];
            topicsListGrp.ColSpan=[1,3];
            if this.getShowActions()
                topicsListGrp.Items={addTopicBtn,duplicateBtn,delTopicBtn,topicsList};
            else
                topicsListGrp.Items={topicsList};
            end

            panel.Type='panel';
            panel.LayoutGrid=[5,3];
            panel.RowStretch=[0,0,1,0,1];
            panel.ColStretch=[0,0,1];
            panel.Items={domainIDLabel,domainID,registerTypeGrp,topicsListGrp};

            dlgstruct.Items={panel};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function setPropValue(this,propName,propVal)
            if~isequal(propName,'DomainID')
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,propVal);
                return;
            end
            this.mNode.DomainID=str2num(propVal);
        end

        function children=getChildren(this)
            if isempty(this.mData)||this.mRefreshChildren
                this.mRefreshChildren=false;
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function children=generateChildren(this)
            childList=feval(this.mGetListFunc,this.mNode);

            children=[];
            if isempty(childList)
                return;
            end

            childObj=feval(this.mGetObjFunc,this.mNode,childList{1});
            dataClass=['dds.internal.simulink.ui.internal.',class(childObj)];
            children=feval(dataClass,this.mMdl,this.mTree,childObj);
            for i=2:numel(childList)
                childObj=feval(this.mGetObjFunc,this.mNode,childList{i});
                children(i)=feval(dataClass,this.mMdl,this.mTree,childObj);
            end
        end

        function addObject(this,type)
            if isequal(type,'Topic')
                dds.internal.simulink.ui.internal.dds.datamodel.domain.Topic.create(this.mMdl,this.mTree,this.mNode,'');
            end
        end

        function domainObj=duplicate(this)
            domainLibNode=this.mNode.Container;
            domains=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomains(domainLibNode);
            txn=this.mMdl.beginTransaction;
            domainObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,domains,this.mNode,'');
            domainLibNode.Domains.add(domainObj);
            txn.commit;
        end

        function typeChain=getTypeChain(this)
            typeChain={this.getClassName()};
        end
    end


    methods(Static,Access=public)

        function r=onSelectionChanged(tag,sels,dlg)
            if isequal(tag,'ssRegisterTypes')
                delBtn='DelBtn';
                dupBtn='DuplicateBtn';
            else
                delBtn='DelTopicBtn';
                dupBtn='DuplicateTopicBtn';
            end
            if~isempty(delBtn)
                dlg.setEnabled(delBtn,~isempty(sels));
            end
            if~isempty(dupBtn)
                dlg.setEnabled(dupBtn,~isempty(sels));
            end
        end

        function domainObj=create(ddsMdl,~,domainLibNode,name)
            domains=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomains(domainLibNode);
            txn=ddsMdl.beginTransaction;
            domainObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,domains,'dds.datamodel.domain.Domain',name);
            domainLibNode.Domains.add(domainObj);
            txn.commit;
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

        function registeredNames=getRegisteredNames(domainNode)
            registeredNames={};
            regTypes=domainNode.RegisterTypes;
            registeredNames=regTypes.keys;
        end

        function regNameObj=getRegisteredNameObj(domainNode,regName)
            regNameObj=[];
            regTypes=domainNode.RegisterTypes;
            try
                regNameObj=regTypes{regName};
            catch
            end
        end

        function topics=getTopicsList(domainNode)
            topics={};
            topicMap=domainNode.Topics;
            topics=topicMap.keys;
        end

        function topicObj=getTopicObj(domainNode,topicName)
            topicObj=[];
            topicMap=domainNode.Topics;
            try
                topicObj=topicMap{topicName};
            catch
            end
        end

    end


    methods(Access=private)


    end
end
