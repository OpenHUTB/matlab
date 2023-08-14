classdef SignalFinder<mlreportgen.finder.Finder


























































































    properties











        IncludeInputSignals(1,1)logical=true;











        IncludeOutputSignals(1,1)logical=true;















        IncludeControlSignals(1,1)logical=false;













        IncludeInternalSignals(1,1)logical=false;















        IncludeVirtualBlockSignals(1,1)logical=true;








        IncludeUnnamedSignals(1,1)logical=true;











        SearchDepth(1,1){mustBePositiveIntegerOrInfinite}=1;
    end

    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)


        NodeList=[]


        NodeCount{mustBeInteger}=0


        NextNodeIndex{mustBeInteger}=0


        IsIterating logical=false
    end

    methods
        function this=SignalFinder(varargin)
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)












            findImpl(this);

            results=this.NodeList;
        end
    end

    methods
        function result=next(this)














            if hasNext(this)

                result=this.NodeList(this.NextNodeIndex);

                this.NextNodeIndex=this.NextNodeIndex+1;
            else
                result=slreportgen.finder.SignalResult.empty();
            end
        end

        function tf=hasNext(this)
























            if this.IsIterating
                if this.NextNodeIndex<=this.NodeCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findImpl(this);
                if this.NodeCount>0
                    this.NextNodeIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end
    end

    methods(Access=protected)
        function tf=isIterating(this)






            tf=this.IsIterating;
        end

        function reset(this)







            this.NodeList=[];
            this.IsIterating=false;
            this.NodeCount=0;
            this.NextNodeIndex=0;
        end
    end

    methods(Access=private)
        function findImpl(this)





            container=resolveContainer(this);


            inSigs=[];
            outSigs=[];
            ctrlSigs=[];
            stateSigs=[];
            if strcmpi(get_param(container,"Type"),"block")

                portHandles=get_param(container,"PortHandles");


                if this.IncludeInputSignals
                    inSigs=getSourcePorts(this,portHandles.Inport);


                    inSigs=unique(inSigs);
                end

                if this.IncludeControlSignals
                    ctrlPorts=[portHandles.Enable,...
                    portHandles.Trigger,...
                    portHandles.Ifaction,...
                    portHandles.Reset];
                    ctrlSigs=getSourcePorts(this,ctrlPorts);
                end

                if this.IncludeOutputSignals
                    if this.IncludeVirtualBlockSignals...
                        ||strcmp(get_param(container,"Virtual"),"off")
                        outSigs=portHandles.Outport';
                        stateSigs=portHandles.State;
                    else



                        outSigs=getNonvirtualSource(portHandles.Outport);


                        outSigs=unique(outSigs);
                    end
                end
            elseif strcmpi(get_param(container,"Type"),"block_diagram")
                if this.IncludeInputSignals


                    inportBlks=find_system(container,"FindAll",'on',"SearchDepth",1,"Type","block","BlockType","Inport");
                    if~isempty(inportBlks)
                        portHandles=getPortHandles(inportBlks);
                        inSigs=[portHandles.Outport]';
                    end
                end
                if this.IncludeOutputSignals


                    outportBlks=find_system(container,"FindAll",'on',"SearchDepth",1,"Type","block","BlockType","Outport");
                    if~isempty(outportBlks)
                        ph=getPortHandles(outportBlks);
                        outSigs=getSourcePorts(this,[ph.Inport]);


                        outSigs=unique(outSigs);
                    end
                end
            else

                error(message("slreportgen:finder:error:mustBeSimulinkBlockOrModel"));
            end


            internalSigs=getInternalSignals(this,container);



            if~isempty(this.Properties)
                inSigs=find_system(inSigs,this.Properties{:});
                outSigs=find_system(outSigs,this.Properties{:});
                stateSigs=find_system(stateSigs,this.Properties{:});
                ctrlSigs=find_system(ctrlSigs,this.Properties{:});
            end


            this.NodeList=getSignalResults(this,string(getfullname(container)),...
            inSigs,outSigs,stateSigs,ctrlSigs,internalSigs);
            this.NodeCount=length(this.NodeList);
        end

        function container=resolveContainer(this)




            container=this.Container;
            if isempty(container)

                error(message("slreportgen:finder:error:mustBeSimulinkBlockOrModel"));
            else
                if isa(container,"slreportgen.finder.DiagramResult")...
                    ||isa(container,"slreportgen.finder.BlockResult")
                    container=container.Object;
                    if isa(container,"Stateflow.Chart")
                        container=container.Path;
                    end
                end

                if~isValidSlObject(slroot,container)
                    error(message("slreportgen:finder:error:mustBeSimulinkBlockOrModel"));
                end
            end
        end

        function internalSigs=getInternalSignals(this,container)





            internalSigs=[];

            if this.IncludeInternalSignals&&slreportgen.utils.isValidSlSystem(container)



                opts={'FindAll','on',...
                'Regexp','on',...
                'SearchDepth',this.SearchDepth,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'type','port',...
                'porttype','outport|state'};
                opts=[opts,this.Properties];
                allOutPorts=find_system(container,opts{:});



                parentBlks=get_param(allOutPorts,"Parent");
                if~this.IncludeVirtualBlockSignals

                    isVirtual=strcmp(get_param(parentBlks,"Virtual"),"on");
                    parentBlks(isVirtual)=[];
                    allOutPorts(isVirtual)=[];
                end

                parentTypes=get_param(parentBlks,"blocktype");
                toRemove=strcmp(parentTypes,"Inport");
                internalSigs=allOutPorts(~toRemove);


                if strcmp(get_param(container,"Type"),"block")
                    ph=get_param(container,"PortHandles");
                    internalSigs=setdiff(internalSigs,ph.Outport);
                end

                outBlks=find_system(container,"SearchDepth",1,...
                "MatchFilter",@Simulink.match.allVariants,...
                "LookUnderMasks","on","FollowLinks","on",...
                "type","block","blocktype","Outport");
                if~isempty(outBlks)
                    ph=getPortHandles(outBlks);
                    outPorts2Filter=getSourcePorts(this,[ph.Inport]);
                    internalSigs=setdiff(internalSigs,outPorts2Filter,'stable');
                end


                if this.SearchDepth>1
                    internalSigs=sortByDepth(internalSigs);
                end
            end
        end

        function results=getSignalResults(this,containerName,...
            inports,outports,statePorts,ctrlPorts,internalPorts)





            nIn=numel(inports);
            nOut=numel(outports);
            nState=numel(statePorts);
            nCtrl=numel(ctrlPorts);
            nInternal=numel(internalPorts);


            relStrings=[repelem("Input",nIn),...
            repelem("Output",nOut),...
            repelem("State",nState),...
            repelem("Control",nCtrl),...
            repelem("Internal",nInternal)];

            allPorts=[inports;outports;statePorts;ctrlPorts;internalPorts];
            names=string(get_param(allPorts,"Name"));
            if~this.IncludeUnnamedSignals
                noNames=names=="";
                allPorts(noNames)=[];
                names(noNames)=[];
                relStrings(noNames)=[];
            end

            parents=string(get_param(allPorts,"Parent"));
            portNums=mlreportgen.utils.safeGet(allPorts,"portnumber",'get_param');


            nTotal=numel(allPorts);
            results=slreportgen.finder.SignalResult.empty(0,nTotal);

            for i=1:nTotal
                node=allPorts(i);

                r=slreportgen.finder.SignalResult(node);

                r.SourceBlock=parents(i);
                r.SourcePortNumber=portNums{i};
                r.Name=names(i);
                r.RelatedObject=containerName;
                r.Relationship=relStrings(i);

                results(i)=r;
            end

        end

        function srcPorts=getSourcePorts(this,ports)



            srcPorts=[];
            if~isempty(ports)
                [~,srcPorts,~]=slreportgen.utils.traceSignal(ports,"Nonvirtual",~this.IncludeVirtualBlockSignals);
                if iscell(srcPorts)
                    srcPorts=cell2mat(srcPorts);
                end
            end
        end
    end

end

function portHandles=getPortHandles(blks)


    portHandles=get_param(blks,"PortHandles");
    if iscell(portHandles)
        portHandles=cell2mat(portHandles);
    end
end

function nonVirtualOutP=getNonvirtualSource(outP)



    nonVirtualOutP=[];
    if~isempty(outP)

        inLine=mlreportgen.utils.safeGet(outP,'Line','get_param');
        nLines=numel(inLine);
        for idx=1:nLines
            line=inLine{idx};
            if line>0
                nonVirtualOutP=[nonVirtualOutP;get_param(line,'NonvirtualSrcPorts')];%#ok<AGROW>
            end
        end
    end
end

function sortedPorts=sortByDepth(ports)










    nPorts=numel(ports);
    if isscalar(ports)

        sortedPorts=ports;
        return;
    end


    sortedPorts=zeros(nPorts,1);



    parents=get_param(ports,"Parent");
    parents=get_param(parents,"Parent");
    currIdx=1;
    while currIdx<nPorts

        newParents=get_param(parents,"Parent");
        emptyParent=cellfun(@(x)isempty(x),newParents);
        nEmpty=nnz(emptyParent);
        if nEmpty>0

            sortedPorts(currIdx:currIdx+nEmpty-1)=ports(emptyParent);
            currIdx=currIdx+nEmpty;
        end

        ports(emptyParent)=[];
        parents=newParents(~emptyParent);
    end

end

function mustBePositiveIntegerOrInfinite(val)
    mustBeNumeric(val)
    if~isinf(val)
        mustBeInteger(val);
        mustBeGreaterThanOrEqual(val,0);
    end
end
