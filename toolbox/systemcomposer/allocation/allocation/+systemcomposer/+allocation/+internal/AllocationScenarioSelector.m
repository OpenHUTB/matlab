classdef AllocationScenarioSelector<systemcomposer.internal.mixin.CenterDialog









    properties
        allocator systemcomposer.allocation.internal.ContextMenuAllocator
scenarioPath
activeDialog
    end

    methods
        function obj=AllocationScenarioSelector(allocator)
            obj.allocator=allocator;
        end

        function schema=getDialogSchema(this)


            treeItems=this.getAllocationSetTreeData();

            allocBrowser.Type='tree';
            allocBrowser.Name=DAStudio.message('SystemArchitecture:studio:SelectActiveScenario');
            allocBrowser.Tag='allocScenarioBrowser';
            allocBrowser.TreeItems=treeItems;
            allocBrowser.TreeMultiSelect=false;
            allocBrowser.ExpandTree=true;
            allocBrowser.Source=this;
            allocBrowser.ObjectMethod='handleClickTreeNode';
            allocBrowser.MethodArgs={'%dialog','%value'};
            allocBrowser.ArgDataTypes={'handle','mxArray'};
            allocBrowser.DialogRefresh=true;
            allocBrowser.Graphical=true;
            allocBrowser.RowSpan=[1,3];
            allocBrowser.ColSpan=[1,1];

            selectedScenarioTxt.Type='text';
            selectedScenarioTxt.Tag='selectedScenarioText';
            if isempty(this.scenarioPath)
                selectedScenarioTxt.Name=[...
                DAStudio.message('SystemArchitecture:studio:SelectedScenario'),...
                ' ',...
                DAStudio.message('SystemArchitecture:studio:none')];
            else
                selectedScenarioTxt.Name=[...
                DAStudio.message('SystemArchitecture:studio:SelectedScenario'),...
                ' ',...
                this.scenarioPath];
            end
            selectedScenarioTxt.RowSpan=[4,4];
            selectedScenarioTxt.ColSpan=[1,4];

            newBtn.Type='pushbutton';
            newBtn.Tag='newAllocationSetButton';
            newBtn.Name=DAStudio.message('SystemArchitecture:studio:New');
            newBtn.ObjectMethod='handleNewButton';
            newBtn.MethodArgs={'%dialog'};
            newBtn.ArgDataTypes={'handle'};
            newBtn.RowSpan=[1,1];
            newBtn.ColSpan=[2,2];

            openBtn.Type='pushbutton';
            openBtn.Tag='openAllocationSetButton';
            openBtn.Name=DAStudio.message('SystemArchitecture:studio:Open');
            openBtn.Source=this;
            openBtn.ObjectMethod='handleOpenButton';
            openBtn.MethodArgs={'%dialog'};
            openBtn.ArgDataTypes={'handle'};
            openBtn.RowSpan=[2,2];
            openBtn.ColSpan=[2,2];

            group.Type='group';
            group.Items={allocBrowser,selectedScenarioTxt,newBtn,openBtn};
            group.LayoutGrid=[4,2];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:studio:SelectActiveScenario');
            schema.DisplayIcon='';
            schema.Items={group};
            schema.DialogTag='system_composer_allocation_selector';
            schema.Source=this;
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.ExplicitShow=true;
            schema.PreApplyMethod='preApply';
            schema.PreApplyArgs={'%dialog'};
            schema.PreApplyArgsDT={'handle'};
            schema.StandaloneButtonSet={'OK','Cancel'};
            schema.Sticky=true;
        end

        function handleOpenDialog(this,dlg)

            this.positionDialog(dlg,this.allocator.getTargetModel());
            dlg.show();
        end

        function handleClickTreeNode(obj,dlg,val)


            [allocSetName,scenarioName]=strtok(val,'/');


            if isempty(scenarioName)
                catalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance();
                allocSet=catalog.getAllocationSet(allocSetName);
                scenarios=allocSet.getScenarios();
                scen=scenarios(1);
                obj.scenarioPath=[allocSetName,'/',scen.getName()];
            else

                obj.scenarioPath=val;
            end
            dlg.refresh();
        end

        function handleOpenButton(~,dlg)


            [fname,pname]=uigetfile('*.mldatx',...
            DAStudio.message('SystemArchitecture:studio:SelectAllocSetFileToOpen'));
            if~ischar(fname)
                return;
            end
            systemcomposer.allocation.load(fullfile(pname,fname));
            dlg.refresh();
        end

        function handleNewButton(this,dlg)



            this.activeDialog=dlg;
            obj=systemcomposer.allocation.internal.AllocationSetCreator(this);
            DAStudio.Dialog(obj);
        end

        function mdl=getSourceModel(this)
            mdl=this.allocator.getSourceModel();
        end

        function mdl=getTargetModel(this)
            mdl=this.allocator.getTargetModel();
        end

        function refresh(this)
            this.activeDialog.refresh();
        end

        function preApply(this,~)



            if isempty(this.scenarioPath)
                error(message('SystemArchitecture:studio:ErrorNoScenarioSelected'));
            end
            this.allocator.setCurrentScenarioAndContinueAllocate(this.scenarioPath);
        end
    end

    methods(Access=private)
        function treeItems=getAllocationSetTreeData(this)
            catalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance();
            allocSets=catalog.getAllocationSets();

            treeItems={};
            for idx=1:length(allocSets)
                allocSet=systemcomposer.allocation.internal.getWrapperForImpl(allocSets(idx));



                if~this.allocator.allocSetMatchesElems(allocSet)
                    continue;
                end

                treeItems=[treeItems,{allocSet.Name}];%#ok<*AGROW> 
                scenarios=allocSet.Scenarios;
                scenarioNames={};
                for s=1:length(scenarios)
                    scenario=scenarios(s);
                    scenarioNames=[scenarioNames,{scenario.Name}];
                end
                treeItems=[treeItems,{scenarioNames}];
            end
        end
    end
end