function retVal=gpufeature(varargin)











    narginchk(1,2);
    mlock;
    persistent featureMap;

    if isempty(featureMap)
        iInitializeFeatureMap();
    end

    featureName=varargin{1};
    if strcmp(featureName,'AllFeatures')
        retVal=containers.Map(keys(featureMap),values(featureMap));
    else
        iCheckFeatureName(featureName);
        retVal=featureMap(featureName);
        if nargin==2
            featureMap(featureName)=varargin{2};
        end
    end

    function iInitializeFeatureMap()
        featureMap=containers.Map('KeyType','char','ValueType','any');
        featureMap('ReduceShuffleThreshold')=0;
        featureMap('ReduceStrideFactor')=20;
        featureMap('EnableMemcpy')=false;
        featureMap('gpuMemoryMode')='high';
    end

    function iCheckFeatureName(featureName)
        allFeatureNames=keys(featureMap);
        featureIndex=strcmp(allFeatureNames,featureName);
        if(~any(featureIndex))
            error(message('gpucoder:common:InvalidGpuFeatureControlName',featureName));
        end
    end

end


