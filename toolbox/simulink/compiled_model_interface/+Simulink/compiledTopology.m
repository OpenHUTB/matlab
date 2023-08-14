


classdef compiledTopology<handle
    properties
slh
sess
bdo
ct
isTerminated
    end

    methods
        function topo=compiledTopology(bd)
            topo.slh=slsvTestingHook('TG_DebugSLTopo',32);
            topo.sess=Simulink.CMI.CompiledSession;
            topo.bdo=Simulink.CMI.CompiledBlockDiagram(topo.sess,bd);
            setWantTopology(topo.bdo,topo.sess);
            init(topo.bdo);
            topo.ct=getTopology(topo.bdo,topo.sess);
            topo.isTerminated=false;
        end

        function delete(topo)
            if~topo.isTerminated
                term(topo.bdo);
            end
            slsvTestingHook('TG_DebugSLTopo',topo.slh);
        end

        function term(topo)
            if~topo.isTerminated
                term(topo.bdo);
                topo.isTerminated=true;
            end
        end

        function printForwardConnectivity(obj,handle)
            bl=getChildrenBlocks(obj.ct,handle);
            for idx=1:numel(bl)
                blk=bl(idx);
                pa=getOutputPorts(obj.ct,blk);
                for pidx=1:numel(pa)
                    dstp=getDstPorts(obj.ct,pa(pidx));
                    for didx=1:numel(dstp)
                        fprintf('%s/%d -> %s/%d\n',...
                        replaceNewLine(obj,[get_param(blk,'Parent'),'/',get_param(blk,'Name')]),...
                        get_param(pa(pidx),'PortNumber'),...
                        replaceNewLine(obj,get_param(dstp(didx),'Parent')),...
                        get_param(dstp(didx),'PortNumber'));
                    end
                end
                cbl=getChildrenBlocks(obj.ct,blk);
                if~isempty(cbl)
                    printForwardConnectivity(obj,blk)
                end
            end
        end

        function printConnectivity(obj,handle)
            bl=getChildrenBlocks(obj.ct,handle);
            for idx=1:numel(bl)
                blk=bl(idx);
                pa=getInputPorts(obj.ct,blk);
                if isempty(pa)
                    fprintf('Block %s has no source port\n',replaceNewLine(obj,[get_param(blk,'Parent'),'/',get_param(blk,'Name')]));
                end
                for pidx=1:numel(pa)
                    srcp=getSrcPorts(obj.ct,pa(pidx));
                    if isempty(srcp)
                        fprintf(' -> %s/%d\n',replaceNewLine(obj,[get_param(blk,'Parent'),'/',get_param(blk,'Name')]),...
                        get_param(pa(pidx),'PortNumber'));
                        continue;
                    end
                    fprintf('%s/%d -> %s/%d\n',replaceNewLine(obj,get_param(srcp,'Parent')),...
                    get_param(srcp,'PortNumber'),...
                    replaceNewLine(obj,[get_param(blk,'Parent'),'/',get_param(blk,'Name')]),...
                    get_param(pa(pidx),'PortNumber'));
                end
                cbl=getChildrenBlocks(obj.ct,blk);
                if~isempty(cbl)
                    printConnectivity(obj,blk);
                end
            end
        end

        function s=replaceNewLine(~,t)
            s=strrep(t,char(10),[char(92),char(110)]);
        end
    end
end


