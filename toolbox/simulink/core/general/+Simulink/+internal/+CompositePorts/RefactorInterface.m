classdef RefactorInterface<Simulink.internal.CompositePorts.InterfaceAction

    properties(Access=private)


        mDispatcher;
    end


    methods(Access=protected)

        function this=RefactorInterface(editor,selection,derivedClassType)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.InterfaceAction(editor,selection,mfilename('class'));



            this.mDispatcher=Simulink.internal.CompositePorts.Dispatcher(this,derivedClassType);

            this.mData.srcBlock=-1;
            this.mData.dstBlock=-1;
            this.mData.srcSubsys=-1;
            this.mData.dstSubsys=-1;
            this.mData.lines=[];
            this.mData.linesBySrc=[];
            this.mData.linesByDst=[];
            this.mData.srcPorts=[];
            this.mData.dstPorts=[];
            this.mData.origInportBlocks={};
            this.mData.origOutportBlocks={};
        end
    end

    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)
            tf=this.mDispatcher.dispatch('canExecuteImpl');
        end


        function msg=executeImpl(this)
            msg=this.mDispatcher.dispatch('executeImpl');
        end



    end

    methods(Access=protected)
        function line=getLineOfPortBlock(this,h)
            blockType=get_param(h,'BlockType');
            line=get_param(h,'LineHandles');
            if any(strcmpi({'inport','inportshadow'},blockType))
                line=line.Outport;
            elseif strcmpi('outport',blockType)
                line=line.Inport;
            else
                line=-1;
            end
        end

        function res=pickElements(this,lines,outportBlocks,inportBlocks,signalIdx)






            busSelectorOutput=arrayfun(@this.isBusSelectorOutput,arrayfun(@(h)get_param(h,'SrcPortHandle'),lines));
            res=cellfun(@this.pickElementNameForLine,num2cell(lines),outportBlocks,inportBlocks,num2cell(signalIdx));
            res=this.uniquifySignalNames(res,busSelectorOutput,signalIdx);
            res=this.pickPortBlockElements(res,outportBlocks,inportBlocks);
        end

        function connectBlockPortsAndLineEnds(this,ports,lineEnds)
            assert(numel(ports)==numel(lineEnds));
            for i=1:numel(ports)

                SLM3I.SLDomain.createSegment(GLUE2.Editor.empty(),ports{i},lineEnds{i});
            end
        end

        function[ports,lineEnds]=getBlockPortsAndLineEndsToConnect(this,side,blocks,lines)
            if iscell(lines)
                lines=cell2mat(lines);
            end

            assert(any(strcmpi({'input','output'},side)));
            isInput=strcmpi('input',side);

            ports={};
            lineEnds={};
            for i=1:numel(blocks)

                if~ishandle(lines(i))
                    continue;
                end
                p=get_param(blocks(i),'PortHandles');
                de=SLM3I.SLDomain.handle2DiagramElement(lines(i));
                if isInput
                    p=p.Outport;
                    de=de.srcElement;
                else
                    p=p.Inport;
                    de=de.dstElement;
                end
                ports{end+1}=SLM3I.SLDomain.handle2DiagramElement(p);%#ok<AGROW>
                lineEnds{end+1}=de;%#ok<AGROW>
            end
        end

        function res=forEachInArrayInCell(this,func,c)
            res=cellfun(@(array)arrayfun(func,array,'UniformOutput',false),c,'UniformOutput',false);
        end

    end

    methods(Access=private)

        function res=pickPortBlockElements(this,cur,outportBlocks,inportBlocks)
            res=cur;
            for i=1:numel(res)
                res(i).outportElements=arrayfun(@(b)this.prependElementString(b,res(i).name),outportBlocks{i},'UniformOutput',false);
                res(i).inportElements=arrayfun(@(b)this.prependElementString(b,res(i).name),inportBlocks{i},'UniformOutput',false);
            end
        end

        function res=uniquifySignalNames(this,cur,busSelectorOutput,signalIdx)
            assert(numel(cur)==numel(signalIdx));
            postProcessForBusSelector=false;
            newNames={};
            res=cur;

            largestSignalIdx=0;
            for i=1:numel(cur)

                if signalIdx(i)<=largestSignalIdx

                    actualIdx=find(signalIdx==signalIdx(i),1);
                    newNames{i}=newNames{actualIdx};
                    res(i).name=res(actualIdx).name;
                    res(i).setOnLine=res(actualIdx).setOnLine;
                    continue;
                end
                newNames{i}=SLM3I.SLDomain.uniquifyString(cur(i).name,newNames);%#ok<AGROW>
                if~strcmp(newNames{i},cur(i).name)
                    if busSelectorOutput(i)
                        postProcessForBusSelector=true;
                        break;
                    else
                        res(i).name=newNames{i};
                        res(i).setOnLine=true;
                    end
                end
                largestSignalIdx=signalIdx(i);
            end


            if postProcessForBusSelector
                for i=1:numel(cur)
                    res(i).name=sprintf('%s (%s)',cur(i).name,sprintf('signal %d',signalIdx(i)));
                    res(i).setOnLine=false;
                end
            end

        end

        function res=pickElementNameForLine(this,line,outportBlocks,inportBlocks,idx)
            outportBlock=-1;
            inportBlock=-1;
            if~isempty(outportBlocks)
                outportBlock=outportBlocks(1);
            end
            if~isempty(inportBlocks)
                assert(strcmpi(get_param(inportBlocks(1),'BlockType'),'Inport'));
                inportBlock=inportBlocks(1);
            end

            [name,setOnLine]=this.pickElementNameForLineUnsafe(line,outportBlock,inportBlock,idx);

            safeName=strrep(name,'.',':');
            safeName=strrep(safeName,',',';');

            safeName=strtrim(safeName);

            if isempty(safeName)
                safeName=['signal',num2str(idx)];
            end
            res.name=safeName;
            res.setOnLine=setOnLine;
        end

        function busSelectorOutput=isBusSelectorOutput(this,ph)
            busSelectorOutput=false;
            if~ishandle(ph)||~strcmpi(get_param(ph,'PortType'),'outport')
                return;
            end

            parent=get_param(ph,'ParentHandle');
            if ishandle(parent)&&strcmpi(get_param(parent,'Type'),'Block')&&strcmpi(get_param(parent,'BlockType'),'BusSelector')
                busSelectorOutput=true;
            end
        end

        function[sigName,propName]=getSignalNameForPort(this,ph)

            propName='';
            sigName='';
            srcPort=ph;
            assert(strcmpi(get_param(ph,'PortType'),'outport'));


            sigName=get_param(srcPort,'Name');


            if~isempty(sigName)&&sigName(1)=='<'&&sigName(end)=='>'
                if this.isBusSelectorOutput(srcPort)
                    sigName=sigName(2:end-1);
                end
            end


            dp=SLM3I.SLDomain.handle2DiagramElement(srcPort);
            disconnect=false;
            if dp.edge.size~=0
                disconnect=true;
            end
            if disconnect
                dl=dp.edge.at(1);
                this.disconnectSegmentFromSrc(dl);
            end
            propName=get_param(srcPort,'RefreshedPropSignals');
            if disconnect

                SLM3I.SLDomain.createSegment(GLUE2.Editor.empty(),dp,dl.srcElement);
            end
        end










        function[name,setOnLine]=pickElementNameForLineUnsafe(this,line,outportBlock,inportBlock,idx)

            setOnLine=false;




            srcPort=get_param(line,'SrcPortHandle');

            if ishandle(inportBlock)&&strcmpi(get_param(inportBlock,'IsComposite'),'off')

                ph=get_param(inportBlock,'PortHandles');
                [sigName,propName]=this.getSignalNameForPort(ph.Outport);
                if~isempty(sigName)&&~this.isBusSelectorOutput(srcPort)

                    name=sigName;
                    setOnLine=true;
                    return;
                elseif~isempty(propName)


                    name=propName;
                    return;
                end
            else


                [sigName,propName]=this.getSignalNameForPort(srcPort);
                if~isempty(sigName)
                    name=sigName;
                    setOnLine=true;
                    return;
                elseif~isempty(propName)
                    name=propName;
                    return;
                end
            end


            if ishandle(outportBlock)
                portName=strtrim(this.removeNewLines(get_param(outportBlock,'PortName')));
                if strcmpi(get_param(outportBlock,'IsComposite'),'off')
                    defaultPrefix='Out';
                else
                    defaultPrefix='OutBus';
                end
                if~this.isDefaultName(portName,defaultPrefix)
                    name=portName;
                    setOnLine=true;
                    return;
                end
            end

            if ishandle(inportBlock)
                portName=strtrim(this.removeNewLines(get_param(inportBlock,'PortName')));
                if strcmpi(get_param(inportBlock,'IsComposite'),'off')
                    defaultPrefix='In';
                else
                    defaultPrefix='InBus';
                end
                if~this.isDefaultName(portName,defaultPrefix)
                    name=portName;
                    setOnLine=true;
                    return;
                end
            end


            name=['signal',num2str(idx)];
        end

    end
end
