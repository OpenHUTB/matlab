classdef DLBitstreamBuild<handle




    properties(Access=protected)
hWC
hProcessorModel
        Verbose=1;
    end

    properties(Constant,Access=protected,Hidden)




        CustomModuleModelPath='testbench/DUT/DUT/Adder Module/Real Adder Kernel/Add Engine/Subsystem/customLayer/real/DL Custom Layers/'

    end


    methods
        function obj=DLBitstreamBuild(hWC,hProcessorModel,verbose)
            if nargin<3
                verbose=1;
            end

            obj.hWC=hWC;
            obj.hProcessorModel=hProcessorModel;
            obj.Verbose=verbose;
        end
    end


    methods
        function runBitstreamBuild(obj,isShowModel,isMakehdlOnly,hdlcoderConfig,dutConfig,projectFolder,processorName)


            dnnfpga.disp('Preparing code generation ...',1,obj.Verbose);
            dnnfpga.disp(sprintf('at %s',datestr(now)),2,obj.Verbose);


            obj.hProcessorModel.preModelSetup();

            try
                dnnfpga.disp('Loading Deep Learning Processor model ...',1,obj.Verbose);
                dnnfpga.disp(sprintf('at %s',datestr(now)),2,obj.Verbose);


                obj.hProcessorModel.loadModel(isShowModel);


                dnnfpga.disp('Setting up Deep Learning Processor model ...',1,obj.Verbose);
                dnnfpga.disp(sprintf('at %s',datestr(now)),2,obj.Verbose);


                hPC=obj.hProcessorModel.getProcessorConfig;
                hPC.ModelManager.applySettingsToModel(obj.hProcessorModel.getModelName,...
                obj.hProcessorModel.getHWDUTPath);



                obj.hProcessorModel.postModelSetup(hPC);



                obj.applyCustomMakehdlSettingToModel(hdlcoderConfig)


                obj.applyCustomDUTSettingToModel(dutConfig);


                dnnfpga.disp('Start Deep Learning Processor HDL code generation ...',1,obj.Verbose);
                dnnfpga.disp(sprintf('at %s',datestr(now)),2,obj.Verbose);


                obj.hProcessorModel.setDUTHDLParams('IPCoreName',processorName);

                if isMakehdlOnly

                    makehdl(obj.hProcessorModel.getHWDUTPath,...
                    'TargetDirectory',sprintf('%s/hdlsrc',projectFolder));

                else







                    hPC=obj.hProcessorModel.getProcessorConfig;
                    if hPC.isGenericDLProcessor
                        obj.hWC.RunTaskGenerateRTLCodeAndIPCore=true;
                        obj.hWC.RunTaskEmitDLBitstreamMATFile=true;
                        obj.hWC.RunTaskCreateProject=false;
                        obj.hWC.RunTaskBuildFPGABitstream=false;
                    end


                    obj.hWC.ProjectFolder=projectFolder;

                    try



                        hdlcoder.runWorkflow(obj.hProcessorModel.getHWDUTPath,obj.hWC,...
                        'Verbosity',obj.Verbose,...
                        'DLProcessor',obj.hProcessorModel.getProcessor,...
                        'DLProcessorConfig',hPC,...
                        'DLProcessorName',processorName);
                    catch ME


                        msg=obj.refineErrorMessage(ME);
                        error(msg);
                    end



                end


                obj.hProcessorModel.closeModel();

                dnnfpga.disp('Deep Learning Processor code generation complete.',1,obj.Verbose);
                dnnfpga.disp(sprintf('at %s',datestr(now)),2,obj.Verbose);

            catch ME

                obj.hProcessorModel.closeModel();
                rethrow(ME)
            end
        end
    end


    methods(Access=protected)

        function msg=refineErrorMessage(obj,ME)









            msg=message("dnnfpga:workflow:HDLCodeGenerationFail",ME.message);

        end
    end

    methods(Access=protected)

        function applyCustomMakehdlSettingToModel(obj,hdlcoderConfig)




            p=inputParser;
            p.KeepUnmatched=true;

            p.parse(hdlcoderConfig{:});
            inputMakehdlConfig=p.Unmatched;


            inputMakehdlConfigFields=fields(inputMakehdlConfig);
            if~isempty(inputMakehdlConfigFields)
                for ii=1:length(inputMakehdlConfigFields)
                    inputProperty=inputMakehdlConfigFields{ii};
                    inputPropertyValue=inputMakehdlConfig.(inputProperty);


                    obj.hProcessorModel.setSystemHDLParams(...
                    inputProperty,inputPropertyValue);
                end
            end
        end

        function applyCustomDUTSettingToModel(obj,dutConfig)




            p=inputParser;
            p.KeepUnmatched=true;

            p.parse(dutConfig{:});
            inputDUTConfig=p.Unmatched;


            inputDUTConfigFields=fields(inputDUTConfig);
            if~isempty(inputDUTConfigFields)
                for ii=1:length(inputDUTConfigFields)
                    inputProperty=inputDUTConfigFields{ii};
                    inputPropertyValue=inputDUTConfig.(inputProperty);


                    obj.hProcessorModel.setDUTHDLParams(...
                    inputProperty,inputPropertyValue);
                end
            end
        end

    end

end




