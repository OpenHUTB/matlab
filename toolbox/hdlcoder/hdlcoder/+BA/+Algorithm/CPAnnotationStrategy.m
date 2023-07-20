



classdef CPAnnotationStrategy<handle

    properties(SetAccess=protected,GetAccess=protected)
colorMgr
uncolorMgr
numColoredCPs
maxNumCPs
targetModel
numSuccValidNodesMap
succNodesMap
nodeLatencyMap

highlightPir
pirHiliteMap
pirAnnotationMap

cgDir
fcnName
isMLHDLC
    end

    methods


        function this=CPAnnotationStrategy(highlightPir,cgDir,fcnName,isMLHDLC)


            this.numColoredCPs=0;


            this.colorMgr=BA.Annotator.colorManager;


            this.maxNumCPs=8;


            this.uncolorMgr=cell(1,this.maxNumCPs);


            this.targetModel='Generated';


            this.numSuccValidNodesMap=containers.Map('KeyType','double','ValueType','int16');
            this.succNodesMap=containers.Map('KeyType','double','ValueType','any');
            this.nodeLatencyMap=containers.Map('KeyType','double','ValueType','double');

            this.pirHiliteMap=containers.Map('KeyType','char','ValueType','double');
            this.pirAnnotationMap=containers.Map('KeyType','char','ValueType','any');

            if nargin<4
                isMLHDLC=false;
            end

            if nargin<3
                fcnName='';
            end

            if nargin<2
                cgDir='';
            end

            if nargin<1
                highlightPir=false;
            end

            this.highlightPir=highlightPir;
            this.cgDir=cgDir;
            this.fcnName=fcnName;
            this.isMLHDLC=isMLHDLC;

            this.highlightPir=true;
        end


        function resetMaps(this)
            this.numSuccValidNodesMap=containers.Map('KeyType','double','ValueType','int16');
            this.succNodesMap=containers.Map('KeyType','double','ValueType','any');
            this.nodeLatencyMap=containers.Map('KeyType','double','ValueType','double');

            this.pirHiliteMap=containers.Map('KeyType','char','ValueType','double');
            this.pirAnnotationMap=containers.Map('KeyType','char','ValueType','any');
        end


        function setTargetModel(this,tModel)
            this.targetModel=tModel;
        end


        function tModel=getTargetModel(this)
            tModel=this.targetModel;
        end


        function incrementAndAllocateUncolorMgr(this)
            this.numColoredCPs=this.numColoredCPs+1;


            this.uncolorMgr{this.numColoredCPs}=BA.Annotator.uncolorManager;
        end


        function reset(this)
            if(this.numColoredCPs==0)
                return;
            end
            this.uncolorMgr{this.numColoredCPs}.resetColors;
            this.uncolorMgr{this.numColoredCPs}.removeAnnotations;
            this.numColoredCPs=this.numColoredCPs-1;
        end


        function resetall(this)
            if(this.numColoredCPs==0)
                return;
            end
            for i=this.numColoredCPs:-1:1
                this.resetCP(i);
            end
            this.numColoredCPs=0;
        end


        function resetCP(this,i)
            if(i==0)
                return;
            end
            this.uncolorMgr{i}.resetColors;
            this.uncolorMgr{i}.removeAnnotations;
        end


        function printColoredObjects(this)
            if this.numColoredCPs==0
                fprintf(1,'No colored objects.\n');
                return;
            end
            for i=this.numColoredCPs:-1:1
                this.uncolorMgr{i}.print;
            end
        end



        function markRecursive(this,colorIndex,outputSignal)



            this.markAndHilite(colorIndex,outputSignal);

            currSignalOwner=outputSignal.Owner;
            parentInstances=currSignalOwner.instances;

            if length(parentInstances)==1
                parentOutputSignals=parentInstances.getOutputSignals('data');
                if~isempty(parentOutputSignals)
                    this.markRecursive(colorIndex,parentOutputSignals(1));
                end
            end
        end


        function markAndHilite(this,colorIndex,signal)



            this.highlightComp(signal,true,colorIndex,true);
        end


        function annotateText(this,annotationText,location,path,colorIndex)
            cm=this.colorMgr;
            ucm=this.uncolorMgr{this.numColoredCPs};
            cm.annotate(location,path,annotationText,colorIndex);

            ucm.addToTextBlocks([path,'/',annotationText]);
        end



        function l=getLineHandleFromReceiver(~,pirSignal)
            l=-1;
            receivers=pirSignal.getReceivers;
            numReceivers=length(receivers);
            for i=1:numReceivers

                rp=receivers(i);


                r=rp.Owner;

                if~strcmp(r.ClassName,'network')


                    inPortIndex=hdlcoder.SimulinkData.getOriginalIdx(rp)+1;


                    rh=r.getGMHandle;

                    if(rh~=-1)
                        portHandles=get_param(rh,'porthandles');
                        l=get_param(portHandles.Inport(inPortIndex),'line');
                        break;
                    end
                end
            end
        end



        function l=getLineHandleFromDriver(~,pirSignal)
            l=-1;
            drivers=pirSignal.getDrivers;

            if isempty(drivers)
                return;
            end


            dp=drivers(1);


            d=dp.Owner;

            if~strcmp(d.ClassName,'network')


                outPortIndex=hdlcoder.SimulinkData.getOriginalIdx(dp)+1;


                dh=d.getGMHandle;

                if(dh~=-1)
                    portHandles=get_param(dh,'porthandles');
                    l=get_param(portHandles.Outport(outPortIndex),'line');
                end
            end
        end


        function h=getComponentHandle(this,pirSignal)
            h=-1;
            drivers=pirSignal.getDrivers;

            if isempty(drivers)
                return;
            end

            if strcmpi(this.targetModel,'Original')

                signalHandle=pirSignal.SimulinkHandle;

                if signalHandle<0||signalHandle==0
                    fprintf('Warning: The node %s has been elaborated. Unable to locate it.\n',drivers.Owner.Name);
                    return;
                end

                try
                    object=get_param(signalHandle,'Object');
                catch %#ok<CTCH>
                    warning(message('hdlcoder:backannotate:UnableToFind',pirSignal.Name));
                    return;
                end


                h=get_param(object.parent,'Handle');

            end

            if strcmpi(this.targetModel,'Generated')


                d=pirSignal.getDrivers.Owner;

                if strcmp(d.ClassName,'network')



                    l=this.getLineHandleFromReceiver(pirSignal);
                else



                    h=d.getGMHandle;

                    if(h~=-1)
                        return;
                    end


                    l=this.getLineHandleFromReceiver(pirSignal);
                end

                if(l==-1)
                    fprintf(1,'Warning: The node %s has been elaborated. Unable to find it.\n',d.Name);
                else

                    srcPortHandle=get_param(l,'SrcPortHandle');



                    object=get_param(srcPortHandle,'Object');


                    h=get_param(object.parent,'Handle');
                end

            end

        end


        function dc=getDriverComp(~,sig)
            drivers=sig.getDrivers;
            if(length(drivers)~=1)

                dc=[];
            else
                if(~isequal(drivers.Owner.RefNum,sig.Owner.RefNum))


                    dc=drivers.Owner;
                else
                    dc=drivers;
                end
            end
        end


        function hilite_pir(this,comp,colorIndex)
            if(this.highlightPir)
                if(~isempty(comp)&&~isempty(find(strcmpi(fields(comp),'RefNum'),1)))
                    this.pirHiliteMap([comp.Owner.RefNum,'_',comp.RefNum])=colorIndex;
                end
            end
        end


        function annotate_pir(this,comp,text)
            if(this.highlightPir)
                if(~isempty(comp))
                    d=comp.getDrivers();
                    if(isempty(d))
                        return;
                    end
                    assert(length(d)==1,'More than one dirver???');
                    if(strcmpi(class(d.Owner),'hdlcoder.network'))
                        port=[d.Owner.RefNum,':',d.Name];
                    else
                        port=[d.Owner.Owner.RefNum,'_',d.Owner.RefNum,':',d.Name];
                    end
                    this.pirAnnotationMap(port)=text;
                end
            end
        end

        function[hiliteMap,annotationMap]=getPirMaps(this)
            hiliteMap=this.pirHiliteMap;
            annotationMap=this.pirAnnotationMap;
        end


        function highlightComp(this,seed,isSig,colorIndex,mark)
            if(isSig)
                if~this.isMLHDLC
                    ch=this.getComponentHandle(seed);
                end
                comp=this.getDriverComp(seed);
            else
                ch=seed.SimulinkHandle;
                comp=seed;
            end

            if~this.isMLHDLC
                cm=this.colorMgr;
                ucm=this.uncolorMgr{this.numColoredCPs};

                if mark


                    cm.setHiliteScheme3(colorIndex);
                    if(ch~=-1)
                        hilite_system(ch,'user3');
                        ucm.addToColoredObjects(ch);
                    end
                else

                    cm.setHiliteScheme1(colorIndex);
                    if(ch~=-1)
                        if~ucm.findObject(ch)
                            hilite_system(ch,'user1');
                            ucm.addToColoredObjects(ch);
                        end
                    end
                end
            end
            this.hilite_pir(comp,colorIndex);
        end


        function highlightComponent(this,signal,colorIndex)
            this.highlightComp(signal,true,colorIndex,false);
        end


        function portHandle=getPortHandle(this,signal)

            if strcmpi(this.targetModel,'Original')


                portHandle=signal.SimulinkHandle;

                if portHandle==-1
                    receivers=signal.getReceivers;
                    if length(receivers)~=1
                        return;
                    end
                    receiverComp=receivers.Owner;
                    if BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(receiverComp)
                        newSignals=receiverComp.getOutputSignals('data');
                        if length(newSignals)~=1
                            return;
                        end
                        portHandle=newSignals.SimulinkHandle;
                    end
                end
                return;
            end

            lineHandle=-1;
            portHandle=-1;

            if strcmpi(this.targetModel,'Generated')


                lineHandle=this.getLineHandleFromDriver(signal);

                if(lineHandle==-1)

                    lineHandle=this.getLineHandleFromReceiver(signal);
                end
            end

            if(lineHandle~=-1)
                portHandle=get_param(lineHandle,'SrcPortHandle');
            end

        end


        function highlightSignal(this,signal,colorIndex)
            cm=this.colorMgr;
            ucm=this.uncolorMgr{this.numColoredCPs};


            portHandle=this.getPortHandle(signal);

            if(portHandle~=-1&&portHandle~=0)


                try
                    get_param(portHandle,'Object');
                catch %#ok<CTCH>
                    warning(message('hdlcoder:backannotate:UnableToFind',signal.Name));
                    return;
                end

                cm.setHiliteScheme2(colorIndex);


                hilite_system(portHandle,'user2');


                ucm.addToConnectingNets(portHandle);
            end
            hilite_pir(this,signal,colorIndex);
        end


        function updateColoredObjects(this,outSignal,portObject,annotationText)
            ucm=this.uncolorMgr{this.numColoredCPs};

            ch=this.getComponentHandle(outSignal);
            if ch==-1
                return;
            end
            cobj=get_param(ch,'Object');
            compPath=[cobj.Path,'/',cobj.Name];

            ucm.addToTextBlocks([compPath,'/',num2str(portObject.PortNumber),'/',annotationText]);
            ucm.addToAnnotatedPorts(portObject);
        end


        function annotateLatency(this,signal,cumulativeDelay)
            cm=this.colorMgr;

            annotationText=sprintf('%5.5f',cumulativeDelay);


            portHandle=this.getPortHandle(signal);

            if(portHandle~=-1&&portHandle~=0)

                try
                    object=get_param(portHandle,'Object');
                catch %#ok<CTCH>
                    warning(message('hdlcoder:backannotate:UnableToFind',signal.Name));
                    return;
                end

                cm.annotateValueLabel(object,annotationText);

                this.updateColoredObjects(signal,object,annotationText);
            end
            this.annotate_pir(signal,annotationText);
        end


        function highlight(this,thisSignal,sourceSignal,destSignal,colorIndex,showdelays)

            this.highlightComponent(thisSignal,colorIndex);
            if thisSignal.getUniqId==sourceSignal.getUniqId...
                ||thisSignal.getUniqId~=destSignal.getUniqId

                this.highlightSignal(thisSignal,colorIndex);
            end
            if(showdelays)
                nodeLatency=this.getNodeLatency(thisSignal.getUniqId);

                if~isempty(nodeLatency)
                    this.annotateLatency(thisSignal,nodeLatency);
                end
            end
        end


        function finishAnnotation(this,sourceSignal,destSignal,colorIndex,showdelays)

            this.highlight(sourceSignal,sourceSignal,destSignal,colorIndex,showdelays);
            if~isKey(this.succNodesMap,sourceSignal.getUniqId)
                return;
            end
            outSignalsToBeAnnotated=this.succNodesMap(sourceSignal.getUniqId);
            hasMultipleInsts=false;
            for i=1:length(outSignalsToBeAnnotated)
                thisSignal=outSignalsToBeAnnotated(i);
                if~hasMultipleInsts
                    hasMultipleInsts=BA.Algorithm.CPAnnotationStrategy.hasMultipleInstances(thisSignal);
                end

                this.highlight(thisSignal,sourceSignal,destSignal,colorIndex,showdelays);
            end
            if hasMultipleInsts
                fprintf(1,'Warning: There are multiply instantiated subsystems. Therefore, the critical path within such subsystems may be reported inside a different equivalent subsystem. Check the Resource Utilization Report to find all the multiply-instantiated subsystems.\n');
            end
        end


        function printMaps(this)
            if isempty(this.numSuccValidNodesMap)
                return;
            end
            validNodes=this.numSuccValidNodesMap.keys;
            for i=1:length(validNodes)
                validNode=validNodes{i};
                numSuccNodes=this.numSuccValidNodesMap(validNode);
                succNodes=this.succNodesMap(validNode);
                fprintf(1,'%s (%d) --> ',succNodes(1).Name,numSuccNodes);
                for j=2:length(succNodes)
                    succNode=succNodes(j);
                    fprintf(1,'%s ',succNode.Name);
                end
                fprintf(1,'\n');
            end
        end


        function cleanupMaps(this,sourceSignal)
            if isKey(this.succNodesMap,sourceSignal.getUniqId)
                outSignalsToBeAnnotated=this.succNodesMap(sourceSignal.getUniqId);
                for i=1:length(outSignalsToBeAnnotated)
                    thisSignal=outSignalsToBeAnnotated(i);
                    if isKey(this.succNodesMap,thisSignal.getUniqId)
                        remove(this.numSuccValidNodesMap,thisSignal.getUniqId);
                        remove(this.succNodesMap,thisSignal.getUniqId);
                    end
                    if isKey(this.nodeLatencyMap,thisSignal.getUniqId)
                        remove(this.nodeLatencyMap,thisSignal.getUniqId);
                    end
                end
            end
        end


        function value=getNumSuccValidNodes(this,id)
            value=0;
            if isKey(this.numSuccValidNodesMap,id)
                value=this.numSuccValidNodesMap(id);
            end
        end


        function value=getSuccNodes(this,id)
            value=[];
            if isKey(this.succNodesMap,id)
                value=this.succNodesMap(id);
            end
        end


        function value=getNodeLatency(this,id)
            value=[];
            if isKey(this.nodeLatencyMap,id)
                value=this.nodeLatencyMap(id);
            end
        end



        function newSourceSignal=validateSource(~,currSourceSignal)
            newSourceSignal=currSourceSignal;
            drivers=currSourceSignal.getDrivers;
            if~isempty(drivers)&&length(drivers)==1
                driverComp=drivers.Owner;
                if~strcmp(driverComp.ClassName,'network')...
                    &&BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(driverComp)
                    inputPorts=driverComp.getInputPorts('data');
                    if length(inputPorts)==1
                        newSourceSignal=inputPorts(1).Signal;
                    end
                end
            end
        end


        function annotateEndLatencies(this,cp,source,dest,srcApprox,dstApprox)



            srcCPNode=cp.getNode(1);
            if~srcApprox

                this.annotateLatency(source,srcCPNode.cumulativeDelay);
            end



            dstCPNode=cp.getNode(cp.numNodes);
            if~dstApprox

                this.annotateLatency(dest,dstCPNode.cumulativeDelay);
            end
        end



        function applyPath(this,cpir,i,mdlName,unique,showdelays,showall,showends,endsonly,skipannotation)

            totalCPs=cpir.getNumCPs;
            if(i>totalCPs)
                error(message('hdlcoder:backannotate:IllegalNumCP'));
            end

            if(i>this.maxNumCPs)
                error(message('hdlcoder:backannotate:MaxNumCP',this.maxNumCPs));
            end



            [startCPIndex,totalCPsToBeAnnotated]=...
            BA.Algorithm.CPAnnotationStrategy.setCPIndices(i,totalCPs,showall);

            prevSourceMatch=[];
            prevDestMatch=[];

            if(totalCPsToBeAnnotated==0)
                error(message('hdlcoder:backannotate:NothingToBeDone'));
            end


            rootPIR=pir;

            if(~isempty(mdlName))

                bdo=get_param(mdlName,'Object');

                if(showdelays)
                    Simulink.AnnotationGateway.SetMode(bdo,'ENABLE');
                else
                    Simulink.AnnotationGateway.SetMode(bdo,'DISABLE');
                end
            end

            for j=startCPIndex:totalCPsToBeAnnotated


                cpir.abstractOutCP(j,rootPIR);


                cp=cpir.getAbstractedCP(j);


                if this.isMLHDLC

                    cpHtmlReportFileName=[this.fcnName,'_synthesis_report.html'];
                    cpHtmlReportFile=fullfile(this.cgDir,cpHtmlReportFileName);
                    fid=fopen(cpHtmlReportFile,'w','n','utf-8');
                    if fid==-1
                        error(message('hdlcoder:backannotate:SynthesisHtmlReportReadFailure',cpHtmlReportFile));
                    end
                    BA.Algorithm.generateCPhtmlReport(fid,cpir,rootPIR);
                    fclose(fid);
                end


                if(cp.numNodes==0)


                    this.incrementAndAllocateUncolorMgr;

                    absComps=cp.getAbstractedComps;
                    if~isempty(absComps)&&length(absComps)==1


                        this.highlightComp(absComps(1),false,j,true);
                    end
                    warning(message('hdlcoder:backannotate:EmptyCP'));
                    return;
                end



                sourceMatch=cp.abstractOutSignal(cp.getSource,rootPIR);
                destMatch=cp.abstractOutSignal(cp.getDestination,rootPIR);


                [sourceMatch,srcApprox]=this.getSourceSanity(cp,sourceMatch);
                if(isempty(sourceMatch))
                    return;
                end


                [destMatch,dstApprox]=this.getDestinationSanity(cp,destMatch);
                if(isempty(destMatch))
                    return;
                end

                if(unique...
                    &&~isempty(prevSourceMatch)&&prevSourceMatch.getUniqId==sourceMatch.getUniqId...
                    &&~isempty(prevDestMatch)&&prevDestMatch.getUniqId==destMatch.getUniqId)

                    continue;
                end


                this.incrementAndAllocateUncolorMgr;


                if(showdelays)
                    this.annotateEndLatencies(cp,sourceMatch,destMatch,srcApprox,dstApprox);
                end

                prevSourceMatch=sourceMatch;
                prevDestMatch=destMatch;


                sourceMatch=this.validateSource(sourceMatch);

                if(~endsonly)



                    cp.resetVisitedNodes;


                    cpnodeIndex=1;

                    if this.isMLHDLC
                        link=sprintf('<a href="matlab:web(''%s'')">%s</a>',cpHtmlReportFile,cpHtmlReportFileName);
                        disp(' ');
                        fprintf('### Generating Synthesis Report %s\n',link);
                    else

                        fprintf(1,'### Highlighting CP %d from ''%s'' to ''%s'' ...\n',...
                        j,BA.Main.baDriver.getFullPath(sourceMatch),...
                        BA.Main.baDriver.getFullPath(destMatch));
                    end


                    this.resetMaps;



                    [~,endReached]=this.annotateRecursive(j,cp,sourceMatch,destMatch,cpnodeIndex,0,showdelays);




                    this.removeLatencyNoise(cp,sourceMatch);


                    if(~skipannotation)
                        this.finishAnnotation(sourceMatch,destMatch,j,showdelays);
                    end




                    this.cleanupMaps(sourceMatch);



                    BA.Algorithm.CPAnnotationStrategy.reportWarnings(endReached,srcApprox,dstApprox,j);

                end

                if(~skipannotation&&(showends||endsonly))






                    this.markRecursive(j,sourceMatch);


                    this.markRecursive(j,destMatch);

                end

            end
        end


        function removeLatencyNoise(~,~,~)

        end


        function flag=isInOpMatchSet(~,i,j,opMatchSet)
            flag=false;
            for k=1:length(opMatchSet)
                if opMatchSet{k}.receiverNum==i...
                    &&opMatchSet{k}.outPortNum==j
                    flag=true;
                    return;
                end
            end
        end

        function annotateDot(this,dotFileName)
            [cpColorMaps,cpAnnotationMaps]=this.getPirMaps;
            palette={'orange','blue','red','green'};

            fstr=file2str(dotFileName);

            keys=cpColorMaps.keys;
            for i=1:length(keys)
                nc=keys{i};
                val=cpColorMaps(nc);

                [attr,pstart,pend]=regexpi(fstr,[nc,' \[[^\]]*\]'],'match','start','end','once');
                if(isempty(attr))
                    continue;
                end

                newAttr=regexprep(attr,']',[', style=filled, color=',palette{val},']']);
                fstr=[fstr(1:pstart-1),newAttr,fstr(pend+1:end)];
            end

            keys=cpAnnotationMaps.keys;
            for i=1:length(keys)
                nc=keys{i};
                val=cpAnnotationMaps(nc);

                [attr,pstart,pend]=regexpi(fstr,[nc,' -> [\S]+'],'match','start','end','once');
                if(isempty(attr))
                    continue;
                end

                newAttr=[attr,'[taillabel = "',val,'"]'];
                fstr=[fstr(1:pstart-1),newAttr,fstr(pend+1:end)];
            end
            fid=fopen(dotFileName,'w');

            if fid==-1
                error(message('hdlcoder:backannotate:DotFileReadFailure',dotFileName));
            end
            fprintf(fid,'%s',fstr);
            fclose(fid);
        end

    end

    methods(Static)

        function cgir2pirSigMap=createCGIR2PIRSignalMapFromSignals(signals)
            cgir2pirSigMap=containers.Map('KeyType','double','ValueType','any');
            for i=1:length(signals)
                thisSignal=signals(i);
                cgirSignal=hdlcoder.SimulinkData.getCGIRSignalForBA(thisSignal);
                if~isempty(cgirSignal)
                    cgir2pirSigMap(cgirSignal.getUniqId)=thisSignal;
                end
            end
        end

        function cgir2pirSigMap=createCGIR2PIRSignalMap(network)
            signals=network.Signals;
            cgir2pirSigMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMapFromSignals(signals);
        end;

        function cgir2pirSigMap=createCGIR2PIRSignalMapForCtx(ctx)
            signals=[];
            for i=1:length(ctx.Networks)
                signals=[signals;ctx.Networks(i).Signals];
            end
            cgir2pirSigMap=BA.Algorithm.CPAnnotationStrategy.createCGIR2PIRSignalMapFromSignals(signals);
        end


        function flag=isOutputOfDelay(sig)
            opType=BA.Algorithm.OperationType.get(sig);

            flag=opType==BA.Abstraction.OPTYPE.DELAY;
        end



        function flag=isCompAddedByPIR(comp)
            flag=any(strcmp({'typechange_comp','concat_comp','index_comp','buffer_comp'},comp.ClassName));
        end


        function flag=hasMultipleInstances(thisSignal)
            allInstances=thisSignal.Owner.instances;
            flag=length(allInstances)>1;
        end


        function newSignal=getNearestMatchInPIR(currSignal)
            newSignal=currSignal;
            receivers=currSignal.getReceivers;
            if length(receivers)==1
                receiverComp=receivers.Owner;
                if BA.Algorithm.CPAnnotationStrategy.isCompAddedByPIR(receiverComp)
                    newSignal=receiverComp.getOutputSignals('data');
                end
            end
        end


        function reportWarnings(endReached,srcApprox,dstApprox,cpid)
            if~endReached

                fprintf(1,'Warning: The critical path %d may be incomplete\n',cpid);
            end

            if srcApprox
                fprintf(1,'Warning: The starting point of the critical path %d is not traceable\n',cpid);
            end

            if dstApprox
                fprintf(1,'Warning: The end point of the critical path %d is not traceable\n',cpid);
            end
        end


        function[startIndex,endIndex]=setCPIndices(i,totalCPs,showall)

            startIndex=i;
            endIndex=i;


            if(showall)
                startIndex=1;
                endIndex=i;
                if(i==0)
                    endIndex=totalCPs;
                end
            end
        end


        function printSkippedMatches(skippedMatches)
            for i=1:length(skippedMatches)
                fprintf(1,'''%s''\n',BA.Main.baDriver.getFullPath(skippedMatches{i}));
            end
        end

    end
end



