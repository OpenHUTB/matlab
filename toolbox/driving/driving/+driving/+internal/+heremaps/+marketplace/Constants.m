classdef Constants




    properties(Constant)
        CatalogSearchStr={'hdlm-protobuf','hdlm-native'};
        CatalogConfigVersion='2';
        HRNPlaceholder='{hrn}'

        TokenEndpointURL='https://account.api.here.com/oauth2/token'
        PlatformBaseURL='https://api-lookup.data.api.platform.here.com/lookup/v1/platform/apis'
        ResourceTemplateURL='https://api-lookup.data.api.platform.here.com/lookup/v1/resources/{hrn}/apis'

        WebRequestTimeout=15
    end

end
