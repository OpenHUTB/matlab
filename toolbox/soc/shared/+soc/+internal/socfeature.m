function retVal=socfeature(varargin)







    retVal=[];

    narginchk(1,2);

    mlock;
    persistent featureMap;

    if isempty(featureMap)
        featureMap=containers.Map('KeyType','char','ValueType','any');

        featureMap('VERBOSE_VERIFY')=false;
    end

    featureName=varargin{1};


    if featureMap.isKey(featureName)
        retVal=featureMap(featureName);
    end

    if nargin==2

        featureValue=varargin{2};


        featureMap(featureName)=featureValue;
    end






end
