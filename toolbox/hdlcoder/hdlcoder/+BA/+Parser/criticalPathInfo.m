




classdef criticalPathInfo<handle
    properties(SetAccess=protected,GetAccess=protected)
source
destination
criticalPathNodes
        offsetDelay=0.0
        dataPathDelay=0.0
        requirement=0.0
        clockPathDelay=0.0
        clockUncertainty=0.0
    end

    methods

        function thisCP=criticalPathInfo
            thisCP.criticalPathNodes=[];
        end


        function printOriginal(thisCP)




            for i=1:thisCP.numNodes
                fprintf(1,'(%d) ',i);
                thisCP.printNode(thisCP.getNode(i));
            end

        end


        function num=numNodes(thisCP)
            num=length(thisCP.criticalPathNodes);
        end


        function node=getNode(thisCP,i)
            node=thisCP.criticalPathNodes(i);
        end



        function cumDelay=getCumulativeDelay(thisCP,nodeName)
            cumDelay=-1;
            for i=1:thisCP.numNodes
                thisNode=thisCP.getNode(i);
                if strcmp(thisNode.name,nodeName)
                    cumDelay=thisNode.cumulativeDelay;
                    return;
                end
            end
        end


        function setSource(thisCP,s)
            thisCP.source=s;
        end


        function s=getSource(thisCP)
            s=thisCP.source;
        end


        function setDestination(thisCP,d)
            thisCP.destination=d;
        end


        function s=getDestination(thisCP)
            s=thisCP.destination;
        end


        function setOffset(thisCP,o)
            thisCP.offsetDelay=o;
        end


        function o=getOffset(thisCP)
            o=thisCP.offsetDelay;
        end


        function setRequirement(thisCP,o)
            thisCP.requirement=o;
        end


        function o=getRequirement(thisCP)
            o=thisCP.requirement;
        end


        function setDataPathDelay(thisCP,dpd)
            thisCP.dataPathDelay=dpd;
        end


        function o=getDataPathDelay(thisCP)
            o=thisCP.dataPathDelay;
        end


        function setClockPathDelay(thisCP,cpd)
            thisCP.clockPathDelay=cpd;
        end


        function o=getClockPathDelay(thisCP)
            o=thisCP.clockPathDelay;
        end


        function setClockUncertainty(thisCP,cu)
            thisCP.clockUncertainty=cu;
        end


        function o=getClockUncertainty(thisCP)
            o=thisCP.clockUncertainty;
        end

    end

    methods(Abstract)

        addToCriticalPath(thisCP,loc,delayType,delay,name,cumDelay)

        printNode(thisCP,thisNode)
    end

    methods(Static)

        function thisNode=createNode(l,cd,dt,n,target)
            import BA.Main.*;
            thisNode.identifier=BA.Main.baDriver.flattenHierarchicalNames(n,target);
            thisNode.cumulativeDelay=cd;
            thisNode.delayType=dt;
            thisNode.location=l;
            thisNode.opType=BA.Abstraction.OPTYPE.UNKNOWN;
            thisNode.opTypeName='';
        end


    end
end


