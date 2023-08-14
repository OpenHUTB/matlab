classdef ScenarioViewerSpecification<matlabshared.scopes.SystemObjectScopeSpecification



    properties
AppName
    end
    methods
        function obj=ScenarioViewerSpecification(varargin)

            obj@matlabshared.scopes.SystemObjectScopeSpecification(varargin{:});
        end

        function b=useMCOSExtMgr(~)
            b=true;
        end




        function crFcn=getCloseRequestFcn(~,hScope)
            crFcn=@(~,~)closeSV(hScope);

        end

        function b=useUIMgr(~)
            b=false;
        end
        function b=showCloseAll(~)
            b=false;
        end
        function b=showConfiguration(~)
            b=false;
        end
        function b=allowsAsynchronous(~)
            b=false;
        end

        function b=showBringAllForward(~)
            b=false;
        end
        function b=showKeyboardCommand(~)
            b=false;
        end










        function cfgFile=getConfigurationFile(~)
            cfgFile=fullfile(matlabroot,'toolbox','phased','phased','+phased','+scopes','scenarioviewer.cfg');
        end

        function helpArgs=getHelpArgs(~,varargin)
            helpArgs=[];
        end

        function appName=getScopeTag(this)
            appName=this.AppName;
        end
        function[mApp,mExample,mAbout]=createHelpMenuItems(~,mHelp)


            mapFileLocation=fullfile(docroot,'toolbox','phased','helptargets.map');

            mApp(1)=uimenu(mHelp,...
            'Tag','uimgr.uimenu_phased.InsensityScope',...
            'Label',getString(message('phased:scopes:SViewerhelp')),...
            'Callback',@(hco,ev)helpview(mapFileLocation,'phasedscenarioviewer'));

            mApp(2)=uimenu(mHelp,...
            'Tag','uimgr.uimenu_Phased System Toolbox',...
            'Label',getString(message('phased:scopes:PAThelp')),...
            'Callback',@(hco,ev)helpview(mapFileLocation,'phased_doc'));




            mExample=uimenu(mHelp,...
            'Tag','uimgr.uimenu_Phased System Toolbox Examples',...
            'Label',getString(message('phased:scopes:PATExamples')),...
            'Callback',@(hco,ev)demo('toolbox','phased'));



            mAbout=uimenu(mHelp,...
            'Tag','uimgr.uimenu_About',...
            'Label',getString(message('phased:scopes:About')),...
            'Callback',@(hco,ev)aboutphasedtbx);

        end
    end
end
function closeSV(hScope)
    cameratoolbar(hScope.Parent,'stopmoving');
    visible(hScope,'off');
end

