%#codegen


classdef dlnetwork<handle








    properties(Access=private)
anchor



MatFile



VariableName



CodegenInputFormats



BatchSize




NetworkInputSizes


NumOutputLayers



        DataType='fp32'


LayerLearnablesIdx



CustomLayerProperties



LearnableLayerInfo



LearnablesSizes
    end

    properties(SetAccess=private)




InputNames



OutputNames



Layers



Connections



        Initialized=true
    end


    properties
Learnables

State
    end

    properties(Access=protected)




DLTNetwork


NetworkInfo




DLTargetLib


NumInputLayers



NetworkName


HasSequenceInput



InputLayerIndices



OutputLayerIndices





CodegenInputSizes
    end

    properties(Constant,Access=private)
        PredictFcnName='#dlpredict';
        SetsizeFcnName='#setsize';
        SetupFcnName='#setup';
        DeleteFcnName='#delete';

        PredictAnchorName='#__dlpredict__';
        SetupAnchorName='#__dlsetup__';
        DeleteAnchorName='#__dldelete__';

        customPredictAnchor='#__customPredict__';
        callPredictForCustomLayersAnchor='#__dlCallPredictForCustomLayer__';
        customPropertiesAnchor='#__customProperties__';

        SetLearnablesAnchorName='#__dlsetLearnables__';
        SetLearnablesFcnName='#setLearnables';

        NetworkWrapperAnchor='#__dlNetworkWrapper__';
    end


    methods(Hidden=true)


        function obj=dlnetwork(matfile,variableName,varargin)

            coder.allowpcode('plain');
            coder.extrinsic('coder.internal.dlnetwork.parseDLNetwork');
            coder.extrinsic('coder.internal.getFileInfo');
            coder.extrinsic('dltargets.internal.getNetworkIdentifier');
            coder.extrinsic('coder.internal.getDeepLearningCodegenOptionsCallback');


            if~coder.target('MATLAB')
                coder.license('checkout','Neural_Network_Toolbox');
            end

            obj.DLTargetLib=coder.internal.coderNetworkUtils.getTargetLib();


            coder.internal.coderNetworkUtils.validateMatFileAndVariableName(matfile,variableName);


            fileName=coder.const(@coder.internal.getFileInfo,matfile);
            coder.internal.addDependentFile(fileName);

            obj.MatFile=matfile;


            networkFcnName=...
            coder.const(@feval,'coder.internal.coderNetworkUtils.parseCoderLoadNetworkVarargin',varargin{:});

            obj.setNetworkName(networkFcnName);




            [obj.DLTNetwork,mxArrayVarName]=feval('coder.internal.dlnetwork.getNetworkObj',obj.MatFile,variableName);


            obj.VariableName=coder.const(mxArrayVarName);

            ctx=eml_option('CodegenBuildContext');
            if~strcmp(obj.DLTargetLib,'disabled')



                dlConfig=coder.const(@feval,'coder.internal.getDeepLearningConfig',ctx,obj.DLTargetLib);

                dlCodegenOptionsCallback=coder.const(@coder.internal.getDeepLearningCodegenOptionsCallback,ctx);

                networkIdentifier=coder.const(@dltargets.internal.getNetworkIdentifier,obj.DLTNetwork);


                obj.DataType=coder.const(@feval,'coder.internal.coderNetworkUtils.populateDataType',dlConfig,dlCodegenOptionsCallback,networkIdentifier);
            else
                obj.DataType='fp32';
            end


            resultStruct=...
            coder.const(@coder.internal.dlnetwork.parseDLNetwork,obj.DLTNetwork);


            obj.NetworkInputSizes=resultStruct.NetworkInputSizes;
            obj.HasSequenceInput=resultStruct.HasSequenceInput;



            obj.InputLayerIndices=coder.const(resultStruct.InputLayerIndices);
            obj.OutputLayerIndices=coder.const(resultStruct.OutputLayerIndices);
            obj.NumInputLayers=coder.const(numel(resultStruct.InputNames));
            obj.NumOutputLayers=coder.const(numel(resultStruct.OutputNames));
            obj.InputNames=coder.const(resultStruct.InputNames);
            obj.OutputNames=coder.const(resultStruct.OutputNames);

            if coder.const(@feval,'dlcoderfeature','EnableOnlineUpdate')

                [~,obj.LearnablesSizes,obj.LayerLearnablesIdx]=coder.const(@feval,'coder.internal.networkLearnables',obj.DLTNetwork);
            end

            obj.setup();



            if~coder.internal.isAmbiguousComplexity&&~coder.internal.isAmbiguousTypes
                coder.internal.coderNetworkUtils.registerDependencies;
            end

        end


        function delete(obj)



            coder.inline('never');
            coder.internal.defer_inference('callDelete',obj);
        end

        function setupNetworkWrapper(obj,networkWrapperIdentifier)
            coder.inline('never');





            coder.internal.defer_inference('callSetupNetworkWrapper',obj,networkWrapperIdentifier);
        end

    end

    methods(Access=public)

        varargout=predict(varargin);

    end

    methods(Access=private)

        validate(obj);


        permutedData=permuteVectorSequenceData(obj,inputData,format)


        permutedData=permuteImageSequenceData(obj,dataInput,isDataOutput,dataFormat)

    end

    methods(Static)


        resultStruct=parseDLNetwork(dlnet);


        [outputSizes,outputFormats]=getOutputSizes(net,inputSizes,inputFormats,...
        outputNames)


        layerNames=parseInputsCodegenPredict(varargin);


        [layerIndices,sortedOutputPortIndices]=getOutputIndices(dlnet,numOutputsRequested,layerNames,targetLib);

    end

    methods(Static,Access=protected)


        [isImageOutput,outputHasTimeDim]=processOutputFormat(outputFormat)

    end

    methods(Access=protected)






        setAnchor(obj)


        permutedData=permuteFeatureData(obj,inputData);


        setNetworkName(obj,varargin)

        outputs=callPredict(obj,inputsT,...
        outsizes,isInputSequenceVarsized,outputFormats,numOutputs,...
        sortedOutputLayerIndices,sortedOutputPortIndices);

        callPredictForCustomLayers(obj);


        inputDataT=transposeInputsBeforePredict(obj,dataInputs,inputHasTimeDim,isImageInput,inputFormats);


        outputDataT=transposeOutputsAfterPredict(obj,outputData,numOutputsRequested,outputFormats)


        outputs=allocateOutputMemory(obj,numOutputsRequested,outsizes,outputFormats,isInputSequenceVarsized)


        obj=setSizeDependentProperties(obj,inputFormats);


        obj=setNetworkInfoDependentProperties(obj);
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'MatFile','VariableName','CodegenInputSizes','BatchSize','NetworkName','HasSequenceInput',...
            'NetworkInputSizes','CodegenInputFormats','NumInputLayers','NumOutputLayers',...
            'DLTargetLib','InputNames','OutputNames','DataType',...
            'Initialized','LayerLearnablesIdx','CustomLayerProperties','LearnablesSizes','LearnableLayerInfo',...
            'InputLayerIndices','OutputLayerIndices'};
        end

        function n=matlabCodegenMxArrayNontunableProperties(~)
            n={'DLTNetwork','NetworkInfo'};
        end

        function name=matlabCodegenUserReadableName(~)
            name='dlnetwork';
        end



        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end

    end

    methods(Static,Hidden)

        function[net,variableName]=getNetworkObj(matfile,variableName)

            [matObj,variableName]=coder.internal.loadCachedDeepLearningObj(matfile,variableName,ReturnNetwork=true);




            if isa(matObj,'yolov3ObjectDetector')
                net=matObj.Network;
            elseif isa(matObj,'yolov4ObjectDetector')
                net=matObj.Network;
            elseif isa(matObj,'pointPillarsObjectDetector')
                net=matObj.underlyingNetworkForCoder;
            else
                assert(isa(matObj,'dlnetwork'),'Expected to load dlnetwork object');
                net=matObj;
            end
        end

    end

    methods(Access=private)

        function setup(obj)
            coder.inline('never');






            coder.internal.defer_inference('callSetup',obj);
        end


        function callSetup(obj)
            coder.inline('always');



            if coder.internal.is_defined(obj.anchor)

                coder.ceval('-layout:any',obj.SetupAnchorName,...
                coder.internal.stringConst(obj.NetworkName));


                coder.ceval('-layout:any',obj.SetupFcnName,...
                coder.ref(obj.anchor));
            end

        end


        function callSetLearnables(obj,learnables)
            coder.inline('always');

            learnablesVal=coder.internal.coderNetworkUtils.permuteLearnables(learnables,obj.LayerLearnablesIdx,...
            obj.LearnableLayerInfo,obj.CustomLayerProperties.layerObj,obj.CustomLayerProperties.layerIdx);


            coder.ceval('-layout:any',obj.SetLearnablesAnchorName,coder.ref(learnablesVal));


            coder.ceval('-layout:any',obj.SetLearnablesFcnName,coder.wref(obj.anchor),coder.ref(learnablesVal));

        end


        function callSetupNetworkWrapper(obj,networkWrapperIdentifier)
            coder.inline('always');
            coder.internal.prefer_const(networkWrapperIdentifier);



            if coder.internal.is_defined(obj.anchor)


                coder.ceval('-layout:any',obj.NetworkWrapperAnchor,coder.rref(obj.anchor),...
                coder.internal.stringConst(networkWrapperIdentifier));
            end
        end

    end

    methods(Access=protected)




        function callSetSize(obj,sequenceLengths,inputHasTimeDim)
            coder.inline('always');
            coder.internal.prefer_const(sequenceLengths,inputHasTimeDim);


            actualSequenceLengths=coder.const(sequenceLengths(inputHasTimeDim));


            numSequenceInputs=coder.const(numel(actualSequenceLengths));
            sequenceLengthsCell=cell(1,numSequenceInputs);
            coder.unroll();
            for i=1:numSequenceInputs
                sequenceLengthsCell{i}=uint32(actualSequenceLengths(i));
            end



            coder.ceval('-layout:any',obj.SetsizeFcnName,...
            coder.wref(obj.anchor),...
            coder.internal.valuelistfun(@coder.internal.identity,sequenceLengthsCell));
        end


        function callDelete(obj)
            if coder.internal.is_defined(obj.anchor)



                if coder.const(~(strcmp(obj.DLTargetLib,'none')))
                    coder.ceval('-layout:any',obj.DeleteAnchorName);
                    coder.ceval('-layout:any',obj.DeleteFcnName,...
                    coder.ref(obj.anchor));
                end

            end
        end
    end

    methods(Static,Access=private)

        function varargout=layerPredictWithRowMajority(layer,isInputFormatted,inputDlarrayFormat,varargin)




            coder.inline('never');






            coder.rowMajor;
            shouldPreserveFunctionInterface=true;
            [varargout{:}]=coder.internal.coderNetworkUtils.customLayerPredict(layer,...
            isInputFormatted,inputDlarrayFormat,[],shouldPreserveFunctionInterface,...
            varargin{:});
        end

        function varargout=layerPredictWithColMajority(layer,isInputFormatted,inputDlarrayFormat,varargin)




            coder.inline('never');







            coder.columnMajor;
            shouldPreserveFunctionInterface=true;


            [varargout{:}]=coder.internal.coderNetworkUtils.customLayerPredict(layer,...
            isInputFormatted,inputDlarrayFormat,[],shouldPreserveFunctionInterface,...
            varargin{:});
        end
    end

    methods


        function val=get.Learnables(~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','Learnables');
            val=[];
        end

        function val=get.State(~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','State');
            val=[];
        end

        function val=get.Layers(~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','Layers');
            val=[];
        end

        function val=get.Connections(~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','Connections');
            val=[];
        end


        function set.Learnables(~,~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','Learnables');
        end

        function set.State(~,~)
            coder.internal.errorIf(true,'dlcoder_spkg:dlnetwork:PropertyNotSupported','State');
        end


        function varargout=forward(varargin)
            coder.internal.assert(false,'dlcoder_spkg:dlnetwork:UnsupportedMethod','forward');
            varargout=deal([]);
        end

        function varargout=initialize(varargin)
            coder.internal.assert(false,'dlcoder_spkg:dlnetwork:UnsupportedMethod','initialize');
            varargout=deal([]);
        end

    end

    methods(Hidden)
        function setLearnables(obj,learnables)
            coder.inline('never');

            if coder.const(@feval,'dlcoderfeature','EnableOnlineUpdate')






                coder.internal.errorIf(obj.HasSequenceInput&&strcmp(obj.DLTargetLib,'tensorrt'),...
                'dlcoder_spkg:cnncodegen:RNNLearnablesUnsupportedForTensorRT');


                ctx=eml_option('CodegenBuildContext');
                coder.const(@feval,'coder.internal.coderNetworkUtils.errorForSimulinkUpdateLearnables',ctx);


                coder.internal.coderNetworkUtils.validateLearnables(obj.LearnablesSizes,learnables);
                coder.internal.defer_inference('callSetLearnables',obj,learnables);
            end
        end
    end

end

