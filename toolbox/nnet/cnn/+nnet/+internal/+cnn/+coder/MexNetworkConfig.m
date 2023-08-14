classdef(Abstract)MexNetworkConfig














    properties

        Precision string="single"


        TargetLib char='cudnn'


        NumOutputs(1,1)double



        ConstantInputs cell={}
    end

    methods
        function obj=MexNetworkConfig(targetLib,precision,numOutputs,constantInputs)
            obj.Precision=precision;
            obj.TargetLib=targetLib;
            obj.NumOutputs=numOutputs;
            obj.ConstantInputs=constantInputs;
        end

        function key=getKey(this)




            keyContent=this.getKeyContent();



            currentDevice=gpuDevice();
            currentDeviceIdx=currentDevice.Index;

            key=jsonencode([keyContent;{currentDeviceIdx}]);
        end

        function codegenArguments=getCodegenArguments(this,networkFilename,generationDirectory)


            magicKey='tp835d9653_bestej_4437_dlaccelbfd0_dc3f1d27bb78';
            codegenArguments={'-args',this.getCodegenInputArgs(networkFilename),...
            '-config',this.getCoderConfig(),...
            '-o',generationDirectory,...
            '-d',generationDirectory,...
            '-nargout',this.NumOutputs,...
            '--preserve',magicKey...
            };
        end

        function[designFileName,designFilePath]=getDesignFileInfo(this)



            [designFileName,designFilePath]=this.getDesignFileNameAndPath();
        end

        function fusedLayerFcn=getFusedLayerFcn(this)



            fusedLayerFcn=this.getAssociatedFusedLayerFcn();
        end

        function mustBeSupportedNetwork(this,network)




            inputSizes=this.getInputSizesForValidation(network);
            cfg=coder.DeepLearningConfig('TargetLibrary',this.TargetLib,'DeepLearningAcceleration',true);
            try


                resetVal=dlcoderfeature('QNetCodegen',true);
                cleanup=onCleanup(@()dlcoderfeature('QNetCodegen',resetVal));

                dltargets.internal.sdk.validateNetwork(network,cfg,dltargets.internal.formatInputSizes(inputSizes));
            catch me

                e=MException(message('nnet_cnn:dlAccel:NetworkUnsupported'));
                e=e.addCause(me);
                throw(e);
            end

            if deep.internal.quantization.isQuantizationEnabled(network)
                quantizedNetworkTargetLibrary=deep.internal.quantization.getTargetLibrary(network);
                if~strcmpi(this.TargetLib,quantizedNetworkTargetLibrary)
                    error(message('nnet_cnn:dlAccel:QuantizedUnsupported'));
                end
            end
        end
    end

    methods(Access=private)
        function inputArgs=getCodegenInputArgs(this,networkFileName)




            variableInputArgs=this.getCodegenVariableInputArgs();



            extraConstantInputs=cellfun(@coder.Constant,this.ConstantInputs,"UniformOutput",false);





            inputArgs=[{coder.Constant(networkFileName)},extraConstantInputs,variableInputArgs];
        end
    end


    methods(Abstract,Access=protected)
        key=getKeyContent(this);
        inputArgs=getCodegenVariableInputArgs(this);
        [designFileName,designFilePath]=getDesignFileNameAndPath(this);
        fusedLayerFcn=getAssociatedFusedLayerFcn(this);
        inputSizes=getInputSizesForValidation(this,network);
    end

    methods(Access=protected)
        function path=getMexNetworkPrivateDirectoryPath(~)
            path=fullfile(matlabroot,'toolbox','nnet',...
            'cnn','+nnet','+internal','+cnn','+coder','private');
        end

        function cfg=getCoderConfig(this)




            cfg=coder.config('mex');
            cfg.GenerateReport=false;
            cfg.TargetLang='C++';
            if strcmpi(this.TargetLib,'cudnn')
                cfg.GpuConfig=coder.gpu.config;
                cfg.GpuConfig.Enabled=1;

                cfg.CppPreserveClasses=false;
            end
            cfg.DeepLearningConfig=coder.DeepLearningConfig('TargetLibrary',this.TargetLib,'DeepLearningAcceleration',true);
            cfg.GpuConfig.UseShippingLibs=true;
            cfg.GpuConfig.SafeBuild=1;
        end
    end
end
