classdef APILookupClient<driving.internal.heremaps.marketplace.RESTClient

    properties(Access=private)

PlatformResponse
    end

    properties(Constant,Hidden)

        ResourceResponse=containers.Map('KeyType','char','ValueType','any')
    end

    properties(Access=?MarketplaceTester)

TestingURL
    end

    methods(Access=protected)

        function this=APILookupClient()
            this.BaseURL=driving.internal.heremaps.marketplace.Constants.PlatformBaseURL;
        end

        function data=getPlatformResponse(this)
            data=this.read(this.BaseURL);
        end

        function data=getResourceResponse(this,catalog)
            if~this.ResourceResponse.isKey(catalog)
                url=matlab.net.URI(this.getCatalogResourceURL(catalog));
                localMap=this.ResourceResponse;
                localMap(catalog)=this.read(url);%#ok<NASGU>
            end
            data=this.ResourceResponse(catalog);
        end

    end

    methods(Static,Hidden)

        function this=getInstance()
            persistent client
            if isempty(client)
                client=driving.internal.heremaps.marketplace.APILookupClient();
            end
            this=client;
        end

        function url=getCatalogResourceURL(catalog)
            import driving.internal.heremaps.marketplace.Constants;
            url=replace(Constants.ResourceTemplateURL,Constants.HRNPlaceholder,catalog);
        end

    end

    methods(Hidden)

        function baseURL=getBaseURL(this,api,apiversion,catalog)
            if isempty(this.TestingURL)
                if nargin==3
                    if isempty(this.PlatformResponse)
                        this.PlatformResponse=this.getPlatformResponse;
                    end
                    data=this.PlatformResponse;
                else
                    data=this.getResourceResponse(catalog);
                end
                baseURL=matlab.net.URI(getBaseURLforAPI(data,api,apiversion));
            else
                baseURL=this.TestingURL;
            end
        end

    end

end

function url=getBaseURLforAPI(data,api,apiversion)
    url='';
    for idx=1:numel(data)
        if strcmpi(data(idx).api,api)&&strcmpi(data(idx).version,apiversion)
            url=data(idx).baseURL;
            break;
        end
    end
end