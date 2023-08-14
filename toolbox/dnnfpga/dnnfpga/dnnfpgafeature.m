function retVal=dnnfpgafeature(varargin)








    narginchk(0,2);

    mlock;
    persistent featureMap;

    if isempty(featureMap)
        featureMap=containers.Map('KeyType','char','ValueType','any');

        featureMap('Debug')='off';

        featureMap('UseBitstreamsUnderTest')='off';
        featureMap('UpdateBitstreamMATFiles')='off';
        featureMap('ReadbackToCheckWrite')='off';
        featureMap('HWPollingInterval')=0.01;
        featureMap('DLHDLQuantizationEnable')='off';
        featureMap('FCQuantizationEnable')='on';


        featureMap('DLProcessorHDLWFA')='off';

        featureMap('Verbose')=1;

        featureMap('UseTargetManager')=false;
        featureMap('DLHDLTwoStepConversion')='off';

        featureMap('DLHDLSaveMatFiles')='off';

        featureMap('FixedPointWorkflow')='off';

    end

    if nargin==0
        keys=featureMap.keys;
        for i=1:length(keys)
            fprintf('%s:\t',keys{i});
            disp(featureMap(keys{i}));
        end
        return;
    end

    featureName=varargin{1};

    if nargin==2

        featureValue=varargin{2};


        featureMap(featureName)=featureValue;

    end


    retVal=[];
    if featureMap.isKey(featureName)
        retVal=featureMap(featureName);
    end









end

