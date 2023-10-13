function varargout=iptfeature(varargin)

    narginchk(1,2);

    mlock;
    persistent iptFeatureMap


    if isempty(iptFeatureMap)
        iptFeatureMap=containers.Map('KeyType','char','ValueType','logical');

        iptFeatureMap('BigImageProcessing')=false;
    end

    featureName=varargin{1};


    if nargin==2
        iptFeatureMap(featureName)=varargin{2};
    end


    retVal=[];
    if iptFeatureMap.isKey(featureName)
        retVal=iptFeatureMap(featureName);
    end

    if nargout==1
        varargout{1}=retVal;
    end

end
