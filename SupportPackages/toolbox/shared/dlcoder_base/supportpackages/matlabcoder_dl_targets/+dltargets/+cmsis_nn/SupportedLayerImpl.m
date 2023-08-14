






classdef SupportedLayerImpl<handle
    properties(Constant,Access=public)
        m_supportedLayers=dltargets.cmsis_nn.SupportedLayerImpl.initSupportedLayers();
        m_layerToCompMap=dltargets.cmsis_nn.SupportedLayerImpl.populateLayerToCompMap();
        rootDir=fullfile(dltargets.cmsis_nn.SupportedLayerImpl.getInstallDir(),'matlabcoder_dl_targets','cmsis_nn');
    end

    methods(Static=true)

        function rootDir=getInstallDir
            [flag,rootDir]=dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
            assert(flag);
            assert(~isempty(rootDir));
        end

        function supportedLayers=initSupportedLayers()

            supportedLayers={'gpucoder.input_layer_comp',...
            'gpucoder.output_layer_comp',...
            'gpucoder.conv_int8_layer_comp',...
            'gpucoder.MWBfpScaleLayer',...
            'gpucoder.MWBfpRescaleLayer',...
            'gpucoder.sequence_input_layer_comp',...
            'gpucoder.rnn_layer_comp',...
            'gpucoder.fc_int8_layer_comp',...
            'gpucoder.elementwise_affine_layer_comp',...
'gpucoder.softmax_layer_comp'
            };
        end

        function layerToCompMap=populateLayerToCompMap()
            layerToCompMap=containers.Map;
            layerToCompMap('nnet.cnn.layer.FullyConnectedLayer')='gpucoder.fc_int8_layer_comp';
            layerToCompMap('nnet.cnn.layer.ImageInputLayer')='gpucoder.input_layer_comp';
            layerToCompMap('nnet.cnn.layer.LSTMLayer')='gpucoder.rnn_layer_comp';
            layerToCompMap('nnet.cnn.layer.SequenceInputLayer')='gpucoder.sequence_input_layer_comp';
            layerToCompMap('nnet.cnn.layer.SoftmaxLayer')='gpucoder.softmax_layer_comp';
            layerToCompMap('nnet.cnn.layer.ClassificationOutputLayer')='gpucoder.output_layer_comp';
            layerToCompMap('nnet.cnn.layer.RegressionOutputLayer')='gpucoder.output_layer_comp';
            layerToCompMap('nnet.onnx.layer.ElementwiseAffineLayer')='gpucoder.elementwise_affine_layer_comp';
        end
    end
end


