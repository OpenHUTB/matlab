function retVal=dlcoderfeature(varargin)













    narginchk(1,2);

    mlock;
    persistent featureMap;

    if isempty(featureMap)
        featureMap=containers.Map('KeyType','char','ValueType','any');

        featureMap('FCBNReLUToFusedConvLayer')=false;
        featureMap('FCToConvLayer')=false;
        featureMap('cuDNNFp16')=false;
        featureMap('cnnProfiling')=false;
        featureMap('GenerateCustomLayersInRNN')=false;
        featureMap('BatchSizeSupportForARMCompute')=false;
        featureMap('EnableCustomLayerPrototypes')=false;
        featureMap('DLArrayInDAGCustomLayer')=true;
        featureMap('EnableOnlineUpdate')=false;
        featureMap('SimulinkAccelerator')=true;
        featureMap('SupportACLVersionV2011')=false;
        featureMap('AdditionQuantizationForARM')=false;
        featureMap('ConvolutionDispatcherMode')=dlcoder_base.internal.EnumConvDispatcherMode.Performance;
        featureMap('LibraryFreeSimulinkSimulation')=false;
        featureMap('UseCodegenConfigSetForSimulation')=false;
        featureMap('EnableINT8ForDLNetwork')=false;

        featureMap('EnableVarsizeDlarray')=false;
        featureMap('QuantizeAvgPoolLayer')=false;

        featureMap('UseCGIROptimizedLayerImplementation')=true;


        featureMap('OptimizedAlgoParamsSelector')=[];






        featureMap('EnableINT8ForC')=false;

        featureMap('QulNetInSL')=false;
        featureMap('QNetCodegen')=false;

        featureMap('RuntimeLoad')=false;
        featureMap('LibraryFreeCGIR')=false;
        featureMap('SupportFoldAndUnfoldLayersInOriginalGraph')=false;
        featureMap('AllowTensorRTV8X')=false;
        featureMap('OneByOneConvAsCGIRMatMul')=false;
        featureMap('AllowAnyFormatsCustomLayer')=false;
    end

    featureName=varargin{1};

    if strcmpi(featureName,'AllFeatures')


        retVal=containers.Map(keys(featureMap),values(featureMap));
        if nargin==2
            featureValue=iValidateFeatureValue(featureName,varargin{2});

            cellfun(@(fName,fValue)dlcoderfeature(fName,fValue),...
            keys(featureValue),values(featureValue),'UniformOutput',false);
        end
    else

        allFeatureNames=keys(featureMap);
        featureIndex=strcmpi(allFeatureNames,featureName);
        if(~any(featureIndex))
            error(message('dlcoder_spkg:cnncodegen:InvalidFeatureControlFlag',featureName));
        end


        assert(nnz(featureIndex)==1,['Expected ',featureName,' to map to one key in the featureMap.']);


        featureName=allFeatureNames{featureIndex};


        retVal=featureMap(featureName);

        if nargin==2

            featureValue=iValidateFeatureValue(featureName,varargin{2});

            featureMap(featureName)=featureValue;
        end
    end











end

function iMustBeValidFeatureControlClass(featureValue,allowedClass)
    isValidFeatureControlValue=isa(featureValue,allowedClass)...
    ||isempty(featureValue);


    if~(isValidFeatureControlValue)
        error(message(...
        'dlcoder_spkg:cnncodegen:InvalidFeatureControlValue',...
        strjoin({allowedClass},', ')));
    end
end

function featureValue=iValidateFeatureValue(featureName,featureValue)


    if strcmpi(featureName,'AllFeatures')
        assert(isa(featureValue,'containers.Map'),...
        message('dlcoder_spkg:cnncodegen:InvalidFeatureControlValue',...
        'containers.Map'));
    elseif strcmp(featureName,'ConvolutionDispatcherMode')


        iMustBeValidFeatureControlClass(featureValue,...
        'dlcoder_base.internal.EnumConvDispatcherMode');
    elseif strcmp(featureName,'OptimizedAlgoParamsSelector')


        iMustBeValidFeatureControlClass(featureValue,...
        'coder.internal.layer.parameterSelector.BaseParameterSelector');
    else


        isValidFeatureControlValue=(islogical(featureValue)&&...
        isscalar(featureValue))||(isnumeric(featureValue)&&...
        isscalar(featureValue)&&(featureValue==0||featureValue==1));

        if~(isValidFeatureControlValue)
            allowedValue={'true','false','0','1'};
            error(message(...
            'dlcoder_spkg:cnncodegen:InvalidFeatureControlValue',...
            strjoin(allowedValue,', ')));
        elseif~islogical(featureValue)

            featureValue=logical(featureValue);
        end
    end

end

