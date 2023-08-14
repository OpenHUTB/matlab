










function networkFcnName=parseCoderLoadNetworkVarargin(varargin)



    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.PartialMatching=false;
    pObj.KeepUnmatched=true;

    defaultNetworkFcnName='';

    validStringOrChar=@(x)(isstring(x)||ischar(x));

    addOptional(pObj,'NetworkName',defaultNetworkFcnName,validStringOrChar);

    parse(pObj,varargin{:});

    networkFcnName=pObj.Results.NetworkName;

end
