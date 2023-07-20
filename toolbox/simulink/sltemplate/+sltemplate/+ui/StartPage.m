classdef StartPage<handle






    properties(Access=private)
        Channel;
        Controller;
        Listeners;
        DialogTitle;
        DialogDimensions;
        ServerReady;
        ClientReady;
        FeaturedExampleRegistrar;
        HistoryChangeSubscriber;
        HistoryChangePublisher;
    end

    methods(Access=private)

        function obj=StartPage(varargin)









            p=inputParser;
            p.KeepUnmatched=true;
            p.parse(varargin{:});


            sltemplate.internal.Registrar.warmupCache();

            obj.Channel='/sltemplate/GalleryView/All/';

            obj.HistoryChangeSubscriber=slhistoryChangeSubscriber(obj.Channel);
            obj.HistoryChangePublisher=slhistoryChangePublisher(obj.Channel);

            obj.Controller=sltemplate.internal.GalleryController(obj.Channel,varargin{:});

            obj.ClientReady=false;
            obj.Listeners{end+1}=obj.Controller.addlistener('ClientReady',...
            @(varargin)obj.setClientReady(varargin));

            obj.ServerReady=true;
        end

        function setClientReady(varargin)
            obj=varargin{1};
            obj.ClientReady=true;
        end

        function runOnReady(obj,onReadyFunction)
            if obj.ClientReady
                onReadyFunction();
            else
                obj.Controller.runOnceAfterReady(onReadyFunction);
            end
        end

        function showView(obj,viewId,value)
            doViewCustomization=@(varargin)obj.Controller.customizeView(viewId,value);
            obj.runOnReady(doViewCustomization);
        end

    end

    methods(Access=public,Static=true)
        function showCustomView(viewId,value,varargin)
            sltemplate.ui.StartPage.doShow(varargin{:});
            startpage=sltemplate.ui.StartPage.getInstance();
            startpage.showView(viewId,value);
        end

        function openTemplate(templateFilePath,varargin)
            sltemplate.ui.StartPage.doShow(varargin{:});
            startpage=sltemplate.ui.StartPage.getInstance();
            openFunction=@(varargin)startpage.Controller.openTemplate(templateFilePath);
            startpage.runOnReady(openFunction);
        end

        function show(varargin)
            f=@()sltemplate.ui.StartPage.showCustomView('Start',[],varargin{:});
            sltemplate.ui.StartPage.showWithFallback(f,@slLibraryBrowser);
            sltemplate.internal.updateLearnSection();
        end

        function hide(varargin)
            if sltemplate.ui.StartPage.isServerReady()
                startpage=sltemplate.ui.StartPage.getInstance();
                startpage.Controller.hideDialog();
            end
        end

        function close(varargin)
            if sltemplate.ui.StartPage.isServerReady()
                startpage=sltemplate.ui.StartPage.getInstance();
                startpage.Controller.closeDialog();
                sltemplate.ui.StartPage.clearInstance();
            end
        end

        function refresh(varargin)
            sltemplate.ui.StartPage.clearInstance();
            sltemplate.ui.StartPage.show();
        end

        function visible=isVisible()
            open=sltemplate.ui.StartPage.isOpen();

            if~open
                visible=open;
                return;
            end

            startpage=sltemplate.ui.StartPage.getInstance();
            visible=startpage.Controller.isClientVisible();
        end

        function open=isOpen()
            open=sltemplate.ui.StartPage.serverReady()&&sltemplate.ui.StartPage.clientReady();
        end

        function serverReady=isServerReady()
            serverReady=sltemplate.ui.StartPage.serverReady();
        end

        function clientReady=isClientReady()
            clientReady=sltemplate.ui.StartPage.clientReady();
        end

        function setDefaultModelTemplate(filePath)


            if sltemplate.ui.StartPage.isServerReady()
                startpage=sltemplate.ui.StartPage.getInstance();
                startpage.Controller.broadcast('SetDefaultModelTemplate',filePath);
            end
        end

        function newSimulinkModelView(varargin)
            f=@()sltemplate.ui.StartPage.showCustomView('NewModel',[],varargin{:});
            sltemplate.ui.StartPage.showWithFallback(f,@()open_system(new_system));
        end

        function newSimulinkProjectView(varargin)
            sltemplate.ui.StartPage.newTypeView("Project",@simulinkproject);
        end

        function newStateflowChartView(varargin)
            Stateflow.App.Studio.CreateNewSFXWithUserName;
        end
        function newStateflowSFView(varargin)
            if~sf('License','basic')




                sfnew;
            else
                sltemplate.ui.StartPage.newGroupView("Stateflow",@sfnew);
            end
        end

        function newSimulinkLibraryView(varargin)
            sltemplate.ui.StartPage.newTypeView("Library",@()open_system(new_system('','library')));
        end

        function newSimulinkSubsystemView(varargin)
            sltemplate.ui.StartPage.newTypeView("Subsystem",@()open_system(new_system('','Subsystem')));
        end

        function newArchitectureModelView(varargin)
            sltemplate.ui.StartPage.newTypeView("Architecture",@()open_system(new_system('','Architecture')));
        end

        function newSystemComposerModelView(varargin)
            sltemplate.ui.StartPage.newGroupView("System Composer",@()open_system(new_system('','Architecture')));
        end

        function newAUTOSARComponentModelView(varargin)
            sltemplate.ui.StartPage.newGroupView(...
            "AUTOSAR Blockset",...
            @()sltemplate.ui.StartPage.createNewAUTOSARComponentModel());
        end

        function newAUTOSARCompositionModelView(varargin)
            sltemplate.ui.StartPage.newGroupView(...
            "AUTOSAR Blockset",...
            @()sltemplate.ui.StartPage.createNewAUTOSARCompositionModel());
        end

        function newGroupView(group,fallbackFcn,varargin)
            f=@()sltemplate.ui.StartPage.showCustomView('ExpandedGroup',group,varargin{:});
            sltemplate.ui.StartPage.showWithFallback(f,fallbackFcn);
        end

        function newTypeView(type,fallbackFcn,varargin)
            f=@()sltemplate.ui.StartPage.showCustomView('FilteredByType',type,varargin{:});
            sltemplate.ui.StartPage.showWithFallback(f,fallbackFcn);
        end
    end


    methods(Access=public,Static=true,Hidden=true)

        function url=getURL()
            url='';

            if sltemplate.ui.StartPage.isOpen()
                startpage=sltemplate.ui.StartPage.getInstance();
                url=startpage.Controller.getURL();
            end
        end

        function showControlsCourse(show)
            startpage=sltemplate.ui.StartPage.getInstance();
            startpage.Controller.broadcast('ShowControlsCourse',show);
        end

        function showSimscapeCourse(show)
            startpage=sltemplate.ui.StartPage.getInstance();
            startpage.Controller.broadcast('ShowSimscapeCourse',show);
        end

    end

    methods(Access=private,Static=true)
        function theStartPage=getInstance(varargin)
            function theStartPage=acquireDialog(theStartPage)
                if~sltemplate.ui.StartPage.serverReady()
                    connector.ensureServiceOn;
                    theStartPage=sltemplate.ui.StartPage(varargin{:});
                end
            end

            theStartPage=sltemplate.ui.StartPage.instance(@acquireDialog);
        end

        function clearInstance(varargin)
            function theStartPage=destroyDialog(theStartPage)
                if sltemplate.ui.StartPage.serverReady()
                    cellfun(@(lh)delete(lh),theStartPage.Listeners,'UniformOutput',false);
                    theStartPage.Controller.unsubscribeAll();
                    theStartPage=[];
                end
            end

            sltemplate.ui.StartPage.instance(@destroyDialog);
        end

        function flag=serverReady()

            startpage=sltemplate.ui.StartPage.instance(@(g)(g));
            flag=~isempty(startpage)&&isvalid(startpage)&&startpage.ServerReady;
        end

        function flag=clientReady()

            startpage=sltemplate.ui.StartPage.instance(@(g)(g));
            flag=~isempty(startpage)&&isvalid(startpage)&&startpage.ClientReady;
        end

        function startpage=instance(dialogOperator)
            persistent theStartPage;
            mlock;
            theStartPage=dialogOperator(theStartPage);
            startpage=theStartPage;
        end

        function waitbar=getWaitBar()
            waitbar=DAStudio.WaitBar();
            waitbar.setMinimum(0);
            waitbar.setMaximum(0);
            waitbar.setLabelText(DAStudio.message('sltemplate:Gallery:InitializingLabel'));
            waitbar.setWindowIcon(sltemplate.internal.Constants.getDialogIcon());
            waitbar.progressCanceledCB(@sltemplate.ui.StartPage.clearInstance);
            waitbar.setWindowTitle(DAStudio.message('sltemplate:Gallery:StartPageHeading'));
            waitbar.show();
        end

        function doShow(varargin)
            if sltemplate.ui.StartPage.isServerReady()
                startpage=sltemplate.ui.StartPage.getInstance(varargin{:});
                startpage.Controller.showDialog();
            else

                waitbar=sltemplate.ui.StartPage.getWaitBar();
                startpage=sltemplate.ui.StartPage.getInstance(varargin{:});

                if waitbar.wasCanceled()
                    sltemplate.ui.StartPage.close();
                else
                    startpage.Controller.showDialog(false);
                end
            end
        end

        function showWithFallback(showFcn,fallbackFcn)
            if~sltemplate.internal.utils.isStartPageAvailable()
                sltemplate.internal.utils.logDDUX("ShowWithFallback");
                fallbackFcn();
            else

                try
                    sltemplate.internal.utils.logDDUX("Show");
                    showFcn();
                catch E
                    sltemplate.internal.utils.logDDUX("ErrorShowWithFallback");
                    warning(E.identifier,'%s',E.getReport);
                    fallbackFcn();
                end
            end
        end

        function createNewAUTOSARComponentModel()


            open_system(Simulink.createFromTemplate('autosar_classic_model.sltx'));
        end

        function createNewAUTOSARCompositionModel()


            open_system(Simulink.createFromTemplate('autosar_composition_model.sltx'));
        end

    end

end
