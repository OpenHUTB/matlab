


classdef alteraCriticalPathInfo<BA.Parser.criticalPathInfo

    methods


        function thisCP=alteraCriticalPathInfo
            thisCP@BA.Parser.criticalPathInfo;
        end


        function addToCriticalPath(thisCP,loc,delayType,delay,name,cumDelay)
            if nargin<6
                cumDelay=0;
            end
            if cumDelay>0
                cumulativeDelay=cumDelay;
            else
                cumulativeDelay=delay;
                if~isempty(thisCP.criticalPathNodes)
                    cumulativeDelay=thisCP.criticalPathNodes(end).cumulativeDelay+delay;
                end
            end
            cpnode=BA.Parser.criticalPathInfo.createNode(loc,cumulativeDelay,delayType,name,'Altera');
            [cpnode.opType,cpnode.opTypeName]=BA.Parser.alteraCriticalPathInfo.getOpType(cpnode);
            thisCP.criticalPathNodes=[thisCP.criticalPathNodes,cpnode];
        end


        function printNode(thisCP,thisNode)
            if isempty(thisNode)
                return;
            end
            optype=thisNode.opType;
            if length(thisNode.identifier)==1
                fprintf(1,'%s\t%5.5f\t%s\t%s\t%s\n',thisNode.identifier{:},...
                thisNode.cumulativeDelay,...
                thisNode.delayType,...
                optype.char,...
                thisNode.opTypeName);
            else
                fprintf(1,'%s\t%5.5f\t%s\t%s\t%s\n',BA.Main.baDriver.getFullPath(thisNode.identifier,'Altera'),...
                thisNode.cumulativeDelay,...
                thisNode.delayType,...
                optype.char,...
                thisNode.opTypeName);
            end
        end

    end

    methods(Static)
        function[optype,optypeName]=getOpType(cpnode)
            import BA.Abstraction.*;
            hierarchicalName=cpnode.identifier;
            optype=OPTYPE.UNKNOWN;
            optypeName=BA.Main.baDriver.getFullPath(hierarchicalName,'Altera');
            hierDepth=numel(hierarchicalName);
            if hierDepth==1
                return;
            end



            for i=hierDepth-1:-1:1
                name=hierarchicalName{i};
                if strncmp(name,'Add',3)
                    optype=OPTYPE.ADD;
                    optypeName=strtok(name,'~');
                    return;
                elseif strncmp(name,'Mult',4)
                    optype=OPTYPE.MULT;
                    optypeName=strtok(name,'~');
                    return;
                elseif strncmp(name,'Equal',5)
                    optype=OPTYPE.RELOP;
                    optypeName=strtok(name,'~');
                    return;
                elseif strncmp(name,'LessThan',8)
                    optype=OPTYPE.RELOP;
                    optypeName=strtok(name,'~');
                    return;
                end
            end
        end
    end

end
