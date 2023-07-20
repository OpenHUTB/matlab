classdef EyeDiagramSystemObjectCfg<matlabshared.scopes.SystemObjectScopeSpecification





    methods

        function this=EyeDiagramSystemObjectCfg(varargin)

            mlock;
            this@matlabshared.scopes.SystemObjectScopeSpecification(varargin{:});
        end

        function b=getShowWaitbar(~)
            b=false;
        end

        function appname=getScopeTag(~)
            appname='Eye Diagram';
        end

        function hiddenExts=getHiddenExtensions(~)

            hiddenExts={'Core:Source UI',...
            'Visuals:User-defined Vector',...
            'Visuals:Frequency Vector',...
            'Visuals:Statistics Vector',...
            'Visuals:Time Vector',...
            'Visuals:Statistics',...
            'Visuals:Video',...
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

        function[mApp,mExample,mAbout]=createHelpMenuItems(~,mHelp)


            if~isempty(ver('comm'))&&builtin('license','test','Communication_Toolbox')

                mapFileLocation=fullfile(docroot,'toolbox','comm','comm.map');

                mApp(1)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_comm.EyeDiagram',...
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:EyeDiagramSystemObjectHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'eyediagramsystemobject'));

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
                'Label',getString(message('shared_comm_msblks_serdes:EyeDiagramVisual:EyeDiagramSystemObjectHelp')),...
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
            end
        end

        function cfgFile=getConfigurationFile(~)
            cfgFile='eyediagramsysobj.cfg';
        end

        function helpArgs=getHelpArgs(this,key)%#ok
            helpArgs=[];
        end





        function b=showKeyboardCommand(~)


            b=false;
        end

        function b=showMessageLog(~)


            b=false;
        end

        function b=showConfiguration(~)
            b=false;
        end

        function b=showPrintAction(~,~)
            b=true;
        end

        function b=isToolbarCompact(~,toolbarName)
            if strcmpi(toolbarName,'autoscale')
                b=true;
            elseif strcmpi(toolbarName,'zoom')
                b=true;
            else
                b=false;
            end
        end

        function renderToolbars(~,~)

        end

        function b=useUIMgr(~)
            b=false;
        end

        function b=useMCOSExtMgr(~)
            b=true;
        end

    end
end


