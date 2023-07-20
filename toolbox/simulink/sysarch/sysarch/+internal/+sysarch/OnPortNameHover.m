function elts=OnPortNameHover(slBdH,graphH,portName,isComposite,isInput)
    elts=findRegularPortsWithName(slBdH,graphH,portName,isInput);

    function blks=findRegularPortsWithName(slBdH,graphH,portName,isInput)
        if(isInput)
            blks=find_system(graphH,'SearchDepth',1,'LookUnderMasks','on',...
            'FollowLinks','on','BlockType','Inport','Name',portName);
        else
            blks=find_system(graphH,'SearchDepth',1,'LookUnderMasks','on',...
            'FollowLinks','on','BlockType','Outport','Name',portName);

        end
        lines=findLinesForPorts(blks,isInput,graphH,slBdH);
        blks=[blks;lines];


        function lines=findLinesForPorts(ports,isInput,graphH,slBdH)
            lines=[];
            for i=1:length(ports)
                ph=get_param(ports(i),'PortHandles');
                l=[];
                if(isInput)
                    l=get_param(ph.Outport,'Line');
                else
                    l=get_param(ph.Inport,'Line');
                end
                seg=SLM3I.SLDomain.handle2DiagramElement(l);
                if(seg.isvalid()&&isa(seg,'SLM3I.Segment'))
                    highlightInfo=[];
                    if(isInput)
                        highlightInfo=SLM3I.SLDomain.getHighlightToDestInfo(seg);
                    else
                        highlightInfo=SLM3I.SLDomain.getHighlightToSrcInfo(seg);
                    end
                    if(~isempty(highlightInfo))
                        hiliteMap=highlightInfo.graphHighlightMap;
                        for k=1:length(hiliteMap)
                            if(hiliteMap{k}==graphH)
                                if~isempty(hiliteMap{k,2})
                                    lines=[lines;hiliteMap{k,2}'];
                                    break;
                                end
                            end
                        end
                    end
                end



                slprivate('remove_hilite',slBdH);
                SLM3I.SLDomain.removeBdFromHighlightMode(slBdH);
            end
