classdef abstractCPInfoByName<BA.Abstraction.abstractCriticalPathInfo

    methods

        function thisCP=abstractCPInfoByName(cpir,num)
            thisCP@BA.Abstraction.abstractCriticalPathInfo(cpir,num);
        end



        function abstractOutCP(thisCP,p)
            if~isempty(thisCP.abstractedCPNodes)

                return;
            end
            for i=1:thisCP.targetCP_IR.getNumNodes(thisCP.CP_num)
                nodeName=thisCP.targetCP_IR.getCPNode(thisCP.CP_num,i);

                cumDelay=thisCP.targetCP_IR.getCPNodeCumulativeLatency(thisCP.CP_num,i);



                [matchingSignal,matchingParentComp,matchingComp]=thisCP.abstractOutSignal(nodeName,p);

                if~isempty(matchingSignal)||(~isempty(matchingComp)&&~isempty(matchingComp.PirOutputSignals))
                    if isempty(matchingSignal)
                        matchingSignal=matchingComp.PirOutputSignals(1);
                    end
                    if isempty(thisCP.abstractedCPNodes)||(thisCP.abstractedCPNodes(end).identifier.getUniqId~=matchingSignal.getUniqId)

                        newNode=BA.Abstraction.abstractCriticalPathInfo.createNode([],...
                        cumDelay,...
                        'abstract',...
                        matchingSignal);
                        thisCP.abstractedCPNodes=[thisCP.abstractedCPNodes,newNode];
                    else

                        thisCP.abstractedCPNodes(end).cumulativeDelay=cumDelay;
                    end
                else


                    if~isempty(matchingParentComp)&&...
                        (isempty(thisCP.abstractedComps)||(thisCP.abstractedComps(end).getUniqId~=matchingParentComp.getUniqId))
                        thisCP.abstractedComps=[thisCP.abstractedComps,matchingParentComp];
                    end
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
            matched=false;
            if comp.isNetworkInstance&&comp.SimulinkHandle==-1
                for i=startIndex:thisCP.numNodes

                    thisnode=thisCP.abstractedCPNodes(i);
                    if strcmp(thisnode.identifier.Owner.RefNum,comp.ReferenceNetwork.RefNum)

                        cpnode=thisnode;
                        cpnodeIndex=i;
                        matched=true;
                    elseif matched
                        return;
                    end
                end
            end
        end


        function[cpnode,cpnodeIndex,isHierMatch]=nodeInAbstractedCP(thisCP,node,startIndex,preferLast)
            if nargin<4
                preferLast=false;
            end
            isHierMatch=false;
            [cpnode,cpnodeIndex]=getInternalHierNodeMatch(thisCP,startIndex,node);
            if~isempty(cpnode)
                isHierMatch=true;
                return;
            end
            for i=startIndex:thisCP.numNodes
                thisnode=thisCP.abstractedCPNodes(i);
                if(thisnode.identifier.getUniqId==node.getUniqId)
                    cpnode=thisnode;
                    cpnodeIndex=i;
                    if~preferLast
                        return;
                    end
                end
            end
        end


        function[matchingSignal,matchingParentComp,matchingComp]=abstractOutSignal(thisCP,nodeName,p)

            tn=p.getTopNetwork;
            nic=[];
            comp=[];
            for j=1:numel(nodeName)-1
                node=nodeName{j};

                comp=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Components,node);
                if isempty(comp)
                    fprintf(1,'Warning: Block ''%s'' in ''%s'' not locatable.\n',...
                    comp,BA.Main.baDriver.getFullPath(nodeName));
                else
                    nic=comp;
                    if(comp.isNetworkInstance)
                        tn=comp.ReferenceNetwork;
                    else
                        break;
                    end
                end
            end
            nodeName=nodeName{end};


            matchingSignal=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Signals,nodeName);
            matchingParentComp=nic;




            matchingComp=[];
            if isempty(matchingSignal)
                matchingComp=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Components,nodeName);
            end


            if~isempty(nic)&&isempty(matchingComp)
                matchingComp=BA.Abstraction.abstractCriticalPathInfo.findMatchingObject(tn.Components,matchingParentComp.Name);
            end
        end

    end

end


