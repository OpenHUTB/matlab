



classdef pirInterpolationStrategy<BA.Algorithm.CPAnnotationStrategy

    methods

        function obj=pirInterpolationStrategy(varargin)
            obj=obj@BA.Algorithm.CPAnnotationStrategy(varargin{:});
        end


        function[foundNextValidSignal,endReached]=annotateRecursive(this,colorIndex,cp,thisSignal,...
            destSignal,cpnodeIndex,numPrevReceivers,showdelays)


            endReached=false;

            foundNextValidSignal=false;

            maxNumValidNodes=0;

            maxSuccNodes=[];



            if cpnodeIndex>1&&thisSignal.getUniqId==destSignal.getUniqId
                endReached=true;
                acpnode=this.lookupInAbstractedCP(cp,thisSignal,cpnodeIndex,true);

                if showdelays&&~isempty(acpnode)

                    this.annotateLatency(thisSignal,acpnode.cumulativeDelay);
                end
                return;
            end



            if cpnodeIndex>1...
                &&BA.Algorithm.CPAnnotationStrategy.isOutputOfDelay(thisSignal)
                return;
            end


            cp.addToVisitedNodes(thisSignal);




            [acpnode,acpnodeIndex]=this.lookupInAbstractedCP(cp,thisSignal,cpnodeIndex);


            if~isempty(acpnode)&&acpnodeIndex<cp.numNodes
                cpnodeIndex=acpnodeIndex+1;
            end


            receivers=thisSignal.getReceivers;


            numReceivers=length(receivers);




            [opMatchSet,nextacpnode,isHierMatch]=this.lookAheadDetectValidCPNode(cp,cpnodeIndex,thisSignal,destSignal);

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







                        if~isHierMatch...
                            &&~isempty(opMatchSet)...
                            &&~traversedHierarchy...
                            &&(this.isInOpMatchSet(i,j,opMatchSet)...
                            ||(numOutports==1&&numReceivers==1))


                            [newFoundNextValidSignal,newEndReached]=this.annotateRecursive(colorIndex,cp,outSignal,destSignal,...
                            cpnodeIndex,0,showdelays);

                            numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId);

                            if~isempty(nextacpnode)

                                foundNextValidSignal=true;
                                numValidNodes=this.getNumSuccValidNodes(outSignal.getUniqId)+1;
                            else
                                foundNextValidSignal=foundNextValidSignal||newFoundNextValidSignal;
                            end


                            endReached=endReached||newEndReached;
                            succNodes=[outSignal,this.getSuccNodes(outSignal.getUniqId)];

                        elseif isHierMatch||BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(destComp)



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


        function[opMatchSet,nextacpnode,isHierMatch]=lookAheadDetectValidCPNode(this,cp,cpnodeIndex,thisSignal,destSignal)
            minDelay=10000;
            opMatchSet={};
            opUnmatchSet={};
            count1=1;
            count2=1;
            nextacpnode=[];
            numUnobstructedPaths=0;
            isHierMatch=false;
            prevCompAddedByPIR=false;

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

                    [acpnode,~,hierMatch]=this.lookupInAbstractedCP(cp,outSignal,cpnodeIndex);
                    if~isempty(acpnode)
                        cumDelay=acpnode.cumulativeDelay;
                        if(cumDelay<minDelay)||prevCompAddedByPIR
                            minDelay=cumDelay;
                            opMatchSet{count1}.receiverNum=i;
                            opMatchSet{count1}.outPortNum=j;
                            count1=count1+1;
                            nextacpnode=acpnode;
                            isHierMatch=hierMatch;
                            prevCompAddedByPIR=false;
                            if BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(destComp)
                                prevCompAddedByPIR=true;
                            end
                        end
                    else
                        opUnmatchSet{count2}.receiverNum=i;
                        opUnmatchSet{count2}.outPortNum=j;
                        count2=count2+1;
                        if isempty(nextacpnode)

                            opMatchSet{count1}.receiverNum=i;
                            opMatchSet{count1}.outPortNum=j;
                            numUnobstructedPaths=numUnobstructedPaths+1;
                        end
                    end
                end
            end
            if isempty(nextacpnode)&&numUnobstructedPaths>1


                opMatchSet=opUnmatchSet;
            end
        end


        function[acpnode,acpnodeIndex,hierMatch]=lookupInAbstractedCP(this,cp,currSignal,cpIndex,preferLast)
            if(nargin<5)
                preferLast=false;
            end
            [acpnode,acpnodeIndex,hierMatch]=cp.nodeInAbstractedCP(currSignal,cpIndex,preferLast);

            cgirSignal=hdlcoder.SimulinkData.getCGIRSignalForBA(currSignal);
            if isempty(acpnode)&&~isempty(cgirSignal)

                [acpnode,acpnodeIndex]=cp.nodeInAbstractedCP(cgirSignal,cpIndex,preferLast);
            end
        end


        function[sourceMatch,approx]=getSourceSanity(this,cp,sourceMatch)%#ok<*MANU>

            approx=false;

            if~isempty(sourceMatch)
                fprintf(1,'### Matched Source = ''%s''\n',BA.Main.baDriver.getFullPath(sourceMatch));
            else
                sourceMatch=cp.getNodeName(1);
                fprintf(1,'### Unable to match the exact source. Approximate match for source = ''%s''\n',BA.Main.baDriver.getFullPath(sourceMatch));
                approx=true;
            end
            if~this.isMLHDLC
                cgir2pirSignalMap=[];
                if sourceMatch.SimulinkHandle<0
                    cgir2pirSignalMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMap(sourceMatch.Owner);
                    if isKey(cgir2pirSignalMap,sourceMatch.getUniqId)
                        sourceMatch=cgir2pirSignalMap(sourceMatch.getUniqId);

                        if sourceMatch.SimulinkHandle<0
                            sourceMatch=BA.Algorithm.CPAnnotationStrategy.getNearestMatchInPIR(sourceMatch);
                        end
                    end
                end



                if sourceMatch.SimulinkHandle<0
                    skippedMatches={sourceMatch};
                    fprintf(1,'Warning: The source ''%s'' has been elaborated. Unable to find it.\n',BA.Main.baDriver.getFullPath(sourceMatch));
                    if cp.numNodes>1
                        for i=2:cp.numNodes-1


                            tmpSourceMatch=cp.getNodeName(i);



                            if i==2&&~isempty(cgir2pirSignalMap)
                                if tmpSourceMatch.SimulinkHandle<0&&isKey(cgir2pirSignalMap,tmpSourceMatch.getUniqId)
                                    tmpSourceMatch=cgir2pirSignalMap(tmpSourceMatch.getUniqId);
                                end
                            end
                            if(tmpSourceMatch.SimulinkHandle>=0)
                                sourceMatch=tmpSourceMatch;
                                fprintf(1,'### Unable to match the exact source. After skipping %d node(s), approximate match for source = ''%s''\n',i-1,BA.Main.baDriver.getFullPath(sourceMatch));
                                fprintf(1,'Skipped node(s) at source:\n');
                                BA.Algorithm.CPAnnotationStrategy.printSkippedMatches(skippedMatches);
                                approx=true;
                                break;
                            else
                                skippedMatches{end+1}=tmpSourceMatch;
                            end
                        end
                    end
                end

            end

        end


        function[destMatch,approx]=getDestinationSanity(this,cp,destMatch)

            approx=false;

            if~isempty(destMatch)
                fprintf(1,'### Matched Destination = ''%s''\n',BA.Main.baDriver.getFullPath(destMatch));
            else
                destMatch=cp.getNodeName(cp.numNodes);
                fprintf(1,'### Unable to match the exact destination. Approximate match for destination = ''%s''\n',BA.Main.baDriver.getFullPath(destMatch));
                approx=true;
            end
            if~this.isMLHDLC
                cgir2pirSignalMap=[];
                if destMatch.SimulinkHandle<0
                    cgir2pirSignalMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMap(destMatch.Owner);
                    if isKey(cgir2pirSignalMap,destMatch.getUniqId)
                        destMatch=cgir2pirSignalMap(destMatch.getUniqId);

                        if destMatch.SimulinkHandle<0
                            destMatch=BA.Algorithm.CPAnnotationStrategy.getNearestMatchInPIR(destMatch);
                        end
                    end
                end

                if destMatch.SimulinkHandle<0
                    skippedMatches={destMatch};
                    fprintf(1,'Warning: The destination ''%s'' has been elaborated. Unable to find it.\n',BA.Main.baDriver.getFullPath(destMatch));
                    if cp.numNodes>1
                        for i=(cp.numNodes-1):-1:2


                            tmpDestMatch=cp.getNodeName(i);



                            if i==(cp.numNodes-1)&&~isempty(cgir2pirSignalMap)
                                if tmpDestMatch.SimulinkHandle<0&&isKey(cgir2pirSignalMap,tmpDestMatch.getUniqId)
                                    tmpDestMatch=cgir2pirSignalMap(tmpDestMatch.getUniqId);
                                end
                            end
                            if(tmpDestMatch.SimulinkHandle>=0)
                                destMatch=tmpDestMatch;
                                fprintf(1,'### Unable to match the exact destination. After skipping %d node(s), approximate match for destination = ''%s''\n',cp.numNodes-i,BA.Main.baDriver.getFullPath(destMatch));
                                fprintf(1,'Skipped node(s) at destination:\n');
                                BA.Algorithm.CPAnnotationStrategy.printSkippedMatches(skippedMatches);
                                approx=true;
                                break;
                            else
                                skippedMatches{end+1}=tmpDestMatch;
                            end
                        end
                    end
                end

            end

        end


    end
end



