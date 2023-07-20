classdef TimeScopeBlockCfg<Simulink.scopes.TimeScopeBlockCfg




    methods

        function this=TimeScopeBlockCfg(varargin)



            mlock;

            this@Simulink.scopes.TimeScopeBlockCfg(varargin{:});
        end

        function cfgFile=getConfigurationFile(~)
            cfgFile='timescope.cfg';
        end

        function measurementTags=getSupportedMeasurements(~)
            measurementTags={'triggers','tcursors','signalstats','peaks','bilevel'};
        end

        function appName=getScopeTag(~)

            appName='Time Scope';
        end

        function[success,errMessage]=checkMeasurementLicense(~,~)

            if~isempty(ver('dsp'))
                [success,errMessage]=builtin('license','checkout','Signal_Blocks');
                if success
                    return
                end
            end
            if~isempty(ver('simscape'))&&builtin('license','test','Simscape')
                [success,errMessage]=builtin('license','checkout','Simscape');
            end
        end

        function[mApp,mExample,mAbout]=createHelpMenuItems(this,mHelp)

            mapFileLocation=fullfile(docroot,'toolbox','dsp','dsp.map');
            if isempty(ver('dsp'))

                [mApp,mExample,mAbout]=createHelpMenuItems@...
                Simulink.scopes.TimeScopeBlockCfg(this,mHelp);
                return;
            end
            mApp(1)=uimenu(mHelp,...
            'Tag','uimgr.uimenu_Time Scope',...
            'Label',getString(message('Spcuilib:scopes:TimeScopeBlockHelp')),...
            'Callback',uiservices.makeCallback(@helpview,mapFileLocation,'dsptimescope'));

            mApp(2)=uimenu(mHelp,...
            'Tag','uimgr.uimenu_DSP System Toolbox',...
            'Label',getString(message('Spcuilib:scopes:DSPSystemToolboxHelp')),...
            'Callback',uiservices.makeCallback(@helpview,mapFileLocation,'dspinfo'));




            mExample=uimenu(mHelp,...
            'Tag','uimgr.uimenu_DSP System Toolbox Demos',...
            'Label',getString(message('Spcuilib:scopes:DSPSystemToolboxDemos')),...
            'Callback','demo(''toolbox'',''dsp'')');



            mAbout=uimenu(mHelp,...
            'Tag','uimgr.uimenu_About',...
            'Label',getString(message('Spcuilib:scopes:AboutDSPSystemToolbox')),...
            'Callback',uiservices.makeCallback(@aboutdspsystbx));
        end

        function renderToolbars(~,~)

        end
    end
    methods(Access=protected)

        function defOpen=getDefaultOpenAtMdlStart(~)
            defOpen=true;
        end
    end
end


