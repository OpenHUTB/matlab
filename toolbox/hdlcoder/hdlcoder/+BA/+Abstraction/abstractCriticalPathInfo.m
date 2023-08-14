classdef abstractCriticalPathInfo<handle
    properties(SetAccess=protected,GetAccess=protected)
targetCP_IR
CP_num
abstractedCPNodes
visitedNodes
abstractedComps
    end

    methods

        function thisCP=abstractCriticalPathInfo(cpir,num)
            thisCP.abstractedCPNodes=[];
            thisCP.visitedNodes=[];
            thisCP.abstractedComps=[];
            thisCP.targetCP_IR=cpir;
            thisCP.CP_num=num;
        end



        function printAbstract(thisCP)

            if~isempty(thisCP.abstractedCPNodes)



                for i=1:thisCP.numNodes
                    fprintf(1,'(%d) ',i);
                    printNode(thisCP.abstractedCPNodes(i));
                end
            end
        end


        function num=numNodes(thisCP)
            num=length(thisCP.abstractedCPNodes);
        end


        function resetVisitedNodes(thisCP)
            thisCP.visitedNodes={};
        end



        function addToVisitedNodes(thisCP,node)
            uniqueNodeId=uniqueId(node);
            thisCP.visitedNodes{end+1}=uniqueNodeId;
        end



        function flag=isFirstEncounter(thisCP,node)
            uniqueNodeId=uniqueId(node);
            flag=isempty(find(ismember(thisCP.visitedNodes,uniqueNodeId),1));
        end


        function startNode=getSource(thisCP)
            startNode=thisCP.targetCP_IR.getStartNode(thisCP.CP_num);
        end


        function endNode=getDestination(thisCP)
            endNode=thisCP.targetCP_IR.getEndNode(thisCP.CP_num);
        end


        function node=getNodeName(thisCP,i)
            node=thisCP.abstractedCPNodes(i).identifier;
        end


        function comps=getAbstractedComps(thisCP)
            comps=thisCP.abstractedComps;
        end


        function node=getNode(thisCP,i)
            node=thisCP.abstractedCPNodes(i);
        end
    end

    methods(Static)

        function thisNode=createNode(opType,cd,dt,pirNode,fullPathName,opTypeName)
            if nargin<6
                opTypeName='';
            end
            if nargin<5
                fullPathName='';
            end
            thisNode.identifier=pirNode;
            thisNode.cumulativeDelay=cd;
            thisNode.delayType=dt;
            thisNode.opType=opType;
            thisNode.opTypeName=opTypeName;
            thisNode.fullPathName=fullPathName;
        end


        function match=findMatchingObject(objects,thisObject)
            matchlen=0;
            match=[];
            for i=1:length(objects)



                currmatch=strfind(thisObject,objects(i).Name);
                currlen=length(objects(i).Name);
                if~isempty(currmatch)&&any(currmatch>0)&&(currlen>matchlen)

                    match=objects(i);
                    matchlen=currlen;
                end
            end
        end

    end

    methods(Abstract)

        abstractOutCP(thisCP,p)

        [matchingSignal,matchingParentComp,matchingComp]=abstractOutSignal(thisCP,nodeName,p)
    end
end


function matchingComp=getMatchingComponent(networks,compName)
    matchingComp=[];
    for j=1:length(networks)
        matchingComp=networks(j).findComponent('name',compName);
        if~isempty(matchingComp)
            break;
        end
    end
end


function matchingNetwork=getMatchingNetwork(comp,p)

    matchingNetwork=p.getTopNetwork;


    if~isempty(comp)
        c=getMatchingComponent(p.Networks,comp);
        if~isempty(c)
            matchingNetwork=c.ReferenceNetwork;
        end
    end
end


function printNode(thisNode)
    opType=thisNode.opType;
    if~isempty(opType)
        if~isempty(thisNode.identifier)
            fprintf(1,'%s\tID=%s\t%5.5f\t%s\t%s\n',...
            opType.char,...
            BA.Main.baDriver.getFullPath(thisNode.identifier),...
            thisNode.cumulativeDelay,...
            thisNode.delayType,...
            thisNode.opTypeName);
        else
            fprintf(1,'%s\tFP=%s\t%5.5f\t%s\t%s\n',...
            opType.char,...
            BA.Main.baDriver.getFullPath(thisNode.fullPathName),...
            thisNode.cumulativeDelay,...
            thisNode.delayType,...
            thisNode.opTypeName);
        end
    else
        fprintf(1,'ID=%s\t%5.5f\t%s\n',...
        BA.Main.baDriver.getFullPath(thisNode.identifier),...
        thisNode.cumulativeDelay,...
        thisNode.delayType);
    end
end


function id=uniqueId(signalNode)
    id=[signalNode.Owner.RefNum,signalNode.RefNum];
end
