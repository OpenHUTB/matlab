classdef ImageRegistration<handle



    properties(Access=private)

RegistrationModel
RegistrationController

    end

    properties(GetAccess=?uitest.factory.Tester)
RegistrationView
    end

    methods

        function self=ImageRegistration(varargin)

            import images.internal.app.registration.ui.*;

            self.RegistrationView=images.internal.app.registration.ui.View();
            self.RegistrationModel=images.internal.app.registration.model.Session();
            self.RegistrationController=images.internal.app.registration.Controller(self.RegistrationModel,self.RegistrationView);

            if self.RegistrationView.App.State~=matlab.ui.container.internal.appcontainer.AppState.RUNNING
                waitfor(self.RegistrationView.App,'State');
            end

            if~isvalid(self.RegistrationView.App)||self.RegistrationView.App.State==matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                return;
            end

            drawnow;
            showAsBusy(self.RegistrationView)
            drawnow;


            addlistener(self.RegistrationView.DocumentArea,'figureDeleted',@(~,~)self.deleteApp());

            try
                if nargin>0
                    moving=varargin{1};
                    fixed=varargin{2};

                    [fixed,moving,isFixedRGB,isMovingRGB,isFixedNormalized,isMovingNormalized,RGBImage]=...
                    preprocessImageDialog(fixed,moving,false,self.RegistrationView.DocumentArea.hRegisteredFig);

                    self.RegistrationModel.startSession('fixedImage',fixed,'movingImage',moving,...
                    'fixedReferencingObject',imref2d(size(fixed)),...
                    'movingReferencingObject',imref2d(size(moving)),...
                    'isFixedRGB',isFixedRGB,'isMovingRGB',isMovingRGB,...
                    'isFixedNormalized',isFixedNormalized,...
                    'isMovingNormalized',isMovingNormalized,...
                    'movingRGBImage',RGBImage);
                    self.RegistrationView.App.Title=[images.internal.app.registration.ui.getMessageString('appName'),' - ',varargin{3},' (',getMessageString('movingImage'),') & ',...
                    varargin{4},' (',getMessageString('fixedImage'),')'];
                    isBinary=islogical(fixed)||islogical(moving);
                    if isBinary
                        self.RegistrationView.RegistrationTab.enableBinaryButtons();
                    else
                        self.RegistrationView.RegistrationTab.enableAllButtons();
                    end
                    setImageSize(self.RegistrationView,fixed,moving);

                    self.RegistrationView.DocumentArea.hDataBrowser.SelectedIndex=3;

                else
                    self.RegistrationView.StatusBar.setStatus(getMessageString('clickNewSessionMessage'));
                end

                imageslib.internal.apputil.manageToolInstances('add','imageRegistration',self.RegistrationView);
                addlistener(self.RegistrationView.App,'ObjectBeingDestroyed',@(~,~)deleteApp(self));
            catch

            end

            if~isvalid(self.RegistrationView.App)
                return;
            end

            unshowAsBusy(self.RegistrationView);

            wireUpSizeChangedCallback(self.RegistrationView.DocumentArea);

            drawnow;
            controlPanelSizeChange(self.RegistrationView.DocumentArea);
            drawnow;

            self.RegistrationView.App.CanCloseFcn=@(~)canTheAppClose(self);

            if self.RegistrationView.CloseRequested
                close(self.RegistrationView.App);
            end

        end

        function TF=canTheAppClose(self)
            deleteApp(self);
            TF=true;
        end

        function deleteApp(self)


            if~isvalid(self)
                return;
            end

            self.RegistrationView.DocumentArea.hScrollPanel.deleteFlickerTimer();
            self.RegistrationView.RegistrationTab.deleteGallery();

            set(self.RegistrationView.DocumentArea.hRegisteredFig,'DeleteFcn',[]);
            set(self.RegistrationView.DocumentArea.hRegisteredFig,'SizeChangedFcn',[]);
            set(self.RegistrationView.DocumentArea.hRightPanel.Figure,'SizeChangedFcn',[]);
            imageslib.internal.apputil.manageToolInstances('remove','imageRegistration',self.RegistrationView);
            delete(self.RegistrationController);
            delete(self.RegistrationModel);
            delete(self);
        end

    end


    methods

        function settingsData=getSettingsData(self)
            settingsData=self.RegistrationModel.gatherSettingsData(true);
        end
        function matchedFeatureArray=getMatchedFeatures(self)
            matchedFeatureArray={self.RegistrationModel.currentAlignment.rigidOperation.fixedMatchedPoints,...
            self.RegistrationModel.currentAlignment.rigidOperation.movingMatchedPoints};
        end
    end

    methods(Static)
        function deleteAllTools(~)
            imageslib.internal.apputil.manageToolInstances('deleteAll','imageRegistration');
        end
    end

end
