classdef Setup<handle





    properties(SetObservable=true)
WebSpPkg
InstSpPkg
FilteredSpPkg
PackageInfo
        SelectedPackage=-1;
        SelectedHardware=-1;
        SelectedTableRow=-1;
DownloadDir
InstallDir
Installer
Steps
CurrentStep
Explorer
IMME
EventDispatcher
FwUpdater
ProgressBar
        SkipInstall=false
listener
MWALogin
        IsUSRPWorkflow=false
        InstallerWorkflow=hwconnectinstaller.internal.InstallerWorkflow.InstallFromInternet;
        ExecuteTaskItem=[];
        SPIEntryPoint=''
    end

    properties(Transient,Access=private)
        InternetIsAccessible=[]
    end

    properties(Constant,Access=private)
        WEBACCESS_TIMEOUT_SECONDS=10
    end

    properties
Labels
    end

    properties(SetAccess=immutable,GetAccess=public)
UsageLogger
    end


    methods(Access='protected')
        function h=Setup
            h.getMessages();
            h.Installer=hwconnectinstaller.PackageInstaller();
            h.FwUpdater=hwconnectinstaller.FirmwareUpdater();
            h.MWALogin=hwconnectinstaller.internal.MWAccountLogin();
            h.UsageLogger=hwconnectinstaller.internal.UsageLogger();
            h.Installer.setUsageLogger(h.UsageLogger);
            h.InstallerWorkflow=hwconnectinstaller.internal.InstallerWorkflow.InstallFromInternet;
        end
    end


    methods(Access='public',Static)
        function h=get(varargin)
            h=[];



            daRoot=DAStudio.Root;
            openEx=daRoot.find('-isa','DAStudio.Explorer');
            found=false;
            if(~isempty(openEx))
                for i=1:numel(openEx)
                    src=openEx(i).getRoot();
                    if(~isempty(src)&&isa(src,'hwconnectinstaller.Setup'))
                        found=true;
                        h=src;
                        break;
                    end
                end
            end
            if(found)

            else
                h=hwconnectinstaller.Setup();
            end
        end
    end



    methods(Access='public')

        function label=getTitle(h)
            label=h.Labels.Title;
        end

        function label=getTreeTitle(h)
            label=h.Labels.TreeTitle;
        end



        function setExplorer(h,ex)
            h.Explorer=ex;
            h.IMME=DAStudio.imExplorer(h.Explorer);
            h.refreshParentAndProxy();
            h.Steps.initializeCustomData();
            h.CurrentStep=h.Steps;
        end


        function refreshParentAndProxy(h)
            RootProxy=h.Explorer.getRoot;
            h.Steps.refreshParentAndProxy(h,RootProxy);
        end

        function jumpToStep(h,stepHierarchy)

            curStep=h.Steps;
            for i=1:numel(stepHierarchy)
                curStep=curStep.getChildByID(stepHierarchy{i});
            end
            h.CurrentStep=curStep;
            h.IMME.selectTreeViewNode(curStep.Proxy);
        end

        function setNextStep(h,hStep,me)%#ok




            stepSelectable=true;
            if(isprop(hStep,'Selectable'))
                stepSelectable=hStep.Selectable;
            end


            if(h.CurrentStep~=hStep)
                if((~h.CurrentStep.Selectable)||(~stepSelectable))
                    h.IMME.selectTreeViewNode(h.CurrentStep.Proxy);
                    return;
                else
                    if(isa(hStep,'hwconnectinstaller.Step'))
                        h.CurrentStep=hStep;
                    else
                        h.CurrentStep=h.Steps;
                    end
                end
            end
            if(isprop(hStep,'AutoNext')&&(hStep.AutoNext))
                hStep.next([hStep.ID,'_Step_Next']);
            end
        end


        function mb=canMoveBack(h,hStep)
            mb=true;
            if(isequal(hStep.Parent,h)||isa(hStep.Parent,'hwconnectinstaller.Setup'))
                mb=false;
            end

        end


        function back(h,hStep,arg)





            if(~isempty(arg))
                previousStep=arg;
            else
                previousStep=hStep.Parent;
            end
            h.CurrentStep=previousStep;
            h.Explorer.show;
            h.IMME.selectTreeViewNode(arg.Proxy);
        end


        function next(h,hStep,arg)




            if(~isempty(arg))
                nextStep=arg;
            else
                nextStep=hStep.getNextSibling();
            end
            h.CurrentStep=nextStep;
            h.Explorer.show;
            h.IMME.selectTreeViewNode(nextStep.Proxy);

        end

        function okToReset=isUIResetAllowed(h)



            okToReset=~isempty(h.IMME)&&~h.IMME.isSleeping;
        end

        function freezeExplorer(h)
            if~isempty(h.Explorer)
                if(~isempty(h.CurrentStep))
                    h.CurrentStep.setEnableWidgets(h.IMME.getDialogHandle(),0);
                end
                h.EventDispatcher=DAStudio.EventDispatcher;
                h.EventDispatcher.broadcastEvent('MESleep');
            end
        end

        function unfreezeExplorer(h)
            if(~isempty(h.Explorer)&&~isempty(h.EventDispatcher))
                h.EventDispatcher.broadcastEvent('MEWake');
                if(~isempty(h.CurrentStep))
                    h.CurrentStep.setEnableWidgets(h.IMME.getDialogHandle(),1);
                end
            end
        end

        function finish(h,~)
            if isvalid(h)&&~isempty(h.Explorer)
                h.Explorer.delete;
            end
            if isvalid(h)
                h.FwUpdater.release;
            end
        end

        function addSteps(h,ParentStep,Children)
            ParentStep.Children=Children;
            h.refreshParentAndProxy();
            ParentStep.initializeCustomData();
            assert(~isempty(h.EventDispatcher));
            h.EventDispatcher.broadcastEvent('HierarchyChangedEvent',h.Explorer.getRoot);
        end


        function displayLabel=getDisplayLabel(h)
            displayLabel=h.Steps.Label;
        end

        function val=getDisplayIcon(h)%#ok
            val='toolbox/simulink/simulink/modeladvisor/private/icon_folder.png';
        end

        function haschld=hasChildren(h)
            haschld=~isempty(h.Steps)&&h.Steps.hasChildren();
        end

        function y=isHierarchical(h)%#ok
            y=true;
        end

        function y=getHierarchicalChildren(h)
            y=h.Steps.getHierarchicalChildren();
        end

        function y=getChildren(h)
            y=h.Steps.getChildren();
        end



        function dialogCallback(h,arg)
            h.Steps.dialogCallback(arg);
        end

        function dlgstruct=getDialogSchema(h,varargin)
            dlgstruct=h.Steps.getDialogSchema(varargin{:});
        end

        function showProgressBar(h,title,message,initial,~)
            if~hwconnectinstaller.internal.isProductInstalled('Simulink')
                if(isempty(h.ProgressBar))
                    h.ProgressBar=waitbar(0,'Please wait ...','Name',title);
                end

                if~isempty(message)


                    delete(h.ProgressBar);
                    h.ProgressBar=waitbar(initial,message,'Name',title);
                end
                return;
            end


            if isempty(h.ProgressBar)




                h.ProgressBar=DAStudio.WaitBar;
                h.ProgressBar.setWindowTitle('Progress Bar');
                h.ProgressBar.setWindowIcon(fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabIcon_32.png'));
                h.ProgressBar.show();
            end

            h.ProgressBar.setWindowTitle(title);
            if(~isempty(h.Explorer))

                p=h.Explorer.position;

                x=round(p(1)+p(3)/2);
                y=round(p(2)+p(4)/2);

                h.ProgressBar.centreOnLocation(x,y);
            end
            h.setProgressBarValue(message,initial,1);
        end



        function vis=isProgressBarVisible(h)
            if~hwconnectinstaller.internal.isProductInstalled('Simulink')
                vis=false;
                return;
            end
            assert(~isempty(h.ProgressBar));
            vis=h.ProgressBar.isVisible();
        end




        function setProgressBarValue(h,message,value,varargin)
            if~hwconnectinstaller.internal.isProductInstalled('Simulink')
                if isempty(message)
                    waitbar(value,h.ProgressBar);
                else
                    waitbar(value,h.ProgressBar,message);
                end
            else
                assert(~isempty(h.ProgressBar));
                if(nargin<4&&~h.isProgressBarVisible())

                    error('hwconnectinstaller:setup:Cancel',DAStudio.message('hwconnectinstaller:setup:cancel'));
                end
                if(value<0)
                    h.ProgressBar.setCircularProgressBar(true);
                else
                    h.ProgressBar.setCircularProgressBar(false);
                    h.ProgressBar.setValue(value);
                end
                if(~isempty(message))
                    h.ProgressBar.setLabelText(message);
                end
            end
        end


        function closeProgressBar(h)
            if~isvalid(h)||isempty(h.ProgressBar)
                return;
            end
            if~hwconnectinstaller.internal.isProductInstalled('Simulink')
                close(h.ProgressBar);
            end
            h.ProgressBar=[];
        end


        function installer=getInstaller(h)
            installer=h.Installer;
        end

        function getMessages(h)
            labels=struct(...
            'Title','',...
            'Help','',...
            'Close','',...
            'TreeTitle','');
            h.Labels=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','setup',labels);
        end

        function out=isInstallFromInternet(hSetup)

            out=isempty(hSetup.DownloadDir);
        end

    end


end



