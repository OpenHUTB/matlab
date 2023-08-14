classdef AllocationSetCreator<systemcomposer.internal.mixin.CenterDialog








    properties
        selector systemcomposer.allocation.internal.AllocationScenarioSelector
        createNewAllocSet=false;
        newAllocSetName='NewAllocationSet';
        allocScenarioName='Scenario 1';
    end

    methods
        function obj=AllocationSetCreator(selector)
            obj.selector=selector;
        end

        function schema=getDialogSchema(this)

            catalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance();
            allocSets=catalog.getAllocationSets();
            entries={};
            for idx=1:length(allocSets)
                allocSet=systemcomposer.allocation.internal.getWrapperForImpl(allocSets(idx));
                if this.selector.allocator.allocSetMatchesElems(allocSet)
                    entries=[entries,{allocSet.Name}];%#ok<*AGROW> 
                end
            end
            entries{end+1}=DAStudio.message('SystemArchitecture:studio:CreateNewAllocSet');
            if length(entries)==1
                this.createNewAllocSet=true;
            end

            allocSetCombo.Type='combobox';
            allocSetCombo.Name=DAStudio.message('SystemArchitecture:studio:AllocationSet');
            allocSetCombo.Tag='allocSetCombo';
            allocSetCombo.Entries=entries;
            allocSetCombo.Source=this;
            allocSetCombo.ObjectMethod='handleAllocSetSelection';
            allocSetCombo.MethodArgs={'%dialog','%value'};
            allocSetCombo.ArgDataTypes={'handle','char'};
            allocSetCombo.RowSpan=[1,1];
            allocSetCombo.ColSpan=[1,2];

            allocSetName.Type='edit';
            allocSetName.Tag='allocSetNameEditBox';
            allocSetName.Name=DAStudio.message('SystemArchitecture:studio:NewAllocationSet');
            allocSetName.Visible=this.createNewAllocSet;
            allocSetName.Source=this;
            allocSetName.ObjectProperty='newAllocSetName';
            allocSetName.Mode=true;
            allocSetName.RowSpan=[2,2];
            allocSetName.ColSpan=[1,2];

            srcModelName.Type='edit';
            srcModelName.Name=DAStudio.message('SystemArchitecture:studio:SourceModel');
            srcModelName.Enabled=false;
            srcModelName.Source=this;
            srcModelName.ObjectProperty='srcModelNameForAllocSet';
            srcModelName.RowSpan=[3,3];
            srcModelName.ColSpan=[2,2];
            srcModelName.Visible=false;

            tgtModelName.Type='edit';
            tgtModelName.Name=DAStudio.message('SystemArchitecture:studio:TargetModel');
            tgtModelName.Enabled=false;
            tgtModelName.Source=this;
            tgtModelName.ObjectProperty='srcModelNameForAllocSet';
            tgtModelName.RowSpan=[4,4];
            tgtModelName.ColSpan=[2,2];
            tgtModelName.Visible=false;

            scenarioName.Type='edit';
            scenarioName.Tag='allocScenarioNameEditBox';
            scenarioName.Name=DAStudio.message('SystemArchitecture:studio:NewAllocScenario');
            scenarioName.Source=this;
            scenarioName.ObjectProperty='allocScenarioName';
            scenarioName.Mode=true;
            scenarioName.RowSpan=[5,5];
            scenarioName.ColSpan=[2,2];

            group.Type='group';
            group.Items={allocSetCombo,allocSetName,srcModelName,tgtModelName,scenarioName};
            group.LayoutGrid=[6,2];
            group.RowStretch=[0,0,0,0,0,1];
            group.ColStretch=[0,1];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:studio:CreateAllocSetOrScenario');
            schema.DisplayIcon='';
            schema.Items={group};
            schema.DialogTag='system_composer_allocation_set_creator';
            schema.Source=this;
            schema.SmartApply=true;
            schema.Sticky=true;
            schema.StandaloneButtonSet={'OK','Cancel'};
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.ExplicitShow=true;
            schema.PreApplyMethod='preApply';
            schema.PreApplyArgs={'%dialog'};
            schema.PreApplyArgsDT={'handle'};
        end

        function handleOpenDialog(this,dlg)

            this.positionDialog(dlg,this.selector.getTargetModel());
            dlg.show();
        end

        function handleAllocSetSelection(this,dlg,~)
            this.createNewAllocSet=strcmp(...
            dlg.getComboBoxText('allocSetCombo'),...
            DAStudio.message('SystemArchitecture:studio:CreateNewAllocSet'));
            dlg.refresh();
        end

        function preApply(this,dlg)


            if this.createNewAllocSet&&~isvarname(this.newAllocSetName)
                error(message('SystemArchitecture:studio:InvalidAllocSetName'))
            end
            if isempty(this.allocScenarioName)
                error(message('SystemArchitecture:studio:InvalidAllocScenarioName'))
            end
            srcModel=this.selector.getSourceModel();
            tgtModel=this.selector.getTargetModel();

            if(this.createNewAllocSet)
                allocSet=systemcomposer.allocation.createAllocationSet(this.newAllocSetName,srcModel,tgtModel);


                defaultScenario=allocSet.Scenarios;
                defaultScenario.Name=this.allocScenarioName;
            else


                allocSetToUseName=dlg.getComboBoxText('allocSetCombo');
                allocSet=systemcomposer.allocation.AllocationSet.find(allocSetToUseName);
                existingScenario=allocSet.getScenario(this.allocScenarioName);
                if~isempty(existingScenario)
                    error(message('SystemArchitecture:studio:AllocScenarioAlreadyExists',...
                    this.allocScenarioName,allocSetToUseName));
                end
                allocSet.createScenario(this.allocScenarioName);
            end

            this.selector.refresh();
        end
    end

end