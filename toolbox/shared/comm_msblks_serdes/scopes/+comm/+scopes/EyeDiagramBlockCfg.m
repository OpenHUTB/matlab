classdef EyeDiagramBlockCfg<Simulink.scopes.ScopeBlockSpecification




    properties
        executedStartFcn=false;
        executedMdlStart=false;
        loadedLines=false;
    end

    properties(Access=private,Transient)
FileMenuOpeningListener
    end

    methods
        function this=EyeDiagramBlockCfg(varargin)



            mlock;

            this@Simulink.scopes.ScopeBlockSpecification(varargin{:});
        end

        function hCopy=copy(this)
            hCopy=copy@Simulink.scopes.ScopeBlockSpecification(this);
            hCopy.OpenAtMdlStart=this.OpenAtMdlStart;
        end

        function openAtMdlStart=getOpenAtMdlStart(this)
            openAtMdlStart=this.OpenAtMdlStart;
        end

        function b=getNeedRuntimeCallbacks(~)

            b=false;
        end

        function setBlockParams(this,varargin)
            if nargin>1
                setBlockParam(this.Scope,varargin{:});
            end
        end

        function setScopeParams(~)

        end

        function appName=getScopeTag(~)

            appName='Eye Diagram';
        end

        function hTypes=getHiddenTypes(~)
            hTypes={'Sources'};
        end

        function hiddenExts=getHiddenExtensions(~)


            hiddenExts={'Core:Source UI',...
            'Visuals',...
            'Tools:Instrumentation Sets',...
            'Tools:Image Tool',...
            'Tools:Pixel Region',...
            'Tools:Image Navigation Tools',...
            };
        end

        function measurementTags=getSupportedMeasurements(~)
            measurementTags={'eyemeasurements'};
        end

        function measurementPrefs=getMeasurementPreferences(~)
            measurementPrefs.TraceSelectionEnabled=false;
        end

        function mdlStart(this)
            this.executedMdlStart=true;
            startFcn(this);
        end

        function b=showConfiguration(~)
            b=false;
        end

        function onScopeLaunched(this)

            hFrameWork=this.Scope.Framework;
            if isempty(hFrameWork)
                return;
            end

            hVisual=hFrameWork.Visual;
            if isempty(hVisual)
                return;
            end

            if~this.executedStartFcn&&this.executedMdlStart
                startFcn(this);
            end
        end

        function mdlTerminate(this)
            this.executedStartFcn=false;
            this.executedMdlStart=false;

        end

        function renderMenus(this,hScope)

            this.FileMenuOpeningListener=addlistener(hScope,'FileMenuOpening',@this.onFileMenuOpening);
        end

        function onFileMenuOpening(this,hScope,~)




            hFileMenu=findobj(this.Scope.Framework.Parent,'Tag','uimgr.uimenugroup_File');
            hOpen=findobj(hFileMenu,'Tag','uimgr.spctogglemenu_OpenAtMdlStart');

            if isempty(hOpen)

                hOpen=uimenu('Parent',hFileMenu,...
                'Tag','uimgr.spctogglemenu_OpenAtMdlStart',...
                'Position',1,...
                'Label',getString(message('Spcuilib:scopes:OpenAtMdlStart')),...
                'Callback',@(h,ev)toggleOpenAtMdlStart(this));
            end

            isStopped=strcmp(get(bdroot(this.Block.Handle),'SimulationStatus'),'stopped');
            set(hOpen,'Enable',uiservices.logicalToOnOff(isStopped));
            set(hOpen,'Checked',uiservices.logicalToOnOff(this.OpenAtMdlStart));
        end

        function[mApp,mExample,mAbout]=createHelpMenuItems(~,mHelp)


            if~isempty(ver('comm'))&&builtin('license','test','Communication_Toolbox')

                mapFileLocation=fullfile(docroot,'toolbox','comm','comm.map');

                mApp(1)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_comm.EyeDiagram',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:EyeDiagramBlockHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'eye_diagram'));

                mApp(2)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Communications Toolbox',...
                'Label',getString(message('comm:shared:CommSystemToolboxHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'comm_ref'));

                mExample=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Communications Toolbox Demos',...
                'Label',getString(message('comm:shared:CommSystemToolboxDemos')),...
                'Callback',@(hco,ev)demo('toolbox','comm'));

                mAbout=uimenu(mHelp,...
                'Tag','uimgr.uimenu_About',...
                'Label',getString(message('comm:ConstellationDiagram:AboutCommSystemToolbox')),...
                'Callback',@(hco,ev)aboutcommsystbx);

            elseif~isempty(ver('serdes'))&&builtin('license','test','SerDes_Toolbox')

                mapFileLocation=fullfile(docroot,'toolbox','serdes','helptargets.map');

                mApp(1)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_comm.EyeDiagramSerdes',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:EyeDiagramBlockHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'eye_diagram'));

                mApp(2)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_SerDes Toolbox',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:SerdesToolboxHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'serdes_ref'));

                mExample=uimenu(mHelp,...
                'Tag','uimgr.uimenu_SerDes Toolbox Demos',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:SerdesToolboxDemos')),...
                'Callback',@(hco,ev)demo('toolbox','serdes'));

                mAbout=uimenu(mHelp,...
                'Tag','uimgr.uimenu_About SerDes Toolbox',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:AboutSerdesToolbox')),...
                'Callback',@(hco,ev)aboutserdestbx);

            elseif~isempty(ver('msblks'))&&builtin('license','test','Mixed_Signal_Blockset')

                mapFileLocation=fullfile(docroot,'toolbox','msblks','helptargets.map');

                mApp(1)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_comm.EyeDiagramMsblks',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:EyeDiagramBlockHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'eye_diagram'));

                mApp(2)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Mixed-Signal Blockset',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:MixedSignalBlocksetHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'msblks_ref'));

                mExample=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Mixed-Signal Blockset Demos',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:MixedSignalBlocksetDemos')),...
                'Callback',@(hco,ev)demo('toolbox','msblks'));

                mAbout=uimenu(mHelp,...
                'Tag','uimgr.uimenu_About Mixed-Signal Blockset',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:AboutMixedSignalBlockset')),...
                'Callback',@(hco,ev)aboutmsblks);
            end
        end

        function cfgFile=getConfigurationFile(~)
            cfgFile='eyediagramblock.cfg';
        end

        function helpArgs=getHelpArgs(~,~)
            helpArgs={};
        end

        function configClass=getConfigurationClass(~)


            configClass='matlabshared.scopes.EyeDiagramConfiguration';
        end

        function startFcn(this)

            hFrameWork=this.Scope.Framework;
            if~isempty(hFrameWork)

                this.executedStartFcn=true;

                hVisual=hFrameWork.Visual;
                if~isempty(hVisual)

                    if~this.loadedLines

                        loadLineProperties(hVisual);
                        this.loadedLines=true;
                    end

                    hVisual.onSourceRun;
                end
            end
        end

        function b=showKeyboardCommand(~)


            b=false;
        end

        function b=showMessageLog(~)


            b=false;
        end

        function b=showPrintAction(~,~)
            b=true;
        end

        function b=shouldShowPlaybackToolbar(~)
            b=false;
        end

        function out=shouldShowControls(~,controlType)


            if any(strcmp(controlType,{'PlaybackMenu','TimeStatus'}))
                out=true;
            else
                out=false;
            end
        end

        function b=isToolbarCompact(~,toolbarName)
            if any(strcmpi(toolbarName,{'zoom','playbackmodes'}))

                b=true;
            else
                b=false;
            end
        end
    end

    methods(Access=protected)


        function retVal=getDefaultConfigParams(this)

            persistent defaultConfigParams;

            if isempty(defaultConfigParams)
                defaultConfigParams=extmgr.ConfigurationSet.createAndLoad(this.getConfigurationFile);
            end

            retVal=defaultConfigParams;
        end

        function defOpen=getDefaultOpenAtMdlStart(~)
            defOpen=true;

        end

    end

    methods(Static,Hidden)

        function this=loadobj(s)

            this=loadobj@Simulink.scopes.ScopeBlockSpecification(s);

            if isempty(this.CurrentConfiguration)
                return;

            end
            cfg=this.CurrentConfiguration.findConfig('Core','Source UI');
            if isempty(cfg)
                return;
            end
            if isempty(cfg.PropertyDb)
                return;
            end
            prop=cfg.PropertyDb.findProp('ShowPlaybackCmdMode');
            if isempty(prop)
                return;
            end
            prop.Value=false;
        end

        function b=useMCOSExtMgr(~)
            b=true;
        end

        function b=useUIMgr(~)
            b=false;
        end
    end
end


function toggleOpenAtMdlStart(this)

    this.OpenAtMdlStart=~this.OpenAtMdlStart;

    set(bdroot(this.Block.handle),'dirty','on');

end


