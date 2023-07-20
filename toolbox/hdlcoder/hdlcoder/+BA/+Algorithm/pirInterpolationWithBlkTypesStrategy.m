



classdef pirInterpolationWithBlkTypesStrategy<BA.Algorithm.CPAnnotationStrategy

    methods

        function obj=pirInterpolationWithBlkTypesStrategy(varargin)
            obj=obj@BA.Algorithm.CPAnnotationStrategy(varargin{:});
        end


        function removeLatencyNoise(this,cp,sourceSignal)
            if~isKey(this.succNodesMap,sourceSignal.getUniqId)
                return;
            end
            outSignalsToBeAnnotated=this.succNodesMap(sourceSignal.getUniqId);
            dstCPNode=cp.getNode(cp.numNodes);
            prevLatency=dstCPNode.cumulativeDelay;
            for i=length(outSignalsToBeAnnotated):-1:1
                currSignal=outSignalsToBeAnnotated(i);
                if isKey(this.nodeLatencyMap,currSignal.getUniqId)
                    currLatency=this.nodeLatencyMap(currSignal.getUniqId);
                    if currLatency==prevLatency
                        remove(this.nodeLatencyMap,currSignal.getUniqId);
                    end
                    prevLatency=currLatency;
                end
            end
        end


        function[foundNextValidSignal,endReached]=annotateRecursive(this,colorIndex,cp,thisSignal,...
            destSignal,cpnodeIndex,numPrevReceivers,showdelays)


            endReached=false;

            foundNextValidSignal=false;

            maxNumValidNodes=0;

            maxSuccNodes=[];



            if cpnodeIndex>1&&thisSignal.getUniqId==destSignal.getUniqId
                endReached=true;
                return;
            end



            if cpnodeIndex>1&&...
                BA.Algorithm.CPAnnotationStrategy.isOutputOfDelay(thisSignal)
                return;
            end


            cp.addToVisitedNodes(thisSignal);




            [acpnode,acpnodeIndex]=this.lookupInAbstractedCP(cp,thisSignal,cpnodeIndex);


            if~isempty(acpnode)&&acpnodeIndex<cp.numNodes
                cpnodeIndex=acpnodeIndex+1;
            end


            receivers=thisSignal.getReceivers;


            numReceivers=length(receivers);




            [opMatchSet,nextacpnode]=this.lookAheadDetectValidCPNode(cp,cpnodeIndex,thisSignal,destSignal);

            for i=1:numReceivers
                if~strcmpi(receivers(i).Kind,'data')
                    continue;
                end
                destComp=receivers(i).Component;

                if(numPrevReceivers>0)

                    continuedNumReceivers=numPrevReceivers;
                else
                    continuedNumReceivers=0;
                end
                traversedHierarchy=false;

                if destComp.isNetworkInstance&&destComp.SimulinkHandle~=-1

                    inPorts=destComp.ReferenceNetwork.getInputPorts('data');
                    portNum=hdlcoder.SimulinkData.getOriginalIdx(receivers(i))+1;

                    if portNum==0
                        warning(message('hdlcoder:backannotate:NodeNotFound',destComp.Name));
                        continue;
                    end

                    inputSignal=inPorts(portNum).Signal;

                    if cp.isFirstEncounter(inputSignal)

                        [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,inputSignal,destSignal,...
                        cpnodeIndex,continuedNumReceivers,showdelays);


                        foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                        endReached=endReached||newEndReached;


                        numValidNodes=this.getNumSuccValidNodes(inputSignal.getUniqId);
                        succNodes=[inputSignal,this.getSuccNodes(inputSignal.getUniqId)];
                    end
                    traversedHierarchy=true;
                end
                if(foundNextValidSignal)


                    if(numValidNodes>maxNumValidNodes)
                        maxNumValidNodes=numValidNodes;
                        maxSuccNodes=succNodes;
                    end
                end
                outports=destComp.getOutputPorts('data');
                numOutports=length(outports);
                for j=1:numOutports
                    outSignal=outports(j).Signal;
                    outSignalPorts=outSignal.getReceivers;


                    parentComps=thisSignal.Owner.instances;

                    for k=1:length(parentComps)
                        parentComp=parentComps(k);


                        if~isempty(parentComp)&&numel(outSignalPorts)==1&&strcmp(outSignalPorts.Owner.ClassName,'network')
                            parentCompOutports=parentComp.getOutputPorts('data');
                            outPortIndex=hdlcoder.SimulinkData.getOriginalIdx(outSignalPorts)+1;
                            if outPortIndex==0
                                localIndex=outSignalPorts.PortIndex+1;
                                parentPort=parentCompOutports(localIndex);
                                outPortIndex=hdlcoder.SimulinkData.getOriginalIdx(parentPort)+1;
                            end
                            if outPortIndex==0
                                warning(message('hdlcoder:backannotate:NodeNotFound',parentComp.Name));
                                continue;
                            end

                            parentOutSignal=parentCompOutports(outPortIndex).Signal;
                            if cp.isFirstEncounter(parentOutSignal)

                                [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,parentOutSignal,destSignal,...
                                cpnodeIndex,0,showdelays);


                                foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                                endReached=endReached||newEndReached;


                                numValidNodes=this.getNumSuccValidNodes(parentOutSignal.getUniqId);
                                succNodes=[parentOutSignal,this.getSuccNodes(parentOutSignal.getUniqId)];
                            end
                        end
                        if(foundNextValidSignal)


                            if(numValidNodes>maxNumValidNodes)
                                maxNumValidNodes=numValidNodes;
                                maxSuccNodes=succNodes;
                            end
                        end
                    end


                    if cp.isFirstEncounter(outSignal)...
                        ||outSignal.getUniqId==destSignal.getUniqId






                        if(numPrevReceivers>0)


                            numReceivers=numPrevReceivers;
                        end






                        if~isempty(opMatchSet)...
                            &&~traversedHierarchy...
                            &&(this.isInOpMatchSet(i,j,opMatchSet)...
                            ||(numOutports==1&&numReceivers==1))


                            [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,outSignal,destSignal,cpnodeIndex,0,showdelays);

                            numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId);

                            if~isempty(nextacpnode)


                                numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId)+1;
                            end

                            foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                            endReached=endReached||newEndReached;

                            if(cpnodeIndex>1&&outSignal.getUniqId==destSignal.getUniqId)
                                endReached=true;

                                foundNextValidSignal=true;
                            end
                            succNodes=[outSignal,this.getSuccNodes(outSignal.getUniqId)];

                        elseif BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(destComp)



                            [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,outSignal,destSignal,...
                            cpnodeIndex,numReceivers,showdelays);


                            foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                            endReached=endReached||newEndReached;


                            numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId);
                            succNodes=[outSignal,this.getSuccNodes(outSignal.getUniqId)];
                        end

                    else

                        if isKey(this.numSuccValidNodesMap,outSignal.getUniqId)

                            numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId);
                            if~isempty(nextacpnode)

                                numValidNodes=numValidNodes+1;
                            end
                            succNodes=[outSignal,this.getSuccNodes(outSignal.getUniqId)];
                            nodeLatency=this.getNodeLatency(outSignal.getUniqId);
                            if~isempty(nodeLatency)...
                                &&~isempty(nextacpnode)...
                                &&nodeLatency<nextacpnode.cumulativeDelay

                                [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,outSignal,destSignal,...
                                cpnodeIndex,numReceivers,showdelays);


                                foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                                endReached=endReached||newEndReached;
                            else
                                foundNextValidSignal=true;
                            end
                        end
                    end

                    if(foundNextValidSignal)


                        if(numValidNodes>maxNumValidNodes)
                            maxNumValidNodes=numValidNodes;
                            maxSuccNodes=succNodes;
                        end
                    end

                end
            end



            if(foundNextValidSignal)

                this.numSuccValidNodesMap(thisSignal.getUniqId)=maxNumValidNodes;
                this.succNodesMap(thisSignal.getUniqId)=maxSuccNodes;
                if~isempty(acpnode)
                    this.nodeLatencyMap(thisSignal.getUniqId)=acpnode.cumulativeDelay;
                end
            end

        end



        function[opMatchSet,nextacpnode]=lookAheadDetectValidCPNode(this,cp,cpnodeIndex,thisSignal,destSignal)
            opMatchSet={};
            opUnmatchSet={};
            count1=1;
            count2=1;
            nextacpnode=[];

            receivers=thisSignal.getReceivers;
            for i=1:length(receivers)
                destComp=receivers(i).Component;
                outports=destComp.getOutputPorts('data');
                numOutports=length(outports);
                for j=1:numOutports
                    outSignal=outports(j).Signal;
                    if BA.Algorithm.CPAnnotationStrategy.isOutputOfDelay(outSignal)...
                        &&outSignal.getUniqId~=destSignal.getUniqId

                        continue;
                    end

                    acpnode=this.lookupInAbstractedCP(cp,outSignal,cpnodeIndex);
                    if~isempty(acpnode)
                        opMatchSet{count1}.receiverNum=i;
                        opMatchSet{count1}.outPortNum=j;
                        count1=count1+1;
                        nextacpnode=acpnode;
                    else

                        opUnmatchSet{count2}.receiverNum=i;
                        opUnmatchSet{count2}.outPortNum=j;
                        count2=count2+1;
                    end
                end
            end
            if isempty(nextacpnode)
                opMatchSet=opUnmatchSet;
            end
        end


        function[acpnode,acpnodeIndex,opMatch]=lookupInAbstractedCP(this,cp,currSignal,cpIndex,preferLast)
            if(nargin<5)
                preferLast=false;
            end
            [acpnode,acpnodeIndex,opMatch]=cp.nodeInAbstractedCP(currSignal,cpIndex,preferLast);
        end


        function[sourceMatch,approx]=getSourceSanity(this,~,sourceMatch)%#ok<*MANU>

            approx=false;

            if~isempty(sourceMatch)
                fprintf(1,'### Matched Source = ''%s''\n',BA.Main.baDriver.getFullPath(sourceMatch));
            else
                warning(message('hdlcoder:backannotate:SourceNotLocatable'));
                return;
            end
            if~this.isMLHDLC
                if sourceMatch.SimulinkHandle<0
                    fprintf(1,'Warning: The source ''%s'' has been elaborated. Unable to find it.\n',...
                    BA.Main.baDriver.getFullPath(sourceMatch));
                    cgir2pirSignalMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMap(sourceMatch.Owner);
                    if isKey(cgir2pirSignalMap,sourceMatch.getUniqId)
                        sourceMatch=cgir2pirSignalMap(sourceMatch.getUniqId);

                        if sourceMatch.SimulinkHandle<0
                            sourceMatch=BA.Algorithm.CPAnnotationStrategy.getNearestMatchInPIR(sourceMatch);
                        end
                    end
                end

                if sourceMatch.SimulinkHandle<0
                    warning(message('hdlcoder:backannotate:SourceNotLocatable'));
                end
            end
        end


        function[destMatch,approx]=getDestinationSanity(this,~,destMatch)

            approx=false;

            if~isempty(destMatch)
                fprintf(1,'### Matched Destination = ''%s''\n',BA.Main.baDriver.getFullPath(destMatch));
            else
                warning(message('hdlcoder:backannotate:DestNotLocatable'));
                return;
            end

            if~this.isMLHDLC
                if destMatch.SimulinkHandle<0
                    fprintf(1,'Warning: The destination ''%s'' has been elaborated. Unable to find it.\n',...
                    BA.Main.baDriver.getFullPath(destMatch));

                    cgir2pirSignalMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMap(destMatch.Owner);
                    if isKey(cgir2pirSignalMap,destMatch.getUniqId)
                        destMatch=cgir2pirSignalMap(destMatch.getUniqId);

                        if destMatch.SimulinkHandle<0
                            destMatch=BA.Algorithm.CPAnnotationStrategy.getNearestMatchInPIR(destMatch);
                        end
                    end

                    if BA.Algorithm.CPAnnotationStrategy.isOutputOfDelay(destMatch)
                        outRegComp=destMatch.getDrivers.Owner;
                        destMatch=outRegComp.getInputSignals('data');



                        destMatch=destMatch(1);
                    end
                end

                if destMatch.SimulinkHandle<0
                    warning(message('hdlcoder:backannotate:DestNotLocatable'));
                end
            end
        end

    end
end



