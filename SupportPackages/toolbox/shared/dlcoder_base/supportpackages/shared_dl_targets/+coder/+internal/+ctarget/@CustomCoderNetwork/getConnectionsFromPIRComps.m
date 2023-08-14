function connections=getConnectionsFromPIRComps(layerComps)

















    endNodes=[];
    endPorts={};

    for iComp=1:numel(layerComps)
        aComp=layerComps(iComp);

        for iEdge=1:aComp.getNumIn
            if~iIsCompHasInputConnectionToNetwork(aComp,iEdge)
                sourceCompInfo=aComp.getSourceCompIndexAndPortIndex(iEdge-1);




                endNodes=[endNodes;(sourceCompInfo(1)+1),iComp];
                endPorts{end+1,1}=[(sourceCompInfo(2)+1),iEdge];
            end
        end
    end

    connections=table(endNodes,endPorts,'VariableNames',{'EndNodes','EndPorts'});

end

function isaIpConnectionToNetwork=iIsCompHasInputConnectionToNetwork(aComp,inPortIdx)




    hSignal=aComp.PirInputSignals(inPortIdx);
    isaIpConnectionToNetwork=hSignal.isNetworkInSignal;
end
