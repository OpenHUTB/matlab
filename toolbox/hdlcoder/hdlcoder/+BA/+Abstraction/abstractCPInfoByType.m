classdef abstractCPInfoByType<BA.Abstraction.abstractCriticalPathInfo
    properties(Constant=true)
        LOOKAHEADSTEP=10;
    end
    properties(SetAccess=protected,GetAccess=protected)
unknownAbstractedCPNodes
unknownAbstractedCPNodeMap
abstractedCPNodeMap
    end
    methods

        function thisCP=abstractCPInfoByType(cpir,num)
            thisCP@BA.Abstraction.abstractCriticalPathInfo(cpir,num);
            thisCP.unknownAbstractedCPNodes=[];
            thisCP.unknownAbstractedCPNodeMap=containers.Map('KeyType','int32','ValueType','int32');
            thisCP.abstractedCPNodeMap=containers.Map('KeyType','int32','ValueType','int32');
        end


        function value=getUnknownAbstractedCPNodeIndex(thisCP,abstractedCPNodeIndex)
            value=-1;
            if isKey(thisCP.unknownAbstractedCPNodeMap,abstractedCPNodeIndex)
                value=thisCP.unknownAbstractedCPNodeMap(abstractedCPNodeIndex);
            end
        end


        function value=getAbstractedCPNodeIndex(thisCP,unknownAbstractedCPNodeIndex)
            value=-1;
            if isKey(thisCP.abstractedCPNodeMap,unknownAbstractedCPNodeIndex)
                value=thisCP.abstractedCPNodeMap(unknownAbstractedCPNodeIndex);
            end
        end



        function abstractOutCP(thisCP,p)
            if~isempty(thisCP.abstractedCPNodes)

                return;
            end
            for i=1:thisCP.targetCP_IR.getNumNodes(thisCP.CP_num)
                nodeName=thisCP.targetCP_IR.getCPNode(thisCP.CP_num,i);


                cumDelay=thisCP.targetCP_IR.getCPNodeCumulativeLatency(thisCP.CP_num,i);

                opType=thisCP.targetCP_IR.getCPNodeType(thisCP.CP_num,i);

                opTypeName=thisCP.targetCP_IR.getCPNodeTypeName(thisCP.CP_num,i);



                [matchingSignal,matchingParentComp,matchingComp]=thisCP.abstractOutSignal(nodeName,p);

                if~isempty(matchingSignal)||~isempty(matchingComp)
                    if isempty(matchingSignal)
                        matchingSignal=matchingComp.PirOutputSignals(1);
                    end
                    if isempty(thisCP.abstractedCPNodes)...
                        ||isempty(thisCP.abstractedCPNodes(end).identifier)...
                        ||(thisCP.abstractedCPNodes(end).identifier.getUniqId~=matchingSignal.getUniqId)

                        newNode=BA.Abstraction.abstractCriticalPathInfo.createNode(opType,...
                        cumDelay,...
                        'abstract',...
                        matchingSignal,...
                        nodeName,...
                        opTypeName);
                        thisCP.abstractedCPNodes=[thisCP.abstractedCPNodes,newNode];
                        abstractedCPNodeIndex=length(thisCP.abstractedCPNodes);
                        if newNode.opType==BA.Abstraction.OPTYPE.UNKNOWN
                            thisCP.unknownAbstractedCPNodes=[thisCP.unknownAbstractedCPNodes,newNode];
                            unknownAbstractedCPNodeIndex=length(thisCP.unknownAbstractedCPNodes);
                            thisCP.unknownAbstractedCPNodeMap(abstractedCPNodeIndex)=unknownAbstractedCPNodeIndex;
                            thisCP.abstractedCPNodeMap(unknownAbstractedCPNodeIndex)=abstractedCPNodeIndex;
                        end
                    else

                        thisCP.abstractedCPNodes(end).cumulativeDelay=cumDelay;
                    end
                else


                    if~isempty(matchingParentComp)&&...
                        (isempty(thisCP.abstractedComps)||(thisCP.abstractedComps(end).getUniqId~=matchingParentComp.getUniqId))
                        thisCP.abstractedComps=[thisCP.abstractedComps,matchingParentComp];
                    end



                    if isempty(thisCP.abstractedCPNodes)||~strcmp(thisCP.abstractedCPNodes(end).opTypeName,opTypeName)
                        newNode=BA.Abstraction.abstractCriticalPathInfo.createNode(opType,cumDelay,'abstract','',nodeName,opTypeName);
                        thisCP.abstractedCPNodes=[thisCP.abstractedCPNodes,newNode];
                    else

                        thisCP.abstractedCPNodes(end).cumulativeDelay=cumDelay;
                    end
                end

            end
        end



        function[cpnode,cpnodeIndex]=getSkippedNodeMatch(thisCP,startIndex,node)
            cpnode=[];
            cpnodeIndex=-1;
            [pirOpType,~,dim]=BA.Algorithm.OperationType.get(node);
            if dim==1
                return;
            end

            match=false;
            for i=startIndex:(startIndex+int32(dim)-1)
                thisnode=thisCP.abstractedCPNodes(i);
                if pirOpType==thisnode.opType...
                    &&thisCP.matchHierPath(thisnode.fullPathName,node)
                    match=true;
                    cpnode=thisnode;
                    cpnodeIndex=i;
                elseif thisnode.opType==BA.Abstraction.OPTYPE.UNKNOWN
                    if thisnode.identifier.getUniqId==node.getUniqId

                        cpnode=thisnode;
                        cpnodeIndex=i;
                        return;
                    else
                        continue;
                    end
                elseif thisnode.opType==BA.Abstraction.OPTYPE.RELOP

                    continue;
                elseif match
                    return;
                end
            end
        end


        function[cpnode,cpnodeIndex]=getInternalHierNodeMatch(thisCP,startIndex,pirSignal)
            cpnode=[];
            comp=[];
            cpnodeIndex=-1;
            driver=pirSignal.getDrivers;
            if~isempty(driver)&&length(driver)==1
                comp=driver.Owner;
            end
            if isempty(comp)||strcmp(comp.ClassName,'network')
                return;
            end
            if comp.isNetworkInstance&&comp.SimulinkHandle==-1

                endIndex=startIndex+thisCP.LOOKAHEADSTEP;
                if endIndex>thisCP.numNodes
                    endIndex=thisCP.numNodes;
                end
                foundBefore=false;

                for i=startIndex:endIndex
                    thisnode=thisCP.abstractedCPNodes(i);
                    nodePath=thisnode.fullPathName;
                    numLevels=numel(nodePath)-2;
                    if numLevels<=0
                        continue;
                    end
                    found=true;
                    tempComp=comp;

                    while~isempty(tempComp)
                        if numLevels>0&&~strcmp(tempComp.Name,nodePath(numLevels))
                            found=false;
                        end
                        numLevels=numLevels-1;
                        tempComp=tempComp.Owner.instances;
                    end
                    if found

                        cpnode=thisnode;
                        cpnodeIndex=i;
                    elseif foundBefore
                        return;
                    end
                    foundBefore=found;
                end
            end
        end


        function flag=matchHierPath(thisCP,nodePath,pirNode)
            flag=true;
            numLevels=numel(nodePath)-2;
            instances=pirNode.Owner.instances;
            if isempty(instances)&&numLevels==0

                return;
            end
            if numLevels<0
                flag=false;
                return;
            end
            for j=1:numLevels
                comp=nodePath{j};
                if strcmpi(comp,'auto_generated')...
                    ||strcmpi(comp,'mult_core')


                    return;
                end
            end


            flag=thisCP.isInstMatchAtLevel(numLevels,instances,nodePath);








        end


        function flag=isInstMatchAtLevel(thisCP,numLevels,instances,nodePath)
            if isempty(instances)&&numLevels>0

                flag=false;
                return;
            end
            if numLevels==0
                flag=true;
                return;
            end
            flag=false;
            for i=1:length(instances)
                currInstance=instances(i);
                if~isempty(currInstance)...
                    &&strcmp(currInstance.Name,nodePath(numLevels))
                    newInstances=currInstance.Owner.instances;
                    if thisCP.isInstMatchAtLevel(numLevels-1,newInstances,nodePath)
                        flag=true;
                        return;
                    end
                end
            end
        end


        function[cpnode,cpnodeIndex,opMatch]=nodeInAbstractedCP(thisCP,node,startIndex,preferLast)
            if nargin<4
                preferLast=false;
            end
            cpnode=[];
            cpnodeIndex=-1;
            opMatch=false;
            unknownCPStartIndex=0;

            for i=startIndex:thisCP.numNodes
                unknownCPStartIndex=thisCP.getUnknownAbstractedCPNodeIndex(i);
                if unknownCPStartIndex>0
                    break;
                end
            end
            if unknownCPStartIndex>0
                for i=unknownCPStartIndex:length(thisCP.unknownAbstractedCPNodes)
                    thisnode=thisCP.unknownAbstractedCPNodes(i);

                    if~isempty(thisnode.identifier)...
                        &&thisnode.identifier.getUniqId==node.getUniqId
                        cpnode=thisnode;
                        cpnodeIndex=thisCP.getAbstractedCPNodeIndex(i);
                        if~preferLast
                            return;
                        end
                    end
                end
            end
            if~isempty(cpnode)
                return;
            end


            if BA.Algorithm.OperationType.get(node)==BA.Abstraction.OPTYPE.UNKNOWN
                return;
            end

            currIndex=startIndex;
            if startIndex==1
                endIndex=1;
            else
                endIndex=startIndex-1;
            end
            if startIndex+1<thisCP.numNodes
                startIndex=startIndex+1;
            end
            if startIndex==thisCP.numNodes
                startIndex=thisCP.numNodes-1;
            end



            for i=[currIndex,startIndex,endIndex,(startIndex+1)]


                if i<1
                    continue;
                end
                thisnode=thisCP.abstractedCPNodes(i);
                [cpnode,cpnodeIndex]=thisCP.getInternalHierNodeMatch(currIndex,node);
                if~isempty(cpnode)
                    return;
                end
                [cpnode,cpnodeIndex]=thisCP.getSkippedNodeMatch(currIndex,node);
                if~isempty(cpnode)
                    return;
                end
                if thisCP.matchHierPath(thisnode.fullPathName,node)...
                    &&(thisnode.opType==BA.Algorithm.OperationType.get(node))
                    cpnode=thisnode;
                    cpnodeIndex=i;
                    opMatch=true;
                    if~preferLast
                        return;
                    end
                end
            end
        end


        function[matchingSignal,matchingParentComp,matchingComp]=abstractOutSignal(thisCP,nodeName,p)

            tn=p.getTopNetwork;
            nic=[];
            earlyBreak=false;
            lastcomp=[];

            for j=1:numel(nodeName)-1
                comp=nodeName{j};
                if strcmpi(comp,'auto_generated')

                    nodeName=lastcomp;
                    earlyBreak=true;
                    break;
                end
                c=tn.findComponent('name',comp);
                lastcomp=comp;
                if isempty(c)
                    if j==numel(nodeName)-1

                        nodeName=comp;
                        earlyBreak=true;
                        break;
                    end
                else
                    if(c.isNetworkInstance)
                        tn=c.ReferenceNetwork;
                        nic=c;
                    end
                end
            end
            if~earlyBreak
                nodeName=nodeName{end};
            end


            matchingSignal=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Signals,nodeName);
            matchingParentComp=nic;




            matchingComp=[];
            if isempty(matchingSignal)
                matchingComp=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Components,nodeName);
            end
        end
    end

end


