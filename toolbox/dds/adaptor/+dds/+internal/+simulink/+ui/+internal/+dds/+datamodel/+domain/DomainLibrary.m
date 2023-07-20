classdef DomainLibrary<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mData;
    end

    methods
        function this=DomainLibrary(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function refresh(this)
            this.mRefreshChildren=true;
        end

        function dlgstruct=getDialogSchema(this,arg)

            row=1;

            this.refresh();
            domains.Type='spreadsheet';
            domains.Tag='ssDomains';
            domains.Columns={' ','Name','DomainID'};
            domains.Source=this;
            domains.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.onSelectionChanged(tag,sels,dlg);


            if this.getShowActions()
                addBtn.Type='pushbutton';
                addBtn.Tag='AddBtn';
                addBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Domain_16.png');
                addBtn.ToolTip=message('dds:ui:AddDomainTooltip').getString;
                addBtn.RowSpan=[row,row];
                addBtn.ColSpan=[1,1];
                addBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.create';
                addBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                dupBtn.Type='pushbutton';
                dupBtn.Tag='DupBtn';
                dupBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                dupBtn.ToolTip=message('dds:ui:DupDomainTooltip').getString;
                dupBtn.RowSpan=[row,row];
                dupBtn.ColSpan=[2,2];
                dupBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.duplicateWidgetRow';
                dupBtn.MatlabArgs={'%dialog',domains.Tag,this.mMdl};
                dupBtn.Enabled=false;

                delBtn.Type='pushbutton';
                delBtn.Tag='DelBtn';
                delBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delBtn.ToolTip=message('dds:ui:DelDomainTooltip').getString;
                delBtn.RowSpan=[row,row];
                delBtn.ColSpan=[4,4];
                delBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.removeWidgetRow';
                delBtn.MatlabArgs={'%dialog',domains.Tag,this.mMdl};
                delBtn.Enabled=false;

                row=row+1;
            end


            domains.RowSpan=[row,3];
            domains.ColSpan=[1,5];

            domainsGrp.Type='group';
            domainsGrp.Flat=0;
            domainsGrp.Name=message('dds:ui:DomainsGroup').getString;
            domainsGrp.RowStretch=[0,0,1];
            domainsGrp.ColStretch=[0,0,0,0,1];
            domainsGrp.LayoutGrid=[3,5];
            domainsGrp.RowSpan=[1,3];
            domainsGrp.ColSpan=[1,3];
            if this.getShowActions()
                domainsGrp.Items={addBtn,dupBtn,delBtn,domains};
            else
                domainsGrp.Items={domains};
            end

            panel.Type='panel';
            panel.LayoutGrid=[3,3];
            panel.RowStretch=[0,0,1];
            panel.ColStretch=[0,0,1];
            panel.Items={domainsGrp};

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
            domains=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomains(this.mNode);
            children=[];
            if isempty(domains)
                return;
            end

            domainObj=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomainObj(this.mNode,domains{1});
            dataClass=['dds.internal.simulink.ui.internal.',class(domainObj)];
            children=feval(dataClass,this.mMdl,this.mTree,domainObj);
            for i=2:numel(domains)
                domainObj=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomainObj(this.mNode,domains{i});
                children(i)=feval(dataClass,this.mMdl,this.mTree,domainObj);
            end
        end

        function addSection(this)
            dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.create(this.mMdl,this.mTree,this.mNode,'');
        end

        function domainLibObj=duplicate(this)
            domainLibs=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomainLibraries(this.mTree);

            txn=this.mMdl.beginTransaction;
            domainLibObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,domainLibs,this.mNode,'');
            systemInModel=dds.internal.getSystemInModel(this.mMdl);
            systemInModel.DomainLibraries.add(domainLibObj);
            txn.commit;
        end

        function typeChain=getTypeChain(this)
            typeChain={this.getClassName()};
        end
    end


    methods(Static,Access=public)

        function r=onSelectionChanged(tag,sels,dlg)
            if isequal(tag,'ssDomains')
                delBtn='DelBtn';
                dupBtn='DupBtn';
            end
            if~isempty(delBtn)
                dlg.setEnabled(delBtn,~isempty(sels));
            end
            if~isempty(dupBtn)
                dlg.setEnabled(dupBtn,~isempty(sels));
            end
        end

        function domainLibObj=create(ddsMdl,ddsTree,~,name)
            domainLibs=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.getDomainLibraries(ddsTree);
            txn=ddsMdl.beginTransaction;
            domainLibObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,domainLibs,'dds.datamodel.domain.DomainLibrary',name);
            systemInModel=dds.internal.getSystemInModel(ddsMdl);
            systemInModel.DomainLibraries.add(domainLibObj);
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

        function domainLibs=getDomainLibraries(ddsTree)
            domainLibs=ddsTree.System.DomainLibraries.keys;
        end

        function domains=getDomains(domainLibNode)
            domains=domainLibNode.Domains.keys;
        end

        function domainObj=getDomainObj(domainLibNode,domainName)
            domainObj=domainLibNode.Domains{domainName};
        end

    end



    methods(Access=private)


    end
end
