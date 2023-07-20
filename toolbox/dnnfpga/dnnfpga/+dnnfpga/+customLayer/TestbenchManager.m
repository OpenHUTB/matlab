classdef TestbenchManager<handle


    properties(GetAccess=public,SetAccess=protected)



LayerManager


Network


InputImages


DeployableIR


ModelManager

    end
    properties(Constant,Access=public)




        TestbenchModelName='dnnfpgaCustomLayerVerificationModel'


        TestbenchModelPath=fullfile('toolbox','dnnfpga','dnnfpga','model','customLayers');


        AutoGenNetworkName='dnnfpgaCustomLayerAutoGenNetwork'



        SimulationTimeName='dnnfpgaCustomLayerSimTime'


        DefaultSimulationTime=9000

    end

    methods
        function obj=TestbenchManager(hLayerManager)


            obj.LayerManager=hLayerManager;
            obj.ModelManager=dnnfpga.model.ModelManager(hLayerManager.ProcessorConfig);

        end

        function openModel(obj,varargin)


            p=inputParser;

            addParameter(p,'Network',[]);


            addParameter(p,'InputImages',[],@dnnfpga.apis.Workflow.validateInputImages);
            addParameter(p,'LoadModelOnly',false,@(x)islogical(x));


            parse(p,varargin{:});
            net=p.Results.Network;
            image=p.Results.InputImages;
            loadModelOnly=p.Results.LoadModelOnly;


            customLayerList=obj.LayerManager.getLayerList;
            hPC=obj.LayerManager.ProcessorConfig;


            if isempty(customLayerList)
                msg=message('dnnfpga:customLayer:EmptyCustomLayer');
                error(msg);
            end


            if isempty(net)








                try
                    convThreadNum=sqrt(hPC.getModuleProperty('conv','ConvThreadNumber'));
                    layers=imageInputLayer([2,2,convThreadNum],'Name','input','Normalization','none');
                    for idx=1:numel(customLayerList)


                        customLayer=customLayerList(idx);
                        layerName=[customLayer.ConfigBlockName,'_',num2str(idx)];
                        layerArguments={layerName};
                        if customLayer.NumInputs>1
                            layerArguments=horzcat(layerArguments,customLayer.NumInputs);%#ok<AGROW> 
                        end






                        if strcmp(customLayer.ClassName,'nnet.cnn.layer.AdditionLayer')
                            layerArguments={nnet.internal.cnn.layer.Addition(layerArguments{:})};
                        end

                        if strcmp(customLayer.ClassName,'dnnfpga.layer.identityLayer')||...
                            strcmp(customLayer.ClassName,'dnnfpga.layer.ExponentialLayer')
                            layerArguments=[{'Name'},layerArguments(:)'];
                        end




                        layers(end+1)=feval(customLayer.ClassName,layerArguments{:});%#ok<AGROW> 
                    end


                    layerOutput=regressionLayer('Name','output');
                    layers(end+1)=layerOutput;




                    lgraph=layerGraph(layers);
                    for idx=1:numel(lgraph.Layers)
                        layer=lgraph.Layers(idx);
                        if layer.NumInputs>1
                            for idy=2:layer.NumInputs
                                lgraph=connectLayers(lgraph,lgraph.Layers(idx-1).Name,[layer.Name,'/in',num2str(idy)]);
                            end
                        end
                    end



                    net=assembleNetwork(lgraph);
                    assignin('base',obj.AutoGenNetworkName,net);


                    msg=message('dnnfpga:customLayer:EmptyNetworkProperty',obj.AutoGenNetworkName);
                    dnnfpga.disp(msg.getString);
                catch ME



                    msg=message('dnnfpga:customLayer:ErrorCreateNetwork');
                    error(msg);
                end

            end


            dnnfpga.disp(message('dnnfpga:customLayer:VerificationModelGenerationStart'));


            obj.checkCanCompileNetwork(net);


            if isempty(image)
                image=rand(net.Layers(1).InputSize);
            end


            obj.Network=net;
            obj.InputImages=image;


            cnnp=hPC.createProcessorObject;
            cc=cnnp.getCC;


            dnnfpga.disp(message('dnnfpga:dnnfpgadisp:CompileStartMsg'));



            deployableNW=dnnfpga.compiler.codegenfpga(net,cnnp,'ProcessorConfig',hPC,'verbose',0);
            inputData=deployableNW.activations(image,'InputToFPGA');
            fpgaLayer=deployableNW.getSingletonFPGALayer();
            initData=fpgaLayer.getData();
            obj.DeployableIR=fpgaLayer.getDepolyableIR(true);


            sGraph=obj.DeployableIR.sgraph;
            for component=sGraph.sortedComponents'

                if component.hasKind(dnnfpga.dagCompile.LayerKind.Hard)


                    supportedLayerKinds=[dnnfpga.dagCompile.LayerKind.Add,...
                    dnnfpga.dagCompile.LayerKind.CustomLayer,...
                    ];
                    if~any(component.hasKind(supportedLayerKinds))
                        msg=message('dnnfpga:customLayer:NetworkContainsOtherLayer');
                        error(msg);
                    end

                end
            end


            TB.dataTransNum=cc.dataTransNum;
            TB.activationKernalDataType=hPC.ProcessorDataType;
            TB.inputData=reshape(inputData,[TB.dataTransNum,length(inputData)/TB.dataTransNum]);


            customLayerInstructions=initData.instructions.adder;
            TB.customLayerInstructionsLen=length(customLayerInstructions);
            TB.customLayerInstructionsAddr=0;
            skdInstuctions=initData.instructions.scheduler;
            TB.skdInstructionsLen=length(skdInstuctions);
            TB.skdInstructionsAddr=TB.customLayerInstructionsAddr+4*TB.customLayerInstructionsLen;
            TB.instructionsData=[customLayerInstructions,skdInstuctions];


            assignin('base','cc',cc);
            assignin('base','TB',TB);









            assignin('base',obj.SimulationTimeName,obj.DefaultSimulationTime);


            dnnfpga.customLayer.setup;











            try
                bdclose(obj.TestbenchModelName);
                templateModelPath=fullfile(matlabroot,...
                obj.TestbenchModelPath,...
                strcat(obj.TestbenchModelName,'.slx'));
                copyfile(templateModelPath,pwd,'f');
            catch ME
                throw(ME);
            end


            if loadModelOnly
                load_system(obj.TestbenchModelName);
            else
                open_system(obj.TestbenchModelName);
            end


            obj.ModelManager.applySettingsToModel(obj.TestbenchModelName,...
            [obj.TestbenchModelName,'/DUT']);


            dnnfpga.disp(message('dnnfpga:customLayer:VerificationModelGenerationComplete'));

        end

        function simulateModel(obj,varargin)



            dnnfpga.disp(message('dnnfpga:customLayer:SimulationAndVerificationStart'));


            p=inputParser;


            addParameter(p,'RelativeTolerance',1e-4,@(x)isnumeric(x)&&isreal(x));
            addParameter(p,'AbsoluteTolerance',1e-4,@(x)isnumeric(x)&&isreal(x));


            addParameter(p,'SimulationTime',obj.DefaultSimulationTime,@(x)isnumeric(x)&&isreal(x));
            addParameter(p,'Testcase',[]);


            parse(p,varargin{:});
            simulationTime=p.Results.SimulationTime;
            assignin('base',obj.SimulationTimeName,simulationTime);




            extraVarargin={'Network',obj.Network,...
            'InputImages',obj.InputImages,...
            'ModelName',obj.TestbenchModelName,...
            'DeployableIR',obj.DeployableIR,...
            'CheckDoneSignal',true};
            varargin=horzcat(varargin,extraVarargin);


            obj.ModelManager.simulateAndValidateModel(varargin{:});


            dnnfpga.disp(message('dnnfpga:customLayer:SimulationAndVerificationComplete'));
        end

        function checkCanCompileNetwork(~,net)

            if(~dnnfpga.compiler.canCompileNet(net,false))
                msg=message('dnnfpga:simulation:InvalidNetwork');
                error(msg);
            end
        end

    end
end

