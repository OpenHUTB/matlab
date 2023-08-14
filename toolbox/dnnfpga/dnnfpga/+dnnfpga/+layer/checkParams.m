classdef checkParams





    properties

    end

    methods
        function obj=checkParams()

        end
    end
    methods(Access=public,Static=true)
        function convParams(param,layer,processor)

            if(isprop(layer,'PaddingValue'))

                if(layer.PaddingValue~=0)
                    error(message('dnnfpga:dnnfpgacompiler:UnsupportedParameter',layer.Name,'PaddingValue'));
                end
            end


            if(~strcmpi(param.type,'FPGA_ConvND')&&(param.convSplitMode>2))
                error(message('dnnfpga:workflow:GroupedConvNumberOfGroupsNotSupported',param.phase));
            end

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(layer.Stride(1),layer.Stride(2),layer.Name);

            strideLimit=dnnfpga.compiler.processorStrideLimit(processor);
            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(layer.Stride(1),layer.Name,strideLimit-1);

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForPaddingSize(param.paddingMode,layer.Name,8);

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForDilationFactor(param.dilationMode,layer.Name);











            filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);
            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(param.origOpSizeValue,layer.Name,1,filterSizeLimit);

            if isfield(processor.getBCC,'convp')
                featureSizeLimit=max(processor.getBCC.convp.conv.featureSizeLimit);
            else
                featureSizeLimit=max(processor.getBCC.conv.featureSizeLimit);
            end

            if(param.inputFeatureNum>featureSizeLimit)
                msg=message('dnnfpga:dnnfpgacompiler:InputFeaturesExceedLimit');
                error(msg);
            elseif(param.outputFeatureNum>featureSizeLimit)
                msg=message('dnnfpga:dnnfpgacompiler:OutputFeaturesExceedLimit');
                error(msg);
            end

        end


        function reluParams(previousLayerParam,layer)
            if(~isfield(previousLayerParam,'reLUMode'))
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence',layer.Name,previousLayerParam.phase);
                error(msg);
            end
        end

        function poolParams(param,processor)

            if isfield(processor.getBCC,'convp')
                featureSizeLimit=max(processor.getBCC.convp.conv.featureSizeLimit);
            else
                featureSizeLimit=max(processor.getBCC.conv.featureSizeLimit);
            end

            if(param.inputFeatureNum>featureSizeLimit)
                msg=message('dnnfpga:dnnfpgacompiler:InputFeaturesExceedLimit');
                error(msg);
            elseif(param.outputFeatureNum>featureSizeLimit)
                msg=message('dnnfpga:dnnfpgacompiler:OutputFeaturesExceedLimit');
                error(msg);
            end

        end


    end
end

