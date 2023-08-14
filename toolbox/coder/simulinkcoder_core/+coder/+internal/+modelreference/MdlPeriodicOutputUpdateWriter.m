




classdef MdlPeriodicOutputUpdateWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
NumPeriodicTasks
    end


    methods
        function this=MdlPeriodicOutputUpdateWriter(outputFunctionInterfaces,updateFunctionInterfaces,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter([],modelInterfaceUtils,codeInfoUtils,writer);



            numPeriodicTasks=0;
            for idx=1:length(outputFunctionInterfaces)
                if(strcmp(outputFunctionInterfaces(idx).Timing.TimingMode,'PERIODIC')||...
                    strcmp(outputFunctionInterfaces(idx).Timing.TimingMode,'APERIODIC'))
                    numPeriodicTasks=numPeriodicTasks+1;
                else
                    break;
                end
            end

            this.FunctionInterfaces=outputFunctionInterfaces(1:numPeriodicTasks);



            if~isempty(updateFunctionInterfaces)
                assert(length(updateFunctionInterfaces)>=numPeriodicTasks);
                this.FunctionInterfaces=...
                [this.FunctionInterfaces,updateFunctionInterfaces(1:numPeriodicTasks)];
            end

            this.NumPeriodicTasks=numPeriodicTasks;
        end
    end



    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=sprintf('void mdlPeriodicOutputUpdate(SimStruct *S, int_T %s)',...
            this.ModelInterfaceUtils.getGlobalTidString);
        end

        function writeFunctionBody(this,~)
            if~isempty(this.FunctionInterfaces)
                actualArguments=this.FunctionInterfaceUtils.getActualArguments(...
                this.FunctionInterfaces);
                this.declareMultiInstanceVariables;
                parameterIndices=this.declareFunctionArguments(actualArguments);
                this.writeModelArguments(actualArguments,parameterIndices);

                for idx=1:length(this.FunctionInterfaces)
                    this.initializePorts(this.FunctionInterfaces(idx).ActualArgs);
                end

                this.writeFunctionCall;

                this.updateOutports(actualArguments);
            end
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end


        function initializePorts(this,actualArguments)
            if this.HasVarDimsInport||this.HasVarDimsOutport
                if this.HasVarDimsInport
                    this.writeInitializeVarDimsPorts(actualArguments,'In','ssGetCurrentInputPortDimensions');
                end

                if this.HasVarDimsOutport
                    this.writeInitializeVarDimsPorts(actualArguments,'Out','ssGetCurrentOutputPortDimensions');
                end
            end
        end


        function writeFunctionCall(this,~)
            numPeriodicTasks=this.NumPeriodicTasks;
            for taskIdx=1:numPeriodicTasks
                this.Writer.writeLine(...
                'if (%s == %d) {',...
                this.ModelInterfaceUtils.getGlobalTidString,...
                taskIdx-1);


                outputFunctionInterface=this.FunctionInterfaces(taskIdx);


                this.Writer.writeLine([outputFunctionInterface.getFunctionCall,';']);


                this.writeUpdateVarDimsOutPorts(outputFunctionInterface.ActualArgs);

                updateFunctionInterfaceIdx=taskIdx+numPeriodicTasks;
                if updateFunctionInterfaceIdx<=length(this.FunctionInterfaces)

                    updateFunctionInterface=...
                    this.FunctionInterfaces(updateFunctionInterfaceIdx);


                    this.Writer.writeLine([updateFunctionInterface.getFunctionCall,';']);


                    this.writeUpdateVarDimsOutPorts(updateFunctionInterface.ActualArgs);
                end

                this.Writer.writeLine('}');
            end

        end
    end
end


