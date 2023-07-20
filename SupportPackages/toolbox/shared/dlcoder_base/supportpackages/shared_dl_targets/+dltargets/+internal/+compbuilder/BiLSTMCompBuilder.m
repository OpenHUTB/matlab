classdef BiLSTMCompBuilder<dltargets.internal.compbuilder.RNNCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.rnn_layer_comp';


        compKind='rnnlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.BiLSTMCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.BiLSTMCompBuilder.compKind;
        end

        function validate(layer,validator)

            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

            allGateAndStateActSupportedTargets={'arm-compute'};
            if~any(strcmpi(validator.getTargetLib(),allGateAndStateActSupportedTargets))
                if~dltargets.internal.compbuilder.RNNCompBuilder.hasDefaultStateFunction(layer)
                    errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedStateActivationFunction',layer.StateActivationFunction,layer.Name,validator.getTargetLib());
                    validator.handleError(layer,errorMessage);
                end

                if~dltargets.internal.compbuilder.RNNCompBuilder.hasDefaultGateFunction(layer)
                    errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedGateActivationFunction',layer.GateActivationFunction,layer.Name,validator.getTargetLib());
                    validator.handleError(layer,errorMessage);
                end
            end



            dltargets.internal.compbuilder.RNNCompBuilder.checkForMimoRNNLayer(layer,validator);
        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.RNNCompBuilder.setCommonRNNCompProperties(layer,converter,comp);

            comp.setRnnMode(0);

            comp.setRnnBiasMode(0);

            comp.setIsBidirectional(true);

            fileNames=converter.getParameterFileNames(layer.Name);
            weightsFile=fileNames{1};
            biasFile=fileNames{2};
            initialHiddenStateFile=fileNames{3};
            initialCellStateFile=fileNames{4};

            comp.setWeightsFile(weightsFile);
            comp.setBiasFile(biasFile);
            comp.setInitialHiddenStateFile(initialHiddenStateFile);
            comp.setInitialCellStateFile(initialCellStateFile);

        end

        function saveFiles(layer,fileSaver)

            weightsFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.WeightsFileNamePostfix);
            weightsFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(weightsFile,...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            biasFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.BiasFileNamePostfix);
            biasFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(biasFile,...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            initialHiddenStateFileNamePostfix='_hx.bin';
            initialHiddenStateFile=strcat(fileSaver.getFilePrefix,layer.Name,initialHiddenStateFileNamePostfix);
            initialHiddenStateFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(initialHiddenStateFile,...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            initialCellStateFileNamePostfix='_cx.bin';
            initialCellStateFile=strcat(fileSaver.getFilePrefix,layer.Name,initialCellStateFileNamePostfix);
            initialCellStateFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(initialCellStateFile,...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{weightsFile,biasFile,initialHiddenStateFile,initialCellStateFile});


            W=layer.InputWeights;
            R=layer.RecurrentWeights;


            Wf=W(1:(end/2),:);
            Wb=W((end/2)+1:end,:);

            Rf=R(1:(end/2),:);
            Rb=R((end/2)+1:end,:);


            Wft=Wf';
            Wbt=Wb';

            Rft=Rf';
            Rbt=Rb';


            W=[Wft(:);Rft(:);...
            Wbt(:);Rbt(:)];


            bias=layer.Bias;
            bf=bias(1:(end/2));
            bb=bias((end/2)+1:end);

            b=[bf(:);bb(:)];

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,weightsFile,W);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,biasFile,b);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,initialHiddenStateFile,layer.HiddenState);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,initialCellStateFile,layer.CellState);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'InputSize',layer.InputSize,...
            'NumHiddenUnits',layer.NumHiddenUnits,'OutputMode',layer.OutputMode,...
            'StateActivationFunction',layer.StateActivationFunction,...
            'GateActivationFunction',layer.GateActivationFunction);
        end
    end
end
