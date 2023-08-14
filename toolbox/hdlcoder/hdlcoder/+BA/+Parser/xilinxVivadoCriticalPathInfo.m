


classdef xilinxVivadoCriticalPathInfo<BA.Parser.criticalPathInfo

    methods


        function thisCP=xilinxVivadoCriticalPathInfo
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
            cpnode=BA.Parser.criticalPathInfo.createNode(loc,cumulativeDelay,delayType,name,'Xilinx Vivado');
            thisCP.criticalPathNodes=[thisCP.criticalPathNodes,cpnode];
        end


        function printNode(~,thisNode)
            if isempty(thisNode)
                return;
            end
            fprintf(1,'%s\t%5.5f\t%s\n',...
            BA.Main.baDriver.getFullPath(thisNode.identifier,'XilinxVivado'),...
            thisNode.cumulativeDelay,...
            thisNode.delayType);
        end

    end

end


