classdef Preferences<handle
    properties(Hidden)
        DeselectByProduct=true;
        UseWebkit=true;

        ShowProgressbar=true;
        ShowProfiler=false;


        MinimizeTree=true;

        BrowserMode='CEF';

        ModelAdvisorWebUI=true;
        MACEWebUIDebugMode=false;
        ShowEdittimeviewInMACE=true;
        ShowMADashboardMenu=true;
        ShowMAPreferencesMenu=true;

        MetricsDashboardRunExtensiveChecks=false;






        CommandLineRun=false;







        StateflowRebuildAll=false;




        MetricCheckThreshold=false;
    end

    properties(SetAccess=public)
        ShowByProduct=true;
        ShowByTask=true;
        ShowSourceTab=false;
        ShowExclusionTab=false;
        ShowAccordion=true;
        ShowExclusionsInRpt=true;
        RunInBackground=false;
        EnableCustomizationCache=true;
    end











    methods(Access='public')

        function Preferences=Preferences()
            persistent SinglePreferences;

            if isa(SinglePreferences,'ModelAdvisor.Preferences')
                Preferences=SinglePreferences;
            else

                SinglePreferences=Preferences;

            end
        end
    end

    methods(Access='public')
        function save(this)


            PrefFile=fullfile(prefdir,'mdladvprefs.mat');
            objfileds=fields(this);
            objfileds{end+1}='MinimizeTree';
            expand_variables(this,objfileds);
            if exist(PrefFile,'file')
                save(PrefFile,objfileds{:},'-append');
            else
                save(PrefFile,objfileds{:});
            end
        end

        function load(this)



            PrefFile=fullfile(prefdir,'mdladvprefs.mat');
            if exist(PrefFile,'file')
                try
                    mdladvprefs=load(PrefFile);
                    objfileds=fields(this);
                    objfileds{end+1}='MinimizeTree';
                    for i=1:length(objfileds)
                        if isfield(mdladvprefs,objfileds{i})
                            this.(objfileds{i})=mdladvprefs.(objfileds{i});
                        end
                    end
                catch

                    delete(PrefFile);
                    this.save;
                end
            end
        end
    end
end

function expand_variables(this,objfileds)
    for i=1:length(objfileds)
        assignin('caller',objfileds{i},this.(objfileds{i}));
    end
end