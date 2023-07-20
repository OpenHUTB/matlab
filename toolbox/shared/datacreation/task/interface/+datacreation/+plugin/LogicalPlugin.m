classdef(Hidden)LogicalPlugin<datacreation.internal.DataCreationPluggable






    properties(Access=public,Transient,Constant)

        PRIORITY=2;
        LiveTaskKey=message('datacreation:datacreation:logicalTaskToggleText').getString;


        LiveTaskKeyValue=message('datacreation:datacreation:logicalTaskToggleValue').getString;
        Icon=fullfile(matlabroot,'toolbox','shared','datacreation','resources','images','icons','logicalSignalPlot50_40.png');

    end


    methods(Access=public,Static)


        function aContributor=getContributor()
            aContributor=@datacreation.contributor.LogicalContributor;
        end


        function boolOut=isSupported(inKey)

            boolOut=false;

            if strcmpi(inKey,datacreation.plugin.LogicalPlugin.LiveTaskKey)

                boolOut=true;

            end
        end
    end
end
