classdef Spacer<flexibleportplacement.connector.Connector





    properties(SetAccess=private)
        DisplayName='Spacer'
        Identifier=flexibleportplacement.connector.Spacer.ConstId;
    end

    properties(Constant,Access=private)
        ConstId='Spacer'
    end

    methods(Static)
        function tf=isIdForSpacer(id)
            tf=strcmp(id,flexibleportplacement.connector.Spacer.ConstId);
        end
    end
end

