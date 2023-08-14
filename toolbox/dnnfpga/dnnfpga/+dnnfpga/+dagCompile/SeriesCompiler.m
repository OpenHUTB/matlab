classdef SeriesCompiler<handle

    methods(Static=true,Access=public)

        function v=canCreateSeriesNetwork(component)
            import dnnfpga.dagCompile.*;
            v=component.hasKind(LayerKind.Conv)||...
            component.hasKind(LayerKind.FC);
        end

        function sn=createSeriesNework(component)
            sz=component.inputs(1).net.size;
            layerInput=imageInputLayer(sz,'Name','data','Normalization','none');
            layerOutputR=regressionLayer('Name','output');
            try
                if(isa((component.nLayer(end)),'nnet.cnn.layer.SoftmaxLayer'))



                    if(numel(component.nLayer)>1)

                        outputSize=prod(component.outputs.size);
                    else
                        inputSize=component.inputs.size;

                        if(nnz(inputSize==1)+1>=numel(inputSize))
                            outputSize=prod(component.inputs.size);
                        else
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedInputSize',component.nLayer.Name);
                            error(msg);
                        end
                    end
                    labels=categorical(1:outputSize);
                    layerOutputC=classificationLayer('Name','output','Classes',labels);
                    sn=assembleNetwork([layerInput,component.nLayer,layerOutputC]);
                elseif(isa((component.nLayer(1)),'nnet.cnn.layer.SigmoidLayer')||isa((component.nLayer(1)),'dnnfpga.layer.ExponentialLayer'))




                    inputSize=component.inputs.size;
                    if(~(nnz(inputSize==1)+1>=numel(inputSize)))
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedInputSize',component.nLayer(1).Name);
                        error(msg);
                    end
                    sn=assembleNetwork([layerInput,component.nLayer,layerOutputR]);
                else
                    sn=assembleNetwork([layerInput,component.nLayer,layerOutputR]);
                end
            catch ME
                rethrow(ME);
            end
        end
    end
end