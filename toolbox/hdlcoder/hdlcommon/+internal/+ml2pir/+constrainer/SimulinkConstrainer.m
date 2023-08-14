




classdef SimulinkConstrainer<internal.ml2pir.constrainer.BaseConstrainer

    properties(Access=protected)

        fcnList={}

        defaultMsgID='hdlcommon:matlab2dataflow:ML2SLUnsupportedConstruct'
        typeMsgID='hdlcommon:matlab2dataflow:ML2SLUnsupportedType'

SimgenCfg
    end

    methods(Access=public)

        function this=SimulinkConstrainer(fcnTypeInfo,exprMap,fcnInfoRegistry,simgenCfg)
            this=this@internal.ml2pir.constrainer.BaseConstrainer(fcnTypeInfo,exprMap,fcnInfoRegistry);
            this.SimgenCfg=simgenCfg;
        end

    end

    methods(Access=protected)

        function isSupported=fcnSupported(~,fcnName)
            supportedPragmas={...
            'coder.allowpcode',...
            'coder.extrinsic',...
            'coder.hdl.loopspec',...
            'coder.hdl.pipeline',...
            'coder.nullcopy',...
            'coder.unroll',...
            'eml.extrinsic',...
            'eml.nullcopy',...
            'eml.unroll'};

            isSupported=~contains(fcnName,'.')||...
            ismember(fcnName,supportedPragmas);
        end

        function checkFunctionCall(this,node)
            switch node.kind
            case 'CALL'
                callee=node.Left.string;
            case 'SUBSCR'
                callee=node.Left.tree2str(0,1);
            otherwise
                assert(strcmp(node.kind,'DOT'));
                callee=node.tree2str(0,1);
            end

            if~this.fcnSupported(callee)

                this.addMessage(...
                node.Left,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:UnsupportedFunctionCall',...
                callee);
            end
        end




        function preProcessFOR(this,node)
            if~this.SimgenCfg.AllowForLoops
                preProcessFOR@internal.ml2pir.constrainer.BaseConstrainer(this,node);
            end
        end

    end
end


