classdef debugModule<dnnfpga.processorbase.abstractProcessor



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=debugModule(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function cycles=estimateThroughput(~,~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.debugModule doesn''t have estimateThroughput');
            cycles=[];
        end

        function nc=resolveNC(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.debugModule doesn''t have resolveNC');
            nc=[];
        end

        function s=resolveOutputSizeLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.debugModule doesn''t have resolveOutputSizeLayer');
            s=[];
        end

        function s=resolveInputSizeLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.debugModule doesn''t have resolveInputSizeLayer');
            s=[];
        end

    end

    methods(Access=protected)
        function cc=resolveCC(this)
            bcc=this.getBCC();


            convBCC=bcc.convp.conv;
            fcBCC=bcc.fcp;
            bcc=bcc.debug;


            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            debugCCParams=debugTagObj.emitCCDebugParameters;




            cc.DebugNametoIDMap=debugTagObj.getDebugNametoIDMap;

            cc.DebugParams=debugCCParams.DebugParams;

            cc.memReadLatency=bcc.memReadLatency;
            cc.debugIDAddrW=ceil(log2(bcc.debugIDNumWLimit));
            cc.debugMemReadLatency=bcc.debugMemReadLatency;
            cc.debugIDAddrW=ceil(log2(bcc.debugIDNumWLimit));
            cc.debugCounterWLimit=bcc.debugCounterWLimit;
            cc.debugDMADepthLimit=bcc.debugDMADepthLimit;
            cc.debugDMAWidthLimit=bcc.debugDMAWidthLimit;
            cc.debugBankAddrW=ceil(log2(bcc.debugBankNumWLimit));
            cc.debugMemDepth=bcc.debugMemDepth;
            cc.debugMemMinDepth=bcc.debugMemMinDepth;


            convLCMemAddrW=ceil(log2(convBCC.layerNumWLimit*convBCC.layerConfigNumWLimit));
            convDebugMemAddrW=max(ceil(log2(max(prod(convBCC.inputMemDepthLimit),prod(convBCC.resultMemDepthLimit)))),convLCMemAddrW);

            fcLCMemAddrW=ceil(log2(fcBCC.layerNumWLimit*fcBCC.layerConfigNumWLimit));
            fcDebugMemAddrW=max(ceil(log2(max(prod(fcBCC.inputMemDepthLimit),prod(fcBCC.resultMemDepthLimit)))),fcLCMemAddrW);
            cc.debugMemAddrW=max(convDebugMemAddrW,fcDebugMemAddrW);

            cc.isCNN4Debug=true;
        end

        function lc=resolveLCPerLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.fifo1Processor doesn''t have LC');
            lc=[];
        end
    end

    methods(Access=protected,Static=true)
    end
end
