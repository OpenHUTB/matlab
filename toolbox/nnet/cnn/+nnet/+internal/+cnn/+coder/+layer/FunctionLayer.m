classdef FunctionLayer<nnet.layer.Layer

%#codegen

    properties
PredictFcnStr
        CodegenCompatibilityMessageID=''
    end


    methods

        function layer=FunctionLayer(predictFcn,numInputs,numOutputs,name)
            coder.allowpcode('plain');
            layer.PredictFcnStr=func2str(predictFcn);
            layer.Name=name;
            layer.NumInputs=numInputs;
            layer.NumOutputs=numOutputs;
        end


        function varargout=predict(this,varargin)
            f=coder.const(str2func(this.PredictFcnStr));
            [varargout{1:this.NumOutputs}]=f(varargin{:});
        end

    end


    methods(Static,Access=public,Hidden)

        function n=matlabCodegenNontunableProperties(~)
            n={'PredictFcnStr','CodegenCompatibilityMessageID'};
        end

    end


    methods(Static)

        function msg=checkCodegenCompatibility(mlObj)
            if~iIsCodegenCompatibleFunction(mlObj)
                msg='nnet_cnn:nnet:checklayer:constraints:SupportedFunctionLayerForCodegen:UnsupportedFunctionHandle';
            elseif isFormattable(mlObj)
                msg='nnet_cnn:nnet:checklayer:constraints:SupportedFunctionLayerForCodegen:UnsupportedFormattable';
            else
                msg='';
            end
        end


        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.layer.FunctionLayer(mlObj.PredictFcn,...
            mlObj.NumInputs,mlObj.NumOutputs,mlObj.Name);
            msgWithoutName=nnet.internal.cnn.coder.layer.FunctionLayer.checkCodegenCompatibility(mlObj);
            if~isempty(msgWithoutName)
                cgObj.CodegenCompatibilityMessageID=[msgWithoutName,'WithName'];
            end

        end

    end
end


function supported=iIsCodegenCompatibleFunction(mlObj)
    funInfo=functions(mlObj.PredictFcn);
    supported=any(strcmp(funInfo.type,["simple","classsimple"]))&&...
    ~isempty(which(funInfo.function));
end
