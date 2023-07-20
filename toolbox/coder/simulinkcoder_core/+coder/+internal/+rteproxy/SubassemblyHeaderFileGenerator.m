


classdef(Hidden=true)SubassemblyHeaderFileGenerator<coder.internal.rteproxy.RTEProxyFileGeneratorBase
    methods(Access=public)
        function this=SubassemblyHeaderFileGenerator(model)

            this@coder.internal.rteproxy.RTEProxyFileGeneratorBase(...
            model,...
            coder.internal.rteproxy.RTEProxyFileType.SubassemblyHeader);
        end

        function writeSections(this)
            this.writeBanner;
            this.writeIncludes;
            this.writeFunctionDeclarations;
            this.writeTrailer;
        end
    end

    methods(Access=private)
        function writeBanner(this)
            this.Writer.wLine('#ifndef RTW_HEADER_%s_timer_proxy_h_',this.Model);
            this.Writer.wLine('#define RTW_HEADER_%s_timer_proxy_h_',this.Model);
        end

        function writeIncludes(this)
            this.Writer.wLine('#include "rtwtypes.h"');

            interface=this.CodeDesc.getFullComponentInterface.PlatformServices.TimerService;
            for subIdx=1:interface.ServiceRequiredSubassemblyList.Size
                this.Writer.wLine('#include "%s_timer_proxy.h"',char(interface.ServiceRequiredSubassemblyList(subIdx)));
            end
        end

        function writeFunctionDeclarations(this)
            this.Service.writeFunctionDeclarations;
        end

        function writeTrailer(this)
            this.Writer.wLine('#endif /* RTW_HEADER_%s_timer_proxy_h_ */',this.Model);
        end

    end
end


