classdef(Hidden)NumericalPlugin<datacreation.internal.DataCreationPluggable






    properties(Access=public,Transient,Constant)

        PRIORITY=1;
        LiveTaskKey=message('datacreation:datacreation:numericalTaskToggleText').getString;


        LiveTaskKeyValue=message('datacreation:datacreation:numericalTaskToggleValue').getString;
        Icon=fullfile(matlabroot,'toolbox','shared','datacreation','resources','images','icons','linePlot.svg');

    end


    methods(Access=public,Static)


        function aContributor=getContributor()
            aContributor=@datacreation.contributor.NumericalContributor;
        end


        function boolOut=isSupported(inKey)

            boolOut=false;

            if strcmpi(inKey,datacreation.plugin.NumericalPlugin.LiveTaskKey)

                boolOut=true;

            end
        end
    end
end
