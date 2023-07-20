function curS=retrieveSignal(idx,criticalPath,pp)



    if(idx>0)
        node=criticalPath(idx);
        if(isempty(node.nwRef)||isempty(node.sigRef))
            curS.signal=[];
        else
            nw=pp.findNetwork('refnum',node.nwRef);
            curS.signal=nw.findSignal('refnum',node.sigRef);
        end
        curS.latency=node.latency;
        curS.cpIdx=idx;
    else
        curS.signal=[];
        curS.latency=0;
        curS.cpIdx=0;
    end
end


