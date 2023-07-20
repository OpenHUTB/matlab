function retVal=hdlverifierfeature(varargin)








    narginchk(1,2);

    mlock;
    persistent featureMap;

    featureName=varargin{1};

    if isempty(featureMap)||strcmp(featureName,'CLEAR_FEATURE_MAP')
        featureMap=containers.Map('KeyType','char','ValueType','any');

        featureMap('VERBOSE_VERIFY')=false;
        featureMap('SVDPI_DEBUG')=false;

        featureMap('IS_CODEGEN_FOR_UVM')=false;
        featureMap('UVM_DPIBUILD_DIR')='';

        featureMap('IS_CODEGEN_FOR_UVMSEQ')=false;

        featureMap('IS_CODEGEN_FOR_UVMDUT')=false;
        featureMap('TRANSACTION_RECORDING')=false;
    end

    if nargin==2

        featureValue=varargin{2};


        featureMap(featureName)=featureValue;
    end


    retVal=[];
    if featureMap.isKey(featureName)
        retVal=featureMap(featureName);
    end





end

