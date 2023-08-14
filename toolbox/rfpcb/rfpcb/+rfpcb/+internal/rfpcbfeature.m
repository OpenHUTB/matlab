function retVal=rfpcbfeature(varargin)







    retVal=false;

    narginchk(1,2);

    mlock;
    persistent rfpcbfeatureMap;

    if isempty(rfpcbfeatureMap)


        featureList=["stripLine","coupledStripLine","couplerLange","viaSingleEnded","viaDifferential","MixedFeedModel"];
        featureStatus=[false,false,false,false,false,false];
        rfpcbfeatureMap=dictionary(featureList,featureStatus);
    end

    featureName=varargin{1};


    if rfpcbfeatureMap.isKey(featureName)
        retVal=rfpcbfeatureMap(featureName);
    end

    if nargin==2

        featureValue=varargin{2};


        rfpcbfeatureMap(featureName)=featureValue;
    end






end