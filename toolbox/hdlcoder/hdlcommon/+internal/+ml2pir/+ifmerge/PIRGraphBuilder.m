classdef PIRGraphBuilder<internal.ml2pir.PIRGraphBuilder



    methods
        function traceCmt=getNodeTraceability(this,~)

            traceCmt=this.TraceCmtPrefix;
        end
    end

    methods(Access=protected)

        function traceCmtPrefix=createTraceCmtPrefix(this)

            traceCmtPrefix=coder.internal.getNameForBlock(this.PirOptions.OriginalSLHandle);
        end
    end
end

