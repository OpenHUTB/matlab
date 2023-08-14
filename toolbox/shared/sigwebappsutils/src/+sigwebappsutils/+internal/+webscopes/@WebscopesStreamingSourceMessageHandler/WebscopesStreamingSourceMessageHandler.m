

classdef WebscopesStreamingSourceMessageHandler<matlabshared.scopes.WebScopeMessageHandler


    methods

        function setAxesLimits(this,axesLimits)
            this.sendToClient('setAxesLimits',axesLimits);
        end
    end
end