classdef EvolutionsSectionView<evolutions.internal.ui.tools.ToolstripSection







    properties(Constant)
        Title=getString(message('evolutions:ui:Evolutions'));
        Name='Evolution';
    end

    properties(SetAccess=protected)

CreateButton
CreateIcon


UpdateButton
UpdateIcon


DeleteSelected
DeleteSelectedIcon

DeleteBranch
DeleteBranchIcon

GetButton
GetIcon
    end

    methods
        function this=EvolutionsSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,enabled,widgetName)

            switch widgetName
            case 'create'
                this.CreateButton.Enabled=enabled;
            case 'update'
                this.UpdateButton.Enabled=enabled;
            case 'get'
                this.GetButton.Enabled=enabled;
            case 'deletenode'
                this.DeleteSelected.Enabled=enabled;
            otherwise
                assert(strcmp(widgetName,'deletebranch'));
                this.DeleteBranch.Enabled=enabled;
            end
        end
    end

    methods(Access=protected)
        function createSectionComponents(this)
            createCreateButtonGroup(this);
            createUpdateButtonGroup(this);
            createGetButtonGroup(this);
            createDeleteSelectedButtonGroup(this);
            createDeleteBranchButtonGroup(this);
        end

        function layoutSection(this)
            add(this.Section.addColumn(),this.CreateButton);
            column2=this.addColumn('HorizontalAlignment','left');
            add(column2,this.GetButton);
            add(column2,this.UpdateButton);
            column3=this.addColumn('HorizontalAlignment','left');
            add(column3,this.DeleteSelected);
            add(column3,this.DeleteBranch);
        end

        function createCreateButtonGroup(this)

            iconsPath=this.IconsFilePath;
            this.CreateIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'Evolutions_Create_24.png'));
            this.CreateButton=this.createButton(...
            getString(message('evolutions:ui:Create')),...
            this.CreateIcon,createChildTag(this,'Create'),...
            getString(message('evolutions:ui:CreateToolTip')));
        end

        function createUpdateButtonGroup(this)

            iconsPath=this.IconsFilePath;
            this.UpdateIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'Evolutions_ReplaceWithActive_16.png'));
            this.UpdateButton=this.createButton(...
            getString(message('evolutions:ui:Update')),...
            this.UpdateIcon,...
            createChildTag(this,'Update'),...
            getString(message('evolutions:ui:UpdateToolTip')));

        end

        function createGetButtonGroup(this)

            iconsPath=this.IconsFilePath;
            this.GetIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'ActiveFiles_ReplaceWithEvolution_16.png'));
            this.GetButton=this.createButton(...
            getString(message('evolutions:ui:GetEvolution')),...
            this.GetIcon,createChildTag(this,'GetFiles'),...
            getString(message('evolutions:ui:GetEvolutionToolTip')));
        end

        function createDeleteBranchButtonGroup(this)

            iconsPath=this.IconsFilePath;
            this.DeleteBranchIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'Evolutions_DeleteBranch_16.png'));
            this.DeleteBranch=this.createButton(...
            getString(message('evolutions:ui:DeleteBranch')),...
            this.DeleteBranchIcon,createChildTag(this,'DeleteBranch'),...
            getString(message('evolutions:ui:DeleteBranchToolTip')));
        end

        function createDeleteSelectedButtonGroup(this)

            iconsPath=this.IconsFilePath;
            this.DeleteSelectedIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'Evolutions_DeleteEvolution_16.png'));
            this.DeleteSelected=this.createButton(...
            getString(message('evolutions:ui:DeleteSelected')),...
            this.DeleteSelectedIcon,createChildTag(this,'DeleteSelected'),...
            getString(message('evolutions:ui:DeleteSelectedToolTip')));
        end
    end
end


