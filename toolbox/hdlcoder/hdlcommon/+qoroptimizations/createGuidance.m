function guidance=createGuidance(pp,criticalPathSet,expLatency,existGuidanceSet)






    guidanceSet=struct('nwRef',{},'sigRef',{});
    guidance.guidanceSet=guidanceSet;
    guidance.optimalLatency=qoroptimizations.getOptimalLatency(criticalPathSet,pp);


    for i=1:length(criticalPathSet)
        criticalPath=criticalPathSet(i).cp;
        lastS=qoroptimizations.retrieveSignal(0);
        lastAccS=qoroptimizations.retrieveSignal(0);
        for j=1:length(criticalPath)

            curS=qoroptimizations.retrieveSignal(j,criticalPath,pp);

            curStackedL=curS.latency-lastAccS.latency;
            while(curStackedL>expLatency)
                if(lastS.latency==lastAccS.latency)



                    guidance.optimalLatency=max(guidance.optimalLatency,curStackedL);




                    return;





                end

                assert(~isempty(lastS.signal));



                candiS=locateInsertionPoint(lastS,lastAccS,criticalPath,pp,existGuidanceSet);
                if(isempty(candiS.signal))




                    guidance.optimalLatency=max(guidance.optimalLatency,curStackedL);




                    return;




                end
                guidanceNode.nwRef=candiS.signal.Owner.refnum;
                guidanceNode.sigRef=candiS.signal.refnum;
                lastAccS=candiS;

                if(~isNodeInCP(guidanceNode,guidanceSet));
                    guidanceSet=addNodeToGuidanceSet(guidanceSet,guidanceNode,candiS.signal);
                end

                curStackedL=curS.latency-lastAccS.latency;
            end

            lastS=curS;
        end
    end

    guidance.guidanceSet=guidanceSet;
end

function guidanceSet=addNodeToGuidanceSet(guidanceSet,guidanceNode,signal)
    guidanceSet(end+1)=guidanceNode;

    signal.addGuidedRetimingPipelineDelay();
end

function candiS=locateInsertionPoint(curS,lastAccS,criticalPath,pp,guidanceSet)
    assert(curS.cpIdx>0);
    if(curS.cpIdx==lastAccS.cpIdx)
        candiS=qoroptimizations.retrieveSignal(0);
        return;
    end



    if(...
        qoroptimizations.isValidInsertionPoint(curS)&&...
        ~isSigInCP(curS.signal,guidanceSet))
        candiS=curS;
        return;
    end

    if(curS.cpIdx==1)
        candiS=qoroptimizations.retrieveSignal(0);
        return;
    end

    lastS=qoroptimizations.retrieveSignal(curS.cpIdx-1,criticalPath,pp);
    candiS=locateInsertionPoint(lastS,lastAccS,criticalPath,pp,guidanceSet);
end

function found=isNodeInCP(node,guidanceSet)
    for i=1:length(guidanceSet)
        cpNode=guidanceSet(i);

        if(isequal(cpNode.nwRef,node.nwRef)&&(isequal(cpNode.sigRef,node.sigRef)))
            found=true;
            return;
        end
    end
    found=false;
end

function found=isSigInCP(sig,guidanceSet)
    node.nwRef=sig.Owner.refnum;
    node.sigRef=sig.refnum;

    found=isNodeInCP(node,guidanceSet);
end


