classdef ProfileSectionView<evolutions.internal.ui.tools.ToolstripSection



    properties(Constant)

        Title='Profile';
        Name='Profile';
    end

    events(NotifyAccess=?protected,ListenAccess=?evolutions.internal.app.toolstrip.manage...
        .ProfileSectionController)


AddProfileButtonClick
RemoveProfileButtonClick

    end

    properties(SetAccess=protected)

AddProfileButton
AddProfileIcon
AddProfilePopupList
AddProfilePopupListData

RemoveProfileButton
RemoveProfileIcon
RemoveProfilePopupList
RemoveProfilePopupListData
    end

    methods
        function this=ProfileSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,enabled,widgetName)

            switch widgetName
            case 'addProfile'
                this.AddProfileButton.Enabled=enabled;
            otherwise
                assert(strcmp(widgetName,'removeProfile'));
                this.RemoveProfileButton.Enabled=enabled;
            end
        end

        function resetDropDownLists(this)
            this.AddProfilePopupListData=containers.Map;
            this.RemoveProfilePopupList=containers.Map;
        end

        function popup=updateAddProfilePopup(this,profileList)
            import matlab.ui.internal.toolstrip.*
            icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'AppIcon_16.png'));
            popup=PopupList();
            for profileIdx=1:numel(profileList)
                listItem=ListItem(profileList{profileIdx},icon);
                listItem.ItemPushedFcn=@this.addProfileAction;
                popup.add(listItem);
            end
            this.AddProfilePopupList=popup;
        end

        function popup=updateRemoveProfilePopup(this,profileList)
            import matlab.ui.internal.toolstrip.*
            icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'AppIcon_16.png'));
            popup=PopupList();
            for profileIdx=1:numel(profileList)
                listItem=ListItem(profileList{profileIdx},icon);
                listItem.ItemPushedFcn=@this.removeProfileAction;
                popup.add(listItem);
            end
            this.RemoveProfilePopupList=popup;
        end
    end

    methods(Access=protected)
        function createSectionComponents(this)
            createAddProfileButtonGroup(this);
            createRemoveProfileButtonGroup(this);
        end

        function layoutSection(this)
            column=this.addColumn('HorizontalAlignment','left');
            add(column,this.AddProfileButton);
            add(column,this.RemoveProfileButton);
        end

        function createAddProfileButtonGroup(this)
            this.AddProfileIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'EvolutionTree_Select_16.png'));
            this.AddProfileButton=this.createDropDownButton(...
            'Add Profile',...
            this.AddProfileIcon,createChildTag(this,'Add'),...
            'Add Profile');
        end

        function createRemoveProfileButtonGroup(this)
            this.RemoveProfileIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'EvolutionTree_Select_16.png'));
            this.RemoveProfileButton=this.createDropDownButton(...
            'Remove Profile',...
            this.RemoveProfileIcon,createChildTag(this,'Remove'),...
            'Remove Profile');
        end

        function addProfileAction(this,src,~)
            Data.ProfileName=src.Text;
            notify(this,'AddProfileButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end

        function removeProfileAction(this,src,~)
            Data.ProfileName=src.Text;
            notify(this,'RemoveProfileButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end
    end
end


