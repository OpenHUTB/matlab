








function url=generateUrl(path,varargin)

    url="http://127.0.0.1:31415";
    url=url+strrep(path,'+','%252B');
    if nargin>=2
        url=url+"?";

        url=url+matlab.net.internal.urlencode(varargin{1},'[]=&,:');
    end

    url=char(url);
