




classdef(Hidden=true)SubassemblySourceFileGenerator<coder.internal.rteproxy.RTEProxyFileGeneratorBase
    methods(Access=public)
        function this=SubassemblySourceFileGenerator(model)

            this@coder.internal.rteproxy.RTEProxyFileGeneratorBase(...
            model,...
            coder.internal.rteproxy.RTEProxyFileType.SubassemblySource);
        end

        function writeSections(this)
            this.writeIncludes;
            this.writeFunctionDefinitions;
        end
    end

    methods(Access=private)

        function writeIncludes(this)


            platformServices=this.CodeDesc.getServices();
            timerService=platformServices.getServiceInterface(...
            coder.descriptor.Services.Timer);
            for subIdx=1:timerService.ServiceRequiredSubassemblyList.Size
                this.Writer.wLine('#include "%s_timer_proxy.h"',char(timerService.ServiceRequiredSubassemblyList(subIdx)));
            end
            this.Writer.wLine('#include "%s"',platformServices.getServicesHeaderFileName());



            if this.Service.getHasDuringExecutionMode
                componentInterface=this.CodeDesc.getFullComponentInterface;
                this.Writer.wLine('#include "%s"',[componentInterface.HeaderFile,'.h']);
            end
        end

        function writeFunctionDefinitions(this)
            this.Service.writeFunctionDefinitions;
        end

    end

end


