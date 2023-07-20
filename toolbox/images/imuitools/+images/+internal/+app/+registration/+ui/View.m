classdef View<handle





    properties(Access={
        ?uitest.factory.Tester,...
        ?images.internal.app.registration.Controller,...
        ?images.internal.app.registration.ImageRegistration})


App


RegistrationTab


DocumentArea


StatusBar

        CloseRequested(1,1)logical=false;

    end

    methods

        function tool=View()

            import matlab.ui.internal.toolstrip.TabGroup;
            import matlab.ui.internal.toolstrip.Tab;
            import images.internal.app.registration.ui.*;


            appOptions.Title=getMessageString('appName');
            appOptions.Tag="RegistrationEstimator"+"_"+matlab.lang.internal.uuid;
            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Image Processing Toolbox";
            appOptions.Scope="Registration Estimator";
            appOptions.CanCloseFcn=@(~)blockAppFromClosing(tool);
            tool.App=matlab.ui.container.internal.AppContainer(appOptions);

            helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            addlistener(helpButton,'ButtonPushed',@(~,~)doc('registrationEstimator'));

            tabGroup=TabGroup();
            tabGroup.Tag="ResgistrationTabGroup";
            tool.RegistrationTab=images.internal.app.registration.ui.RegistrationTab(getMessageString('registration'));
            tabGroup.add(tool.RegistrationTab.thisTab);

            tool.App.addTabGroup(tabGroup);


            tool.DocumentArea=images.internal.app.registration.ui.DocumentArea(tool.App);


            tool.StatusBar=images.internal.app.utilities.StatusBar;
            tool.App.add(tool.StatusBar.Bar);


            tool.DocumentArea.setupControlPanel();


            tool.App.Visible=true;

        end

        function showAsBusy(tool)
            tool.App.Busy=true;
            tool.StatusBar.setStatus(...
            images.internal.app.registration.ui.getMessageString('busy'));
        end

        function setStatusBar(tool,text)
            tool.StatusBar.setStatus(text);
        end

        function unshowAsBusy(tool)

            drawnow;
            tool.App.Busy=false;
        end

        function TF=blockAppFromClosing(self)
            TF=false;
            self.CloseRequested=true;
        end

        function TG=getToolGroup(tool)
            TG=tool.App;
        end

        function setImageSize(tool,fixed,moving)

            minSize=min([size(fixed,1,2),size(moving,1,2)]);

            if minSize>63
                setMinImageSize(tool.DocumentArea.hORBPanel,minSize);
                enableORB(tool.RegistrationTab);
            else
                disableORB(tool.RegistrationTab);
            end

        end

        function throwError(tool,msg,title)

            uialert(tool.DocumentArea.hRegisteredFig,msg,title);

        end

        function delete(tool)
            if~isempty(tool.App)&&isvalid(tool.App)
                close(tool.App);
            end
        end

    end

end
