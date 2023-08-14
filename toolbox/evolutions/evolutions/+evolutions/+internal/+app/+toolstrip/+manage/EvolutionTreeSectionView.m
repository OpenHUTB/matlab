classdef EvolutionTreeSectionView<evolutions.internal.ui.tools.ToolstripSection





    properties(Constant)
        Title=getString(message('evolutions:ui:EvolutionTreeSection'));
        Name='EvolutionTree';
    end

    events(NotifyAccess=?protected,ListenAccess=?evolutions.internal.app.toolstrip.manage...
        .EvolutionTreeSectionController)


ChangeTreeButtonClick
CreateTreeButtonClick
DeleteTreeButtonClick
    end

    properties(SetAccess=protected)

CreateTreeButton
CreateTreeIcon
CreateTreePopupList
CreateTreePopupListData

DeleteTreeButton
DeleteTreeIcon
DeleteTreePopupList
DeleteTreePopupListData

ChangeTreeButton
ChangeTreeIcon
ChangeTreePopupList
ChangeTreePopupListData
    end


    methods
        function this=EvolutionTreeSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,enabled,widgetName)

            switch widgetName
            case 'createTree'
                this.CreateTreeButton.Enabled=enabled;
            case 'changeTree'
                this.ChangeTreeButton.Enabled=enabled;
            otherwise
                assert(strcmp(widgetName,'deleteTree'));
                this.DeleteTreeButton.Enabled=enabled;
            end
        end

        function resetDropDownLists(this)
            this.CreateTreePopupListData=containers.Map;
            this.ChangeTreePopupListData=containers.Map;
            this.DeleteTreePopupListData=containers.Map;
        end

        function popup=updateCreateTreePopup(this,projectList,projectTreeMap)
            import matlab.ui.internal.toolstrip.*
            icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'Project_Select_16.png'));
            if~isequal(projectTreeMap,this.CreateTreePopupListData)
                popup=PopupList();
                header=PopupListHeader(getString(message...
                ('evolutions:ui:MainProject')));
                popup.add(header);
                projectFullPath=projectList{1};
                [~,projectDir]=fileparts(projectFullPath);
                listItem=ListItem(projectDir,icon);
                listItem.Description=projectFullPath;
                listItem.ItemPushedFcn=@this.createTreeAction;
                popup.add(listItem);
                if numel(projectList)>1

                    header=PopupListHeader(getString(message...
                    ('evolutions:ui:ReferenceProject')));
                    popup.add(header);
                    for idx=2:numel(projectList)
                        projectFullPath=projectList{idx};
                        [~,projectDir]=fileparts(projectFullPath);
                        listItem=ListItem(projectDir,icon);
                        listItem.Description=projectFullPath;
                        listItem.ItemPushedFcn=@this.createTreeAction;
                        popup.add(listItem);
                    end
                end
                this.CreateTreePopupList=popup;
                this.CreateTreePopupListData=projectTreeMap;
            else
                popup=this.CreateTreePopupList;
            end
        end

        function popup=updateDeleteTreePopup(this,projectList,projectTreeMap)
            import matlab.ui.internal.toolstrip.*
            icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'AppIcon_16.png'));
            if~isequal(projectTreeMap,this.DeleteTreePopupListData)
                popup=PopupList();
                for idx=1:numel(projectList)
                    projectFullPath=projectList{idx};
                    trees=projectTreeMap(projectFullPath);
                    if~isempty(trees)
                        [~,projDir]=fileparts(projectFullPath);
                        header=PopupListHeader(projDir);
                        popup.add(header);
                        for treeIdx=1:numel(trees)
                            listItem=ListItem(trees(treeIdx).getName,icon);
                            listItem.Description=...
                            fullfile(projectFullPath,trees(treeIdx).Id);
                            listItem.ShowDescription=false;
                            listItem.ItemPushedFcn=@this.deleteTreeAction;
                            popup.add(listItem);
                        end
                    end
                end
                this.DeleteTreePopupList=popup;
                this.DeleteTreePopupListData=projectTreeMap;
            else
                popup=this.DeleteTreePopupList;
            end
        end

        function popup=updateChangeTreePopup(this,projectList,projectTreeMap,currentSelectedTree)
            import matlab.ui.internal.toolstrip.*
            icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'AppIcon_16.png'));
            if~isequal(projectTreeMap,this.ChangeTreePopupListData)
                popup=PopupList();
                for idx=1:numel(projectList)
                    projectFullPath=projectList{idx};
                    trees=projectTreeMap(projectFullPath);
                    if~isempty(trees)
                        [~,projDir]=fileparts(projectFullPath);
                        header=PopupListHeader(projDir);
                        popup.add(header);
                        for treeIdx=1:numel(trees)
                            listItem=ListItem(trees(treeIdx).getName,icon);
                            listItem.Description=...
                            fullfile(projectFullPath,trees(treeIdx).Id);
                            listItem.ShowDescription=false;
                            listItem.Tag=trees(treeIdx).Id;
                            listItem.ItemPushedFcn=@this.changeTreeAction;

                            if isequal(listItem.Tag,currentSelectedTree.Id)
                                listItem.Enabled=false;
                            end
                            popup.add(listItem);
                        end
                    end
                end
                this.ChangeTreePopupList=popup;
                this.ChangeTreePopupListData=projectTreeMap;
            else
                popup=this.ChangeTreePopupList;
            end
        end
    end

    methods(Access=protected)
        function createSectionComponents(this)
            createCreateTreeButtonGroup(this);
            createDeleteTreeButtonGroup(this);
            createChangeTreeButtonGroup(this);
        end

        function layoutSection(this)

            add(this.Section.addColumn(),this.CreateTreeButton);
            column2=this.addColumn('HorizontalAlignment','left');
            add(column2,this.ChangeTreeButton);
            add(column2,this.DeleteTreeButton);
        end

        function createCreateTreeButtonGroup(this)
            this.CreateTreeIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'EvolutionTree_Create_24.png'));
            this.CreateTreeButton=this.createButton(...
            getString(message('evolutions:ui:NewTree')),...
            this.CreateTreeIcon,createChildTag(this,'Create'),...
            getString(message('evolutions:ui:NewTreeToolTip')));
        end

        function createDeleteTreeButtonGroup(this)
            this.DeleteTreeIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'Evolutions_DeleteBranch_16.png'));
            this.DeleteTreeButton=this.createDropDownButton(...
            getString(message('evolutions:ui:DeleteTree')),...
            this.DeleteTreeIcon,createChildTag(this,'Delete'),...
            getString(message('evolutions:ui:DeleteTreeToolTip')));
        end

        function createChangeTreeButtonGroup(this)
            this.ChangeTreeIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'EvolutionTree_Select_16.png'));
            this.ChangeTreeButton=this.createDropDownButton(...
            getString(message('evolutions:ui:ChangeTree')),...
            this.ChangeTreeIcon,createChildTag(this,'Change'),...
            getString(message('evolutions:ui:ChangeTreeToolTip')));
        end
    end

    methods(Hidden,Access=protected)

        function changeTreeAction(this,src,~)
            [Data.ProjectFullPath,Data.TreeId]=...
            fileparts(src.Description);
            Data.TreeName=src.Text;

            this.ChangeTreePopupList.enableAll;
            selected=this.ChangeTreePopupList.getChildByTag(Data.TreeId);
            selected.Enabled=false;
            notify(this,'ChangeTreeButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end

        function createTreeAction(this,src,~)
            Data.ProjectFullPath=src.Description;
            notify(this,'CreateTreeButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end

        function deleteTreeAction(this,src,~)
            [Data.ProjectFullPath,Data.TreeId]=...
            fileparts(src.Description);
            Data.TreeName=src.Text;
            notify(this,'DeleteTreeButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end
    end

    methods(Static=true,Access=protected)
        function tag=createTag(projectName,treeName)
            tag=sprintf('%s%s%s',projectName,filesep,treeName);
        end
    end
end


