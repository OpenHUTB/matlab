classdef Simulator<handle




    properties(Access=private)
        Network=[];
        ProcessorConfig=[];
        Processor=[];
        DeployableNetwork=[];
        hDLQuantizer=[];
        ExponentData=[];

    end

    methods(Access=public)
        function this=Simulator(varargin)

            p=inputParser;
            addParameter(p,'Network',[]);
            addParameter(p,'ProcessorConfig',[]);


            parse(p,varargin{:});


            if(isa(p.Results.Network,'dlquantizer'))


                this.hDLQuantizer=p.Results.Network;


                this.Network=this.hDLQuantizer.Net;
            else


                this.hDLQuantizer=[];

                this.Network=p.Results.Network;
            end

            this.ProcessorConfig=p.Results.ProcessorConfig;


            if(~strcmpi(this.ProcessorConfig.ProcessorDataType,'single')&&~isa(p.Results.Network,'dlquantizer'))
                error(message('dnnfpga:quantization:UnSupportedDlquantizer',class(p.Results.Network)));
            end

            if(~isempty(this.hDLQuantizer))
                if(~isempty(this.hDLQuantizer.CalibrationStatistics))
                    dataAdapter=dlinstrumentation.DataAdapter("ExponentScheme",this.hDLQuantizer.ExponentScheme);
                    switch(this.ProcessorConfig.ProcessorDataType)
                    case 'int8'
                        expData=dataAdapter.computeExponents(this.hDLQuantizer.CalibrationStatistics,8);
                        this.ExponentData=expData.exponentsData;
                    case 'int4'
                        expData=dataAdapter.computeExponents(this.hDLQuantizer.CalibrationStatistics,4);
                        this.ExponentData=expData.exponentsData;
                    otherwise

                    end
                else
                    error(message('dnnfpga:quantization:CalibStatEmpty','dlquantizer'));
                end
            else
                this.ExponentData=[];
            end

            this.Processor=this.ProcessorConfig.createProcessorObject;




            dnnfpga.compiler.sanityChecks(this.Network,this.Processor,this.ExponentData);



            dataType=this.ProcessorConfig.ProcessorDataType;
            try
                if(strcmp(dataType,'single'))
                    this.DeployableNetwork=dnnfpga.compiler.codegenSN2Cosim(this.Network,this.Processor,'ProcessorConfig',this.ProcessorConfig,'processorDataType',dataType);
                else
                    this.DeployableNetwork=dnnfpga.compiler.codegenSN2Cosim(this.Network,this.Processor,'ProcessorConfig',this.ProcessorConfig,'exponentData',this.ExponentData,'processorDataType',dataType);
                end
            catch ME
                throwAsCaller(ME);
            end


            this.DeployableNetwork.setCnnProcessor(this.Processor);
        end
    end

    methods(Access=public)
        function result=predict(this,input)
            result=this.DeployableNetwork.predict(input);
        end

        function result=activations(this,input,layerName,varargin)


            [acts_idx,acts_lname,~]=...
            dnnfpga.apis.Workflow.parseActivationLayerName(this.Network,layerName);


            layer=this.Network.Layers(acts_idx);
            acts_lname=this.transformActsLayerName(acts_lname,layer);

            result=this.DeployableNetwork.activations(input,acts_lname,varargin{:});
        end

    end

    methods
        function set.Network(this,net)
            if isempty(net)
                msg=message('dnnfpga:workflow:EmptyNetwork');
                error(msg);
            else
                if isa(net,'SeriesNetwork')||isa(net,'DAGNetwork')
                    this.Network=net;
                else
                    error(message('dnnfpga:workflow:InvalidInputWrongClass',...
                    'Network','SeriesNetwork, DAGNetwork or dlquantizer',class(net)));
                end
            end
        end

        function set.ProcessorConfig(this,hPC)
            if~isempty(hPC)&&~isa(hPC,'dnnfpga.config.ProcessorConfigBase')
                error(message('dnnfpga:workflow:InvalidInputWrongClass','ProcessorConfig','dlhdl.ProcessorConfig',class(hPC)));
            elseif isempty(hPC)
                error(message('dnnfpga:workflow:EmptyProcessorConfig'));
            else
                this.ProcessorConfig=hPC;
            end
        end
    end

    methods(Static=true,Access=private,Hidden=true)



        function lname=transformActsLayerName(lname,layer)


            switch class(layer)
            case 'nnet.cnn.layer.MaxPooling2DLayer'



                if layer.HasUnpoolingOutputs
                    lname=[lname,'_data'];
                end
            case{'nnet.cnn.layer.TransposedConvolution2DLayer'...
                ,'nnet.cnn.layer.DepthConcatenationLayer'...
                ,'nnet.cnn.layer.AdditionLayer'}



            end
        end
    end

end


