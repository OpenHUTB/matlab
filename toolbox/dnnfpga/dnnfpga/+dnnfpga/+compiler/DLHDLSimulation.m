classdef DLHDLSimulation<handle





    properties(Access=private)
Net
    end
    properties
        ExponentsData={};
CnnProcessor
DeployableNetwork
    end
    methods
        function obj=DLHDLSimulation(net,cnnProcessor,varargin)

            obj.Net=net;


            p=inputParser;
            addParameter(p,'exponentData',[]);
            parse(p,varargin{:});
            obj.ExponentsData=p.Results.exponentData;




            hPC=cnnProcessor;
            obj.CnnProcessor=hPC.createProcessorObject;

            processorDataType=hPC.ProcessorDataType;


            dnnfpga.compiler.sanityChecks(net,obj.CnnProcessor,obj.ExponentsData);

            dataType=dnnfpga.compiler.processorKernelType(obj.CnnProcessor);
            if(strcmp(dataType.dataTypeConv,'single'))
                obj.DeployableNetwork=dnnfpga.compiler.codegenSN2Cosim(obj.Net,obj.CnnProcessor,'ProcessorConfig',hPC);
            else
                obj.DeployableNetwork=dnnfpga.compiler.codegenSN2Cosim(obj.Net,obj.CnnProcessor,'ProcessorConfig',hPC,'exponentData',obj.ExponentsData,'processorDataType',processorDataType);
            end


            obj.DeployableNetwork.setCnnProcessor(obj.CnnProcessor);
        end
    end

    methods
        function predictFcnHandle=matlabSimulation(obj)
            predictFcnHandle=@predict;
        end
    end
end


