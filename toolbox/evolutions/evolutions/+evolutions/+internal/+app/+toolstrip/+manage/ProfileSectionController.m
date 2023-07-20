classdef ProfileSectionController<evolutions.internal.ui.tools.ToolstripSectionController





    properties(SetAccess=immutable)

AppModel
AppController
AppView

ProfileSectionView

EventHandler

StateController
    end

    properties(SetAccess=protected)

StateListener

AddProfileButtonClickListener
RemoveProfileButtonClickListener
    end

    methods
        function this=ProfileSectionController(appController)
            this.AppController=appController;
            this.AppView=getAppView(appController);
            this.AppModel=getAppModel(appController);
            this.ProfileSectionView=getSubView(appController,'ProfileSection');
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;
        end

        function updateWidgetStates(this)
            view=this.ProfileSectionView;
            state=this.StateController;


            enableWidget(view,state.DeleteEvolutionTree,'addProfile');
            enableWidget(view,state.DeleteEvolutionTree,'removeProfile');
        end
    end


    methods(Access=protected)
        function updateView(~)

        end

        function installModelListeners(~)

        end

        function installViewListeners(this)

            view=this.ProfileSectionView;

            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);


            view.AddProfileButton.DynamicPopupFcn=@(~,~)addProfilePopupList(this);
            view.RemoveProfileButton.DynamicPopupFcn=@(~,~)removeProfilePopupList(this);

            this.AddProfileButtonClickListener=...
            addlistener(view,'AddProfileButtonClick',@this.onAddProfileButtonClick);

            this.RemoveProfileButtonClickListener=...
            addlistener(view,'RemoveProfileButtonClick',@this.onRemoveProfileButtonClick);

        end
    end


    methods(Hidden,Access=protected)
        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end

        function onGenerateReport(this,~,~)
            evolutionTreeListManager=getSubModel(this.AppModel,...
            'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            this.AppController.CustomDialogInterface.generateReport(currentTree);
        end

        function popup=addProfilePopupList(this)
            view=this.ProfileSectionView;
            popup=updateAddProfilePopup(view,getProfiles(this));

        end

        function popup=removeProfilePopupList(this)
            view=this.ProfileSectionView;
            popup=updateRemoveProfilePopup(view,getProfiles(this));

        end

        function profMdls=getProfiles(~)
            profMdls={};
            profs=systemcomposer.internal.profile.Profile.getProfilesInCatalog();
            for prof=profs
                if(~isa(prof,'evolutions.Stereotypes.profile.DesignEvolutionProfile')||prof.isBuiltIn)

                    continue;
                end
                model=mf.zero.getModel(prof);
                profile=systemcomposer.internal.profile.Profile.getProfile(model);
                profMdls{end+1}=profile.getName;%#ok<AGROW>
            end
        end

        function onAddProfileButtonClick(this,~,data)
            profile=data.EventData.ProfileName;

            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            tree=evolutionTreeListManager.CurrentSelected;
            try
                createProgressDialog(this,"Add Profile");
                setAppStatus(this,0.5,"Adding Profile");

                evolutions.internal.stereotypes.addProfileToAllModels(tree,profile);
                closeProgressDialog(this);
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end

            notify(this.EventHandler,'StereotypeChanged');
        end

        function onRemoveProfileButtonClick(this,~,data)
            profile=data.EventData.ProfileName;

            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            tree=evolutionTreeListManager.CurrentSelected;
            try
                createProgressDialog(this,"Remove Profile");
                setAppStatus(this,0.5,"Removing Profile");
                evolutions.internal.stereotypes.removeProfileFromAllModels(tree,profile);
                closeProgressDialog(this);
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end

            notify(this.EventHandler,'StereotypeChanged');
        end

    end
end
