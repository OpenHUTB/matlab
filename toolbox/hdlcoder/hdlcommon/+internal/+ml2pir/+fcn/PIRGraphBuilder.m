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

        function resolveMismatchedSignals(this,sig1,sig2)
            if sig1.Type.isArrayType&&~sig2.Type.isArrayType


                vals.hN=sig1.Owner;
                vals.inSigs=sig1;
                vals.outSigs=sig2;
                indexArray={internal.mtree.Constant('',1,'idx')};
                isConditional=false;
                this.instantiateSubscrNode(vals,indexArray,isConditional);
            else
                resolveMismatchedSignals@internal.ml2pir.PIRGraphBuilder(this,sig1,sig2)
            end
        end

    end
end

