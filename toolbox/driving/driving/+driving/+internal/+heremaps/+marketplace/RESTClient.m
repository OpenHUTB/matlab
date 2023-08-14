classdef(Abstract)RESTClient<handle







    properties(SetAccess=protected)

        BaseURL(1,1)matlab.net.URI
    end

    properties(Access=protected)

        WebOptions=weboptions(...
        'CharacterEncoding','UTF-8',...
        'MediaType',matlab.net.http.MediaType('application/json'),...
        'Timeout',driving.internal.heremaps.marketplace.Constants.WebRequestTimeout);
    end

    methods(Access=protected)

        function data=read(this,requestURL)

            credentialsManager=driving.internal.heremaps.CredentialsManager.getInstance();
            data=webread(credentialsManager,requestURL,this.WebOptions);
        end

        function url=getURLWithPath(this,varargin)

            url=this.BaseURL;
            url.Path=horzcat(url.Path,varargin);
        end

    end

    methods(Static)

        function validateResponse(response,varargin)

            depth=nargin-1;
            for idx=1:depth
                fields=varargin{idx};
                notFound=~isfield(response,fields);
                if isempty(response)||any(notFound)
                    if iscell(fields)
                        f=strjoin(fields(notFound),', ');
                    else
                        f=fields;
                    end
                    error(message('driving:heremaps:InvalidMarketplaceResponse',f));
                end
                if idx<depth
                    response=response.(fields);
                    if iscell(response)
                        response=response{1};
                    end
                end
            end
        end

    end

end