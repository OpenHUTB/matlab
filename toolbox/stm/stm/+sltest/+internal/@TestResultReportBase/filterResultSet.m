function oTree=filterResultSet(inTree,resultSetCoverage)












    if(resultSetCoverage<0)
        oTree=inTree;
        return;
    end;

    oTree=[];
    numOfNodes=0;
    positionMap=Simulink.sdi.Map;
    parentMap=Simulink.sdi.Map;

    nNodes=length(inTree);
    for nodeK=1:nNodes
        node=inTree(nodeK);

        toHide=false;
        cM=sltest.internal.TestResultReportBase.getCountMetricsOfResult(node.data);


        if(resultSetCoverage==1)
            if(cM.numOfPassed==0)
                toHide=true;
            end;

        elseif(resultSetCoverage==2)
            if(cM.numOfFailed==0)
                toHide=true;
            end;
        end

        if(~toHide)
            oTree=[oTree,node];
            numOfNodes=numOfNodes+1;
            positionMap.insert(node.UID,numOfNodes);

            if(node.parentIndex>0)
                parentNode=inTree(node.parentIndex);
                parentMap.insert(node.UID,parentNode.UID);
            end
        end
    end;


    nNodes=length(oTree);
    for nodeK=1:nNodes
        node=oTree(nodeK);
        if(node.parentIndex<0)
            continue;
        end
        parentID=parentMap.getDataByKey(node.UID);
        positionOfParent=positionMap.getDataByKey(parentID);
        oTree(nodeK).parentIndex=positionOfParent;
    end
end