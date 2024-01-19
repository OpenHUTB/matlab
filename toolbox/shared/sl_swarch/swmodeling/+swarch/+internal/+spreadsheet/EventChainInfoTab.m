classdef EventChainInfoTab<swarch.internal.spreadsheet.AbstractSoftwareModelingTab

    properties(Access=private)
HighlightingOn
    end


    methods
        function this=EventChainInfoTab(spreadSheetObj)
            this=this@swarch.internal.spreadsheet.AbstractSoftwareModelingTab(spreadSheetObj);
            this.HighlightingOn=false;
        end


        function columns=getColumnNames(~)
            columns{1}=getString(message('SoftwareArchitecture:ArchEditor:EventChainNameColumn'));
            if slfeature('ZCEventChainAdvanced')>0
                columns{end+1}=getString(message('SoftwareArchitecture:ArchEditor:EventChainDurationColumn'));
            end
        end


        function tabName=getTabName(~)
            tabName=getString(...
            message('SoftwareArchitecture:ArchEditor:EventChainTabName'));

        end


        function refreshChildren(this)
            this.pChildren=this.getDataSources();
        end


        function addChildToArchitecture(this)
            timingTrait=this.getRootArchitecture().getTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass);
            if isempty(timingTrait)
                timingTrait=this.getRootArchitecture().addTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass);
            end

            assert(~isempty(timingTrait));
            timingTrait.createEventChain('EC');
        end


        function removeChildFromArchitecture(this,~)
            cellfun(@(s)s.get().destroy(),this.getCurrentSelection());
        end


        function dlgStruct=getDialogSchema(this,~)
            addEventChainButton.Type='pushbutton';
            addEventChainButton.FilePath=this.getIconPath('plusIcon_16.png');
            addEventChainButton.MatlabMethod='swarch.internal.spreadsheet.addEventChainToArchitecture';
            addEventChainButton.MatlabArgs={this};
            addEventChainButton.Tag='addEventChainButtonTag';
            addEventChainButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:addEventChainToolTip'));
            addEventChainButton.Alignment=2;
            removeEventChainButton.Type='pushbutton';
            removeEventChainButton.FilePath=this.getIconPath('minusIcon_16.png');
            removeEventChainButton.ObjectMethod='removeEventChainRow';
            removeEventChainButton.Tag='removeEventChainButtonTag';
            removeEventChainButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:removeEventChainToolTip'));
            removeEventChainButton.Alignment=2;
            removeEventChainButton.Enabled=this.isOwnedChainSelected()||...
            (this.isReferenceChainSelected()&&this.isEditableChainSelected());
            addSubChainButton.Type='pushbutton';
            addSubChainButton.FilePath=this.getIconPath('addSubChain_16.png');
            addSubChainButton.ObjectMethod='addSubChainToSelection';
            addSubChainButton.Tag='addSubChainButtonTag';
            addSubChainButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:addSubChainToolTip'));
            addSubChainButton.Alignment=2;
            addSubChainButton.Enabled=isOwnedChainSelected(this);
            highlightChainToggleButton.Type='togglebutton';
            highlightChainToggleButton.FilePath=[matlabroot,'/toolbox/simulink/ui/studio/config/icons/highlightBlock_16.png'];
            highlightChainToggleButton.ObjectMethod='toggleHighlightChains';
            highlightChainToggleButton.Value=this.HighlightingOn;
            highlightChainToggleButton.Tag='highlightEventChainButtonTag';
            highlightChainToggleButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:toggleEventChainHighlightingTooltip'));
            highlightChainToggleButton.Alignment=2;

            buttonPanel.Type='panel';
            buttonPanel.Items={addEventChainButton,removeEventChainButton,...
            addSubChainButton,highlightChainToggleButton};
            buttonPanel.LayoutGrid=[1,6];
            buttonPanel.ColStretch=[0,0,0,0,0,1];
            buttonPanel.RowStretch=0;
            buttonPanel.RowSpan=[1,1];
            buttonPanel.ColSpan=[1,1];

            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogMode='Slim';
            dlgStruct.Items={buttonPanel};
            dlgStruct.DialogTag='event_chains_button_panel_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end


        function removeEventChainRow(this)
            if this.isReferenceChainSelected()
                sel=this.getCurrentSelection;
                sel{1}.removeFromParent();
            else
                swarch.internal.spreadsheet.removeEventChainFromArchitecture(this);
            end
        end


        function addSubChainToSelection(this)
            assert(this.isOwnedChainSelected());
            sel=this.getCurrentSelection;
            sel{1}.addChildElement(swarch.internal.spreadsheet.EventChainRefDataSource(...
            this,sel{1}.get()));
            this.pParentSpreadSheet.getComponent().update(true);
        end


        function tf=isReferenceChainSelected(this)
            tf=false;

            sel=this.getCurrentSelection;
            if~isempty(sel)
                tf=sel{1}.isEventChainReference();
            end
        end


        function tf=isEditableChainSelected(this)
            tf=false;

            sel=this.getCurrentSelection;
            if~isempty(sel)
                tf=~sel{1}.isReadOnly();
            end
        end


        function tf=isOwnedChainSelected(this)
            tf=false;

            sel=this.getCurrentSelection;
            if~isempty(sel)
                tf=~sel{1}.isEventChainReference();
            end
        end


        function requiresUpdate=processChangeReport(this,changeReport)
            if this.hasDestroyedChildren(changeReport)||...
                this.hasCreatedChildren(changeReport)||...
                this.hasHierarchyChange(changeReport)
                requiresUpdate=true;
                this.refreshChildren();
            else
                requiresUpdate=this.hasModifiedChildren(changeReport);
            end
        end


        function hierChange=hasHierarchyChange(~,changeReport)
            hierChange=false;
            if isempty(changeReport.Modified)

                return;
            end
            modifiedElems={changeReport.Modified.Element};
            isModifiedEC=cellfun(@(el)isa(el,...
            'systemcomposer.architecture.model.traits.EventChain'),modifiedElems);
            if all(~isModifiedEC)
                return
            end
            modifiedECs=changeReport.Modified(isModifiedEC);
            for ec=modifiedECs
                if any(strcmp('subChains',{ec.ModifiedProperties.name}))
                    hierChange=true;
                    return;
                end
            end
        end


        function created=hasCreatedChildren(~,changeReport)
            allCreatedElems=changeReport.Created;
            isChild=@(el)isa(el,'systemcomposer.architecture.model.traits.EventChain');
            created=any(arrayfun(isChild,allCreatedElems));
        end


        function modified=hasModifiedChildren(this,changeReport)

            if isempty(changeReport.Modified)
                modified=false;
                return;
            end
            allModifiedElems=[changeReport.Modified.Element];
            allModifiedUUIDs={allModifiedElems.UUID};
            isModified=@(child)containsModifiedChild(child.get(),allModifiedUUIDs);
            modified=any(arrayfun(isModified,this.pChildren));
        end


        function destroyed=hasDestroyedChildren(this,~)
            isDestroyed=@(child)~isvalid(child.get());
            destroyed=any(arrayfun(isDestroyed,this.pChildren));
        end


        function handleSelectionChanged(this)
            this.getSpreadsheet().ActiveTabData=[];

            sel=this.getCurrentSelection;
            if~isempty(sel)
                if this.HighlightingOn
                    this.getSpreadsheet().ActiveTabData=swarch.internal.spreadsheet.EventChainHighlighter(sel{1}.get());
                end
            end
            this.refreshTitleDialog();
        end


        function toggleHighlightChains(this)
            this.getSpreadsheet().ActiveTabData=[];

            if this.HighlightingOn
                this.HighlightingOn=false;
            else
                this.HighlightingOn=true;
                sel=this.getCurrentSelection;
                if~isempty(sel)
                    this.getSpreadsheet().ActiveTabData=swarch.internal.spreadsheet.EventChainHighlighter(sel{1}.get());
                end
            end
        end
    end


    methods(Access=private)
        function dataSources=getDataSources(this)

            dataSources=[];
            rootArch=this.getRootArchitecture();

            if rootArch.hasTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass)
                for ec=rootArch.getTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass).eventChains.toArray
                    dataSources=[dataSources...
                    ,swarch.internal.spreadsheet.EventChainInfoDataSource(this,ec)];%#ok<AGROW>
                end
            end
            swComponents=swarch.utils.getAllSoftwareComponents(rootArch);
            for swComp=swComponents
                arch=swComp.getArchitecture();
                if arch.hasTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass)
                    for ec=arch.getTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass).eventChains.toArray
                        dataSources=[dataSources...
                        ,swarch.internal.spreadsheet.EventChainInfoDataSource(this,ec)];%#ok<AGROW>
                    end
                end
            end

            for i=1:length(dataSources)
                ec=dataSources(i).get();
                for j=1:ec.subChains.Size
                    childSource=dataSources(arrayfun(@get,dataSources)==ec.subChains(j));
                    assert(~isempty(childSource),'Event chain must exist!');
                    assert(childSource~=dataSources(i),'Event chain cannot have recursive definition!');
                    dataSources(i).addChildElement(childSource.makeReference(ec));
                end
            end
        end


        function refreshTitleDialog(this)
            ss=this.getSpreadsheet();
            comp=ss.getComponent();
            titleDlg=comp.getTitleView();
            titleDlg.refresh;
        end
    end
end


function modified=containsModifiedChild(mfEventChain,allModifiedUUIDs)

    modified=false;
    for idx=1:numel(allModifiedUUIDs)
        curUUID=allModifiedUUIDs{idx};
        if strcmpi(mfEventChain.UUID,curUUID)
            modified=true;
            break;
        end
    end
end


