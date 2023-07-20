classdef NullRTEStrategy<autosar.bsw.rte.RTEStrategy




    methods
        function this=NullRTEStrategy(serviceFunctionName)
            this@autosar.bsw.rte.RTEStrategy(serviceFunctionName);
        end

        function createRTE(~,simulinkFcnBlk,inArgHandles,outArgHandles,~,~)
            import autosar.bsw.rte.NullRTEStrategy.getPortStr

            for inArgIdx=1:numel(inArgHandles)
                inArgHandle=inArgHandles(inArgIdx);
                lh=get_param(inArgHandle,'LineHandles');
                if lh.Outport==-1

                    termH=add_block('simulink/Sinks/Terminator',[simulinkFcnBlk,'/Terminator'],'MakeNameUnique','on');
                    add_line(simulinkFcnBlk,getPortStr(inArgHandle),getPortStr(termH));
                else
                    assert(strcmp(get_param(get_param(lh.Outport,'DstBlockHandle'),'BlockType'),'Terminator'),...
                    'Expect InArg block to be connected to Terminator block');
                end
            end

            for outArgIdx=1:numel(outArgHandles)
                outArgHandle=outArgHandles(outArgIdx);
                lh=get_param(outArgHandle,'LineHandles');
                if lh.Inport==-1

                    groundH=add_block('simulink/Sources/Ground',[simulinkFcnBlk,'/Ground'],'MakeNameUnique','on');
                    add_line(simulinkFcnBlk,getPortStr(groundH),getPortStr(outArgHandle));
                else
                    assert(strcmp(get_param(get_param(lh.Outport,'SrcBlockHandle'),'BlockType'),'Ground'),...
                    'Expect OutArg block to be connected to Ground block');
                end
            end
        end
    end

    methods(Static,Access=private)
        function portStr=getPortStr(blkH)


            blkName=get_param(blkH,'Name');
            portStr=[blkName,'/1'];
        end
    end
end


