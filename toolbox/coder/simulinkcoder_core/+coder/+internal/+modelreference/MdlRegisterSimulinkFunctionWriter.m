


classdef MdlRegisterSimulinkFunctionWriter<handle
    properties(Access=private)
ModelInterface
CodeInfo
Writer

BuildInfoSimulinkFunctions
    end


    methods(Access=public)
        function this=MdlRegisterSimulinkFunctionWriter(modelInterface,codeInfo,writer)
            this.Writer=writer;
            this.ModelInterface=modelInterface;
            this.CodeInfo=codeInfo;
            this.BuildInfoSimulinkFunctions=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'SimulinkFunction');
        end


        function write(this)
            this.Writer.writeLine('static void mdlRegisterSimulinkFunctions(SimStruct *S) {');


            numberOfFunctions=length(this.BuildInfoSimulinkFunctions);
            for i=1:numberOfFunctions
                fcn=this.BuildInfoSimulinkFunctions{i};

                if strcmp(fcn.IsDefined,'yes')&&~strcmp(fcn.IsScoped,'yes')&&~strcmp(fcn.IsConstUncalledFunction,'yes')
                    this.Writer.writeLine(...
                    'slcsSetSimulinkFunctionPtr(S, "%s", &ss%sProvideFunction);',...
                    fcn.Name,fcn.CGFunctionName);
                end
            end
            this.Writer.writeLine('}');
        end
    end
end
