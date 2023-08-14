classdef(Hidden)EnumPlugin<datacreation.internal.DataCreationPluggable






    properties(Access=public,Transient,Constant)

        PRIORITY=3;
        LiveTaskKey=message('datacreation:datacreation:enumerationTaskToggleText').getString;


        LiveTaskKeyValue=message('datacreation:datacreation:enumerationTaskToggleValue').getString;
        Icon=fullfile(matlabroot,'toolbox','shared','datacreation','resources','images','icons','enumeratedSignalPlot50_40.png');
    end


    methods(Access=public,Static)


        function aContributor=getContributor()
            aContributor=@datacreation.contributor.EnumContributor;
        end


        function boolOut=isSupported(inKey)

            boolOut=false;

            if strcmpi(inKey,datacreation.plugin.EnumPlugin.LiveTaskKey)

                boolOut=true;

            end
        end
    end
end
