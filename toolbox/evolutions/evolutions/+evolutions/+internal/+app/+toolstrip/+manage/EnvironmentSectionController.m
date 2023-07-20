classdef EnvironmentSectionController<evolutions.internal.ui.tools.ToolstripSectionController




    properties(Hidden,SetAccess=immutable)

AppModel
AppController

EnvironmentSectionView


EventHandler

StateController
    end

    properties(SetAccess=protected)

        EnableButtons logical
    end

    properties(SetAccess=protected)

ChangeLayoutButtonClickListener
StateListener
    end

    methods
        function this=EnvironmentSectionController(appController)

            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.EnvironmentSectionView=getSubView(appController,'EnvironmentSection');
            this.EnableButtons=false;
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;
        end


        function delete(this)
            deleteListeners(this);
        end
    end


    methods(Access=protected)
        function deleteListeners(this)
            listeners=["ChangeLayoutButtonClickListener",...
            "StateListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function updateView(~)

        end

        function installModelListeners(~)
        end

        function installViewListeners(this)

            view=this.EnvironmentSectionView;



            view.LayoutButton.DynamicPopupFcn=@(~,~)createLayoutPopupList(this);
            view.LayoutButton.ButtonPushedFcn=@(~,~)onDefaultLayoutButtonClick(this);
            this.ChangeLayoutButtonClickListener=...
            addlistener(view,'ChangeLayoutButtonClick',@this.onChangeLayoutButtonClick);
            this.ChangeLayoutButtonClickListener=...
            addlistener(view,'DefaultLayoutButtonClick',@this.onDefaultLayoutButtonClick);
            this.ChangeLayoutButtonClickListener=...
            addlistener(view,'SaveLayoutButtonClick',@this.onSaveLayoutButtonClick);
            this.ChangeLayoutButtonClickListener=...
            addlistener(view,'OrganizeLayoutButtonClick',@this.onOrganizeLayoutButtonClick);
            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);
        end
    end


    methods(Hidden,Access=protected)
        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end

        function popup=createLayoutPopupList(this)
            layouts=this.getLayouts;
            view=this.EnvironmentSectionView;
            popup=updateLayoutPopup(view,layouts);
        end

        function onChangeLayoutButtonClick(this,~,data)
            layoutPath=data.EventData.Name;
            appView=getAppView(this.AppController);
            layoutJSON=fileread(layoutPath);
            layout=jsondecode(layoutJSON);
            setLayout(appView,layout);
        end


        function onDefaultLayoutButtonClick(this,~,~)
            this.AppController.setDefaultManageLayout;
        end

        function onSaveLayoutButtonClick(this,~,~)
            name=this.AppController.CustomDialogInterface.getLayoutName;
            if~isempty(name)
                layoutOutputFile=fullfile(this.getLayoutDir,strcat(name,'.json'));

                appView=getAppView(this.AppController);

                layoutData=rmfield(appView.ToolGroup.Layout,'windowBounds');


                layoutData.documentLayout.tileCount=0;
                layoutData.documentLayout.tileOccupancy=[];

                layout=jsonencode(layoutData);

                evolutions.internal.utils.createDirSafe(this.getLayoutDir)
                fid=fopen(layoutOutputFile,'w');
                fprintf(fid,layout);
                fclose(fid);
                this.EnvironmentSectionView.setLayoutOutOfDate;
            end
        end

        function onOrganizeLayoutButtonClick(this,~,~)
            this.AppController.CustomDialogInterface.getOrganizeLayout(this.getLayoutDir);
            this.EnvironmentSectionView.setLayoutOutOfDate;
        end

        function layouts=getLayouts(this)
            layoutDir=this.getLayoutDir;
            folderList=dir(fullfile(layoutDir,'*.json'));
            layouts=cell.empty;
            if~isempty(folderList)
                fileNames={folderList.name}';

                nonHiddenFiles=cellfun(@(x)~strcmp(x(1),'.'),fileNames);
                layouts=fileNames(nonHiddenFiles);
                for idx=1:numel(layouts)
                    layouts{idx}=fullfile(layoutDir,layouts{idx});
                end
            end
        end

        function layoutDir=getLayoutDir(~)
            layoutDir=fullfile(prefdir,'evolutions','layouts','manage');
        end

    end
end


