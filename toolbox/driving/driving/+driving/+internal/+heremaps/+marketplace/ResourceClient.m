classdef(Abstract)ResourceClient<driving.internal.heremaps.marketplace.RESTClient







    properties(Abstract,Constant,Access=protected)

APIName

APIVersion
    end

    methods

        function this=ResourceClient(catalog)

            if nargin>0
                this.setCatalogBaseURL(catalog);
            end
        end

        function setCatalogBaseURL(this,catalog)

            lookup=driving.internal.heremaps.marketplace.APILookupClient.getInstance();
            this.BaseURL=lookup.getBaseURL(this.APIName,this.APIVersion,catalog);
        end

    end
end