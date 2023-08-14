function criticalPathSet=backAnnotateCPE(gp,guidedCPFileName)





    guidedRetimingStage=5;

    pp=gp.getTopPirCtx;
    nets=pp.Networks;
    criticalPathSet=struct();
    sigLatencyMap=containers.Map('KeyType','char','ValueType','any');
    CP_nodes=[];
    criticalPath=struct('nwRef',{},'sigRef',{},'latency',{});
    s=[];


    for n=1:numel(nets)
        components=nets(n).Components;
        for c=1:numel(components)
            if~isempty(components(c))&&components(c).getOnCriticalPath
                CP_nodes=[CP_nodes,components(c)];
            end
        end
    end
    if isempty(CP_nodes)
        return
    end


    for n=1:numel(CP_nodes)
        node=CP_nodes(n);
        sig=node.PirOutputSignals;
        if numel(sig)>1

            temp=getSigOnCP(sig);
            if temp==-1

                sig=sig(1);
            else

                sig=temp;
            end
        end

        l=node.getCriticalPathDelay(0);
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
            if(sigLatencyMap.isKey(sigRefNum))
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




    for n=1:numel(CP_nodes)
        node=CP_nodes(n);
        sig=node.PirOutputSignals;

        if numel(sig)>1

            temp=getSigOnCP(sig);
            if temp==-1

                sig=sig(1);
            else

                sig=temp;
            end
        end

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



    cpLatency=gp.getCriticalPathDelay;
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
    end


    criticalPathSet.cp=sortedCriticalPath;
    criticalPathSet.ctxName=pp.ModelName;
    tempData.criticalPathSet=criticalPathSet;
    qoroptimizations.saveFile(guidedCPFileName,tempData,pp.ModelName);
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

function sig=getSigOnCP(signals)
    for i=1:numel(signals)
        receivers=signals(i).getReceivers;
        for j=1:numel(receivers)
            if receivers(j).Component.getOnCriticalPath
                sig=signals(i);
                return;
            end
        end
    end
    sig=-1;

end


