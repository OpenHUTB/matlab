classdef EventChainHighlighter<handle

    properties(Access=private)
EventChain
StimulusSLPort
ResponseSLPort
StyledSegments
StyledBlocks
Style
    end


    methods
        function this=EventChainHighlighter(ec)
            this.EventChain=ec;
            [this.StimulusSLPort,this.ResponseSLPort]=getStimulusAndResponseSLPorts(this);
            [this.StyledSegments,this.StyledBlocks]=findAllObjectsInChain(this);
            purple=[0.5,0.0,0.5];
            options={'HighLightColor',purple,'HighlightStyle','SolidLine',...
            'HighlightWidth',3,'tag','EventChain',...
            'HighlightSelectedBlocks',1};
            if~isempty(this.StyledSegments)||~isempty(this.StyledBlocks)
                this.Style=Simulink.Structure.Utils.highlightObjs(unique(this.StyledSegments),unique(this.StyledBlocks),options{:});
            end
            styler=swarch.internal.spreadsheet.EventChainHighlighter.getOrCreatePortEventStyler();
            swarch.internal.spreadsheet.EventChainHighlighter.styleAllPortEvents([this.StimulusSLPort,this.ResponseSLPort])
        end


        function delete(this)
            if~isempty(this.Style)
                this.Style.handles=this.Style.handles(ishandle(this.Style.handles));

                try
                    Simulink.SLHighlight.removeHighlight(this.Style);
                catch
                end
            end

            swarch.internal.spreadsheet.EventChainHighlighter.clearAllPortEventStyles([this.StimulusSLPort,this.ResponseSLPort])
        end


        function port=getRealPort(~,port)
            if strcmpi(get(port,'Type'),'block')
                pidx=str2double(get(port,'Port'));
                blk=get_param(get(port,'Parent'),'Handle');
                if~strcmp(get(blk,'Type'),'block_diagram')

                    ph=get_param(blk,'PortHandles');
                    if strcmpi(get(port,'BlockType'),'inport')
                        port=ph.Inport(pidx);
                    else
                        port=ph.Outport(pidx);
                    end
                else
                    ph=get_param(port,'PortHandles');
                    if strcmpi(get(port,'BlockType'),'outport')

                        port=ph.Inport;
                    else

                        port=ph.Outport;
                    end
                end
            end
        end

        function[stimulusPort,responsePort]=getStimulusAndResponseSLPorts(this)
            stimulusPort=[];
            responsePort=[];
            stimulus=this.EventChain.stimulus;
            if~isempty(stimulus)&&...
                isPortEvent(this,stimulus)
                p=stimulus.port;
                stimulusPort=systemcomposer.utils.getSimulinkPeer(p);
                if strcmpi(get(stimulusPort,'Type'),'block')
                    stimulusPort=getRealPort(this,stimulusPort);
                end
            end
            response=this.EventChain.response;
            if~isempty(response)&&...
                isPortEvent(this,response)
                p=response.port;
                responsePort=systemcomposer.utils.getSimulinkPeer(p);
                if strcmpi(get(responsePort,'Type'),'block')
                    responsePort=getRealPort(this,responsePort);
                end
            end
        end

    end


    methods(Access=private)
        function[segments,blocks]=findAllObjectsInChain(this)
            segments=[];
            blocks=[];
            beginPort=this.StimulusSLPort;
            endPort=this.ResponseSLPort;

            if isempty(beginPort)||isempty(endPort)
                return
            end
            paths=containers.Map('KeyType','double','ValueType','any');
            subChains=this.EventChain.subChains.toArray;
            if isempty(subChains)
                getBlocksAndSegmentsBetweenPorts(this,beginPort,endPort,[],[],paths);
            else
                for i=1:length(subChains)
                    ec=subChains(i);
                    if~isempty(ec.stimulus)&&...
                        isPortEvent(this,stimulus)&&...
                        ~isempty(ec.response)&&...
                        isPortEvent(this,response)

                        p=ec.stimulus.port;
                        beginSubchainPort=get_param(getfullname(systemcomposer.utils.getSimulinkPeer(p)),'Handle');
                        beginSubchainPort=getRealPort(this,beginSubchainPort);

                        p=ec.response.port;
                        endSubchainPort=get_param(getfullname(systemcomposer.utils.getSimulinkPeer(p)),'Handle');
                        endSubchainPort=getRealPort(this,endSubchainPort);

                        getBlocksAndSegmentsBetweenPorts(this,beginSubchainPort,endSubchainPort,[],[],paths);
                    end
                end
            end
            keys=paths.keys();
            for i=1:length(keys)
                path=paths(keys{i});
                segments=[segments,path{1}];
                blocks=[blocks,path{2}];
            end
        end


        function getBlocksAndSegmentsBetweenPorts(this,port,endPort,segments,blocks,paths)

            if port==endPort
                paths(paths.length()+1)={segments,blocks};
                return
            end
            if(strcmpi(get(port,'Type'),'port')&&strcmpi(get(port,'PortType'),'inport'))
                blk=get_param(get(port,'Parent'),'Handle');
                blocks=[blocks,blk];
                ph=get_param(blk,'PortHandles');
                for i=1:length(ph.Outport)
                    getBlocksAndSegmentsBetweenPorts(this,ph.Outport(i),endPort,segments,blocks,paths);
                end
            else
                line=get(port,'Line');

                if ishandle(line)
                    segmentPaths=containers.Map('KeyType','double','ValueType','any');
                    findConnectedPorts(this,line,segmentPaths);
                    keys=segmentPaths.keys;
                    for i=1:length(keys)
                        segmentPath=segmentPaths(keys{i});
                        getBlocksAndSegmentsBetweenPorts(this,segmentPath{1},endPort,[segments,segmentPath{2}],blocks,paths)
                    end
                end
            end
        end


        function findConnectedPorts(this,lines,paths)

            line=lines(end);
            ch=get(line,'LineChildren');

            if isempty(ch)
                p=get(line,'DstPortHandle');
                if~isempty(p)
                    paths(paths.length()+1)={p,lines};
                end
            else
                for i=1:length(ch)
                    findConnectedPorts(this,[lines,ch(i)],paths);
                end
            end
        end


        function tf=isPortEvent(~,event)
            tf=event.eventType==...
            systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_RECEIVE||...
            event.eventType==...
            systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_SEND;
        end
    end


    methods(Static)
        function styler=getOrCreatePortEventStyler()
            styler=diagram.style.getStyler('SwarchPortEventStyler');
            if isempty(styler)
                diagram.style.createStyler('SwarchPortEventStyler');
                styler=diagram.style.getStyler('SwarchPortEventStyler');
                style=diagram.style.Style;
                stroke=MG2.Stroke;
                purple=[0.5,0.0,0.5,0.8];
                stroke.Color=purple;
                stroke.Width=2;
                trace=MG2.TraceEffect(stroke,'Outer');
                glow=MG2.GlowEffect();
                glow.Color=purple;
                glow.Spread=10;
                glow.Gain=1;
                style.set('Trace',trace);
                style.set('Glow',glow);
                selector=diagram.style.ClassSelector('PortEventClass');

                rule=styler.addRule(style,selector);
            end
        end


        function styleAllPortEvents(ports)
            styler=swarch.internal.spreadsheet.EventChainHighlighter.getOrCreatePortEventStyler();
            for ii=1:numel(ports)
                blk=get(ports(ii),'Parent');
                if strcmp(get_param(blk,'Type'),'block')&&(strcmpi(get_param(blk,'BlockType'),'inport')||...
                    strcmpi(get_param(blk,'BlockType'),'outport'))
                    do=diagram.resolver.resolve(blk);
                else
                    do=diagram.resolver.resolve(ports(ii));
                end

                styler.applyClass(do,'PortEventClass')
            end
        end


        function clearAllPortEventStyles(ports)
            styler=swarch.internal.spreadsheet.EventChainHighlighter.getOrCreatePortEventStyler();
            for ii=1:numel(ports)
                blk=get(ports(ii),'Parent');
                if strcmp(get_param(blk,'Type'),'block')&&(strcmpi(get_param(blk,'BlockType'),'inport')||...
                    strcmpi(get_param(blk,'BlockType'),'outport'))
                    do=diagram.resolver.resolve(blk);
                else
                    do=diagram.resolver.resolve(ports(ii));
                end
                styler.removeClass(do,'PortEventClass');
            end
        end
    end

end


