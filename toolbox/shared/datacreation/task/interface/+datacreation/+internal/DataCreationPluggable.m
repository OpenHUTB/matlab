classdef(Hidden)DataCreationPluggable<livetask.internal.LiveTaskPlugin




    methods(Static)

        function outBool=isValidIcon(inVal)
            outBool=ischar(inVal)||isStringScalar(inVal)||isa(inVal,"matlab.ui.internal.toolstrip.Icon");
        end
    end

    properties(Access=public,Transient,Constant,Abstract)

        PRIORITY double
        Icon{datacreation.internal.DataCreationPluggable.isValidIcon}
    end

end
