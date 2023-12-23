classdef CriticalPathHighlighter<handle

    properties
MappingData
HighlightedPaths
HighlightedCostInfo
CostAnnotations
UIObj
    end


    events
HighlightingOnEvent
HighlightingOffEvent
    end


    methods
        function obj=CriticalPathHighlighter(uiObj)
            obj.UIObj=uiObj;
            obj.HighlightedPaths=containers.Map('KeyType','double','ValueType','any');
        end


        function mappingData=get.MappingData(obj)
            mappingData=getMappingData(obj.UIObj);
        end


        function highlightAll(obj)
            removeAllHighlighting(obj);
            numMappings=getNumMapping(obj.MappingData);
            for i=1:numMappings
                modelPath=getModelPath(obj.MappingData,i);
                bp=Simulink.BlockPath([modelPath,{getParentSystemName(obj.MappingData,i)}]);
                bp.open;
                [blocks,ports]=getCriticalPath(obj.MappingData,i);
                highlightCriticalPath(obj,i,blocks,ports);
            end

            if isempty(obj.HighlightedPaths)
                notify(obj,'HighlightingOnEvent');
            end
        end


        function removeAllHighlighting(obj)

            keys=obj.HighlightedPaths.keys;
            for i=1:length(keys)
                style=obj.HighlightedPaths(keys{i});
                removeHighlightByStyle(obj,style);
            end
            remove(obj.HighlightedPaths,keys);
            notify(obj,'HighlightingOffEvent');
        end
    end


    methods(Access=private)

        function highlightCriticalPath(obj,systemId,blocks,ports)
            options={'HighLightColor',[1,1,0],'highlightstyle','SolidLine',...
            'HighlightWidth',3,'tag',['CriticalPath',num2str(0)],...
            'blockedgecolor',[0.6,0.6,0.6],...
            'segmentcolor',[0.6,0.6,0.6],...
            'HighlightSelectedBlocks',1};

            modelPath=getModelPath(obj.MappingData,systemId);
            [segments,blocks]=getHighlightPath(obj,blocks,ports,modelPath);
            obj.HighlightedPaths(systemId)=Simulink.Structure.Utils.highlightObjs(segments,blocks,options{:});

        end


        function removeHighlightByStyle(~,style)
            if~isempty(style)
                style.handles=style.handles(ishandle(style.handles));

                Simulink.SLHighlight.removeHighlight(style);
            end
        end


        function[segmentsToHighlight,blocksToHighlight]=getHighlightPath(obj,blocks,ports,modelPath)

            segmentsToHighlight=[];
            blocksToHighlight=[];
            blockVisited=containers.Map('KeyType','double','ValueType','any');

            for i=1:length(blocks)

                blocksToHighlight=[blocksToHighlight,blocks(i)];
                blockVisited(blocks(i))=1;

                if strcmpi(get(blocks(i),'BlockType'),'subsystem')

                    [nestedSegs,nestedBlks]=findAllBlocksAndSegmentsInSubsystem(obj,blocks(i));
                    blocksToHighlight=[blocksToHighlight,nestedBlks];
                    segmentsToHighlight=[segmentsToHighlight,nestedSegs];
                end

                portIdx=ports{i};
                if isempty(portIdx)
                    subsystems=multicoredesigner.internal.MappingData.getAllVirtualAncestors(blocks(i));
                    for j=1:length(subsystems)
                        parentSS=subsystems(j);
                        if~isKey(blockVisited,parentSS)
                            blocksToHighlight=[blocksToHighlight,parentSS];
                            blockVisited(parentSS)=1;
                            if j==1
                                bp=Simulink.BlockPath([modelPath,{getfullname(parentSS)}]);
                                bp.open;
                            end
                        end
                    end
                else

                    ph=get_param(blocks(i),'PortHandles');
                    for j=1:length(portIdx)
                        line=get(ph.Inport(portIdx(j)+1),'line');
                        [segmentsToSrc,blocksToSrc]=getPathToSrc(obj,line,blockVisited);
                        blocksToHighlight=[blocksToHighlight,blocksToSrc];
                        segmentsToHighlight=[segmentsToHighlight,segmentsToSrc];
                    end
                end
            end
        end


        function[segmentsToSrc,blocksToSrc]=getPathToSrc(~,segment,blockVisited)

            segmentsToSrc=[];
            blocksToSrc=[];
            hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(true,segment,false);
            traceMap=hiliteInfo.graphHighlightMap;

            for k=1:size(traceMap,1)
                nodes=traceMap{k,2};
                for l=1:length(nodes)
                    if strcmp(get(nodes(l),'type'),'line')
                        segmentsToSrc=[segmentsToSrc,nodes(l)];
                    else
                        if strcmp(get(nodes(l),'type'),'block')&&...
                            ~isKey(blockVisited,nodes(l))
                            blocksToSrc=[blocksToSrc,nodes(l)];
                            blockVisited(nodes(l))=1;
                        end
                    end
                end
            end
        end


        function[allSegments,allBlocks]=findAllBlocksAndSegmentsInSubsystem(obj,ssBlk)

            blocks=find_system(ssBlk,'SearchDepth',1,'LookUnderMasks',...
            'all','FollowLinks','on','FindAll','on','type','block');
            allBlocks=blocks(2:end)';
            segments=find_system(ssBlk,'SearchDepth',1,'LookUnderMasks',...
            'all','FollowLinks','on','FindAll','on','type','line');
            allSegments=segments';

            blocks=allBlocks;
            for i=1:length(blocks)
                if strcmpi(get(blocks(i),'BlockType'),'subsystem')
                    [nestedSegments,nestedBlocks]=findAllBlocksAndSegmentsInSubsystem(obj,blocks(i));
                    allSegments=[allSegments,nestedSegments];
                    allBlocks=[allBlocks,nestedBlocks];
                end
            end
        end
    end
end


