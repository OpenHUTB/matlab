function[criticalPathSet,cpManager]=backAnnotate(cp_ir,guidedCPFileName)


    guidedRetimingStage=5;
    criticalPathSet=struct('cp',{},'ctxName',{});

    cpManager=hdlcoder.criticalpathmanager.create;
    ctxName='';
    pp=[];

    sigLatencyMap=containers.Map('KeyType','char','ValueType','any');

    for i=1:cp_ir.numAbstracted
        absCP=cp_ir.getAbstractedCP(i);
        if(absCP.numNodes==0)
            continue;
        end
        if(isempty(pp))
            ctxName=absCP.getNode(1).identifier.Owner.getCtxName;
            pp=pir(ctxName);
        else
            if(absCP.numNodes>0)
                assert(isequal(ctxName,absCP.getNode(1).identifier.Owner.getCtxName));
            end
        end


        for j=1:absCP.numNodes
            node=absCP.getNode(j);
            sig=node.identifier;
            l=qoroptimizations.getCPIRNodeAccumulativeLatency(node,cp_ir.getCP(i));
            newsRefNum=pp.traceBackSignal(sig,guidedRetimingStage);
            if(isempty(newsRefNum))
                newsRefNumUp=pp.traceBackSignalUpstream(sig,guidedRetimingStage);
                newsRefNumDown=pp.traceBackSignalDownstream(sig,guidedRetimingStage);
                newsRefNum=[newsRefNumUp,newsRefNumDown];
            end
            match=regexp(newsRefNum,'(n\d+)_(s\d+)','tokens','once');
            if(isempty(match))


                continue;
            end
            for k=1:length(newsRefNum)
                sigRefNum=newsRefNum{k};
                if(sigLatencyMap.isKey(sigRefNum));
                    tempLatency=sigLatencyMap(sigRefNum);
                else
                    tempLatency.maxL=0;
                    tempLatency.minL=inf;
                end
                tempLatency.maxL=max(tempLatency.maxL,l);
                tempLatency.minL=min(tempLatency.minL,l);
                sigLatencyMap(sigRefNum)=tempLatency;
            end
        end
    end

    if(isempty(pp))
        tempData.criticalPathSet=criticalPathSet;
        qoroptimizations.saveFile(guidedCPFileName,tempData,ctxName);
        return;
    end


    for i=1:cp_ir.numAbstracted
        absCP=cp_ir.getAbstractedCP(i);

        criticalPath=struct('nwRef',{},'sigRef',{},'latency',{});
        s=[];
        cp=cpManager.newCriticalPath();


        for j=1:absCP.numNodes
            node=absCP.getNode(j);
            sig=node.identifier;
            newsRefNum=pp.traceBackSignal(sig,guidedRetimingStage);
            if(~isempty(newsRefNum))
                match=regexp(newsRefNum,'(n\d+)_(s\d+)','tokens','once');
                for k=1:length(newsRefNum)
                    s.nwRef=match{k}{1};
                    s.sigRef=match{k}{2};
                    s.latency=sigLatencyMap(newsRefNum{k}).maxL;




                    [found,~]=isNodeInCP(s,criticalPath);
                    if(~found)
                        criticalPath(end+1)=s;
                    end
                end
            else
                newsRefNumUp=pp.traceBackSignalUpstream(sig,guidedRetimingStage);
                match=regexp(newsRefNumUp,'(n\d+)_(s\d+)','tokens','once');
                for k=1:length(match)
                    s.nwRef=match{k}{1};
                    s.sigRef=match{k}{2};

                    s.latency=sigLatencyMap(newsRefNumUp{k}).minL;

                    [found,~]=isNodeInCP(s,criticalPath);
                    if(~found)
                        criticalPath(end+1)=s;
                    end
                end
                newsRefNumDown=pp.traceBackSignalDownstream(sig,guidedRetimingStage);
                match=regexp(newsRefNumDown,'(n\d+)_(s\d+)','tokens','once');
                for k=1:length(match)
                    s.nwRef=match{k}{1};
                    s.sigRef=match{k}{2};

                    s.latency=sigLatencyMap(newsRefNumDown{k}).maxL;

                    [found,~]=isNodeInCP(s,criticalPath);
                    if(~found)
                        criticalPath(end+1)=s;
                    end
                end
            end
        end
        cpLatency=qoroptimizations.getCPIRNodeAccumulativeLatency(absCP.getNode(absCP.numNodes),cp_ir.getCP(i));
        if(criticalPath(end).latency<cpLatency)


            s.nwRef='';
            s.sigRef='';
            s.latency=cpLatency;
            criticalPath(end+1)=s;
        end


        sortedCriticalPath=struct('nwRef',{},'sigRef',{},'latency',{});
        latencies=[criticalPath.latency];
        [~,indices]=sort(latencies);
        for j=1:length(indices)
            snode=criticalPath(indices(j));
            sortedCriticalPath(j)=snode;
            cp.addNode(snode.nwRef,snode.sigRef,snode.latency);
        end

        criticalPathSet(i).cp=sortedCriticalPath;
        criticalPathSet(i).ctxName=ctxName;
    end

    tempData.criticalPathSet=criticalPathSet;
    qoroptimizations.saveFile(guidedCPFileName,tempData,ctxName);

end

function[found,i]=isNodeInCP(node,cpNodes)
    for i=1:length(cpNodes)
        cpNode=cpNodes(i);
        try
            if(isequal(cpNode.nwRef,node.nwRef)&&(isequal(cpNode.sigRef,node.sigRef)))
                found=true;
                return;
            end
        catch me
            rethrow(me);
        end
    end
    found=false;
end

function found=isNodeInCPSet(node,cpSet)
    for i=1:length(cpSet)
        cp=cpSet(i).cp;

        if(isNodeInCP(node,cp))
            found=true;
            return;
        end
    end
    found=false;
end

