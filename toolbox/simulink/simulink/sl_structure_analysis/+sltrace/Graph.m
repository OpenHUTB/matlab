classdef Graph<handle










































    properties(SetAccess=private,Hidden=true)
Option
TraceInfo
TraceModel
TraceModelName
TraceMap
BlockMap
NodeMap
NodeIndexMap
srcBlockMap
dstBlockMap
SpecialBlockMap
WirelessBlockMap
Digraph
Blocks
BlockHandles
Segments
srcNodes
dstNodes
LastActiveEditor
    end

    properties(Dependent)

SrcBlocks

DstBlocks



TraceGraph
    end


    methods


        function obj=Graph(varargin)


            obj.TraceMap=containers.Map('KeyType','Double','ValueType','any');







            obj.srcBlockMap=containers.Map('KeyType','Double','ValueType','any');

            obj.dstBlockMap=containers.Map('KeyType','Double','ValueType','any');


            obj.NodeIndexMap=containers.Map('KeyType','Double','ValueType','any');

            obj.NodeMap=containers.Map('KeyType','Double','ValueType','any');

            obj.SpecialBlockMap=containers.Map('KeyType','Double','ValueType','any');
            obj.WirelessBlockMap=containers.Map('KeyType','Char','ValueType','any');

            obj.BlockMap=containers.Map('KeyType','Char','ValueType','any');

            if nargin>1
                obj.Option=sltrace.internal.sltraceOptionsManager(varargin{:});
            else
                return;
            end





            segments=obj.Option.TraceSegmentHandle;
            for i=1:length(segments)
                seg=segments(i);
                obj.trace(seg,obj.Option.InterceptorHandle,obj.Option.BusPath);
            end
        end



        function value=get.SrcBlocks(obj)
            if~sltrace.utils.isValidObject(obj.TraceModel)
                return;
            end
            value=[];
            if ismember(obj.Option.TraceDirection,{'source','all source',...
                'source interceptor',...
                'source element'})
                value=obj.getBlocks;
            end
        end



        function value=get.DstBlocks(obj)
            if~sltrace.utils.isValidObject(obj.TraceModel)
                return;
            end
            value=[];
            if ismember(obj.Option.TraceDirection,{'destination',...
                'all destination',...
                'destination interceptor',...
                'destination element'})
                value=obj.getBlocks();
            end
        end



        function value=get.TraceGraph(obj)
            if~sltrace.utils.isValidObject(obj.TraceModel)
                return;
            end
            value=obj.Digraph;
        end


        function highlight(obj,varargin)









            if~sltrace.utils.isValidObject(obj.TraceModel)
                return;
            end

            if isempty(varargin)
                sltrace.internal.HighlightManager.HighlightSignal(...
                obj.TraceModel,obj.TraceMap,...
                obj.Option.OriginBlockHandle);
                return;
            end

            try
                sltrace.internal.HighlightManager.HighlightElements(...
                obj.TraceModel,varargin{:});
            catch ME
                throw(ME);
            end
        end


        function removeHighlight(obj)

            if~sltrace.utils.isValidObject(obj.TraceModel)
                return;
            end
            sltrace.internal.HighlightManager.RemoveHighlight(obj.TraceModel);
        end
    end


    methods(Access=private,Hidden=true)


        function delete(obj)

            obj.removeHighlight();
        end



        function obj=trace(obj,seg,interceptor,busPath)

            switch obj.Option.TraceDirection
            case 'source'
                isTraceToSrc=true;
                isTraceAll=false;
            case 'destination'
                isTraceToSrc=false;
                isTraceAll=false;
            case{'all source','source interceptor','source element'}
                isTraceToSrc=true;
                isTraceAll=true;
            case{'all destination','destination interceptor','destination element'}
                isTraceToSrc=false;
                isTraceAll=true;
            end
            obj.TraceInfo=sltrace.utils.getTraceInfo(isTraceToSrc,seg,isTraceAll,interceptor,busPath);


            obj.processTraceInfo();
            obj.convertSegmentToGraph();
            obj.getNodeMap();
            obj.getDigraph();
        end









        function processTraceInfo(obj)







            obj.TraceModel=obj.TraceInfo.traceBD;
            obj.TraceModelName=getfullname(obj.TraceModel);

            graphMap=obj.TraceInfo.graphHighlightMap;



            [row,~]=size(graphMap);
            for i=1:row
                graphH=graphMap{i,1};
                element=unique(graphMap{i,2},'stable');
                if~obj.TraceMap.isKey(graphH)
                    obj.TraceMap(graphH)=element;
                else
                    obj.TraceMap(graphH)=unique([obj.TraceMap(graphH),element],'stable');
                end
            end


            elements=cell2mat(obj.TraceMap.values);
            len=length(elements);
            blocks=zeros(1,len);
            segments=zeros(1,len);
            for i=1:len
                elementType=get_param(elements(i),'Type');
                switch elementType
                case 'block'
                    blocks(i)=elements(i);
                case 'line'
                    if isempty(get_param(elements(i),'LineChildren'))
                        segments(i)=elements(i);
                    end
                end
            end
            blocks=blocks(blocks~=0);
            obj.BlockHandles=blocks;

            segments=segments(segments~=0);
            obj.Segments=segments;



            obj.LastActiveEditor=obj.Option.LastActiveEditor;
        end



        function convertSegmentToGraph(obj)








            [srcNodesInter,dstNodesInter]=obj.getInterBlockConnections();
            [srcNodesIn,dstNodesIn]=obj.getInBlockConnections();
            [srcNodesSp,dstNodesSp]=obj.getSpecialBlockConnections();
            [srcNodesWi,dstNodesWi]=obj.getWirelessBlockConnections();
            obj.srcNodes=[srcNodesInter,srcNodesIn,srcNodesSp,srcNodesWi];
            obj.dstNodes=[dstNodesInter,dstNodesIn,dstNodesSp,dstNodesWi];
        end



        function[srcNodes,dstNodes]=getInterBlockConnections(obj)








            blockHandles=obj.BlockHandles;
            segs=obj.Segments;
            len=length(segs);
            srcNodes=zeros(1,len);
            dstNodes=zeros(1,len);

            for i=1:len
                seg=segs(i);

                srcNode=get_param(seg,'SrcPortHandle');
                dstNode=get_param(seg,'DstPortHandle');


                if~obj.NodeIndexMap.isKey(srcNode)
                    obj.NodeIndexMap(srcNode)=double(obj.NodeIndexMap.Count)+1;
                end

                if~obj.NodeIndexMap.isKey(dstNode)
                    obj.NodeIndexMap(dstNode)=double(obj.NodeIndexMap.Count)+1;
                end


                srcNodes(1,i)=srcNode;
                dstNodes(1,i)=dstNode;


                srcBlockH=get_param(seg,'SrcBlockHandle');
                ind=find(blockHandles==srcBlockH,1);
                if~isempty(ind)
                    blockHandles(ind)=0;
                end

                if~obj.srcBlockMap.isKey(srcBlockH)
                    obj.srcBlockMap(srcBlockH)=srcNode;
                else
                    oPort=obj.srcBlockMap(srcBlockH);
                    oPort=unique([oPort,srcNode]);
                    obj.srcBlockMap(srcBlockH)=oPort;
                end


                dstBlockH=get_param(seg,'DstBlockHandle');
                ind=find(blockHandles==dstBlockH,1);
                if~isempty(ind)
                    blockHandles(ind)=0;
                end

                if~obj.dstBlockMap.isKey(dstBlockH)
                    obj.dstBlockMap(dstBlockH)=dstNode;
                else
                    iPort=obj.dstBlockMap(dstBlockH);
                    iPort=unique([iPort,dstNode]);
                    obj.dstBlockMap(dstBlockH)=iPort;
                end
                obj.processSpecialBlocks([[srcBlockH,dstBlockH];[srcNode,dstNode]]);
            end
            blockHandles=blockHandles(blockHandles~=0);












            if length(blockHandles)>1
                [srcNodesUnconn,dstNodesUnconn]=obj.processUnconnectedBlocks(blockHandles);
                srcNodes=[srcNodes,srcNodesUnconn];
                dstNodes=[dstNodes,dstNodesUnconn];
            end
        end



        function[srcNodes,dstNodes]=processUnconnectedBlocks(obj,blockHandles)




















            len=length(blockHandles);
            srcNodes=zeros(1,len);
            dstNodes=zeros(1,len);
            counter=1;

            for i=1:len
                block=blockHandles(i);
                blockType=get_param(block,'BlockType');

                if strcmp(blockType,'SubSystem')
                    portConn=get_param(block,'PortConnectivity');
                    inPortBlocks=[portConn.SrcBlock];

                    if~isempty(inPortBlocks)
                        for j=1:length(inPortBlocks)
                            inPortBlock=inPortBlocks(j);
                            inPortBlockType=get_param(inPortBlock,'BlockType');
                            if ismember(inPortBlock,blockHandles)&&strcmp(inPortBlockType,'Inport')


                                srcNode=get_param(inPortBlock,'PortHandles').Outport;
                                dstNode=get_param(block,'PortHandles').Inport(j);

                                if~obj.NodeIndexMap.isKey(srcNode)
                                    obj.NodeIndexMap(srcNode)=double(obj.NodeIndexMap.Count)+1;
                                end
                                if~obj.NodeIndexMap.isKey(dstNode)
                                    obj.NodeIndexMap(dstNode)=double(obj.NodeIndexMap.Count)+1;
                                end

                                srcNodes(counter)=srcNode;
                                dstNodes(counter)=dstNode;
                                counter=counter+1;


                                obj.processSpecialBlocks([[inPortBlock,block];[srcNode,dstNode]]);
                            end
                        end
                    end
                elseif strcmp(blockType,'Outport')
                    srcBlock=get_param(block,'PortConnectivity').SrcBlock;
                    idx=str2double(get_param(block,'PortConnectivity').Type);

                    srcNode=get_param(srcBlock,'PortHandles').Outport(idx);
                    dstNode=get_param(block,'PortHandles').Inport;

                    if~obj.NodeIndexMap.isKey(srcNode)
                        obj.NodeIndexMap(srcNode)=double(obj.NodeIndexMap.Count)+1;
                    end
                    if~obj.NodeIndexMap.isKey(dstNode)
                        obj.NodeIndexMap(dstNode)=double(obj.NodeIndexMap.Count)+1;
                    end

                    srcNodes(counter)=srcNode;
                    dstNodes(counter)=dstNode;
                    counter=counter+1;

                    obj.processSpecialBlocks([[srcBlock,block];[srcNode,dstNode]]);
                else
                    continue;
                end
            end
            srcNodes=srcNodes(srcNodes~=0);
            dstNodes=dstNodes(dstNodes~=0);
        end





        function processSpecialBlocks(obj,pairs)


            blocks=pairs(1,:);
            for i=1:length(blocks)
                block=blocks(i);
                blockType=get_param(block,'BlockType');
                switch blockType
                case 'Inport'
                    parentBlock=get_param(block,'Parent');
                    parentBlockType=get_param(parentBlock,'Type');
                    if~strcmp(parentBlockType,'block')
                        continue;
                    end
                    portIdx=str2double(get_param(block,'Port'));
                    inportH=get_param(parentBlock,'PortHandles').Inport(portIdx);
                    obj.SpecialBlockMap(inportH)=pairs(2,i);
                    if~obj.NodeIndexMap.isKey(inportH)
                        obj.NodeIndexMap(inportH)=double(obj.NodeIndexMap.Count)+1;
                    end
                case 'Outport'
                    parentBlock=get_param(block,'Parent');
                    parentBlockType=get_param(parentBlock,'Type');
                    if~strcmp(parentBlockType,'block')
                        continue;
                    end
                    portIdx=str2double(get_param(block,'Port'));
                    outportH=get_param(parentBlock,'PortHandles').Outport(portIdx);
                    obj.SpecialBlockMap(pairs(2,i))=outportH;
                    if~obj.NodeIndexMap.isKey(outportH)
                        obj.NodeIndexMap(outportH)=double(obj.NodeIndexMap.Count)+1;
                    end
                case{'From','Goto'}
                    gotoTag=get_param(block,'GotoTag');
                    if obj.WirelessBlockMap.isKey(gotoTag)
                        vec=obj.WirelessBlockMap(gotoTag);

                        if strcmp(blockType,'Goto')
                            vec=[pairs(2,i),vec];
                        else
                            vec=[vec,pairs(2,i)];
                        end
                        obj.WirelessBlockMap(gotoTag)=vec;
                    else
                        obj.WirelessBlockMap(gotoTag)=pairs(2,i);
                    end
                case{'EntityMulticast','Queue'}



                    portConn=get_param(block,'PortConnectivity');
                    if length(portConn)~=1
                        continue;
                    end
                    multicastTag=get_param(block,'MulticastTag');
                    if obj.WirelessBlockMap.isKey(multicastTag)

                        vec=obj.WirelessBlockMap(multicastTag);
                        if strcmp(blockType,'EntityMulticast')

                            vec=[pairs(2,i),vec];
                        else
                            vec=[vec,pairs(2,i)];
                        end
                        obj.WirelessBlockMap(multicastTag)=vec;
                    else
                        obj.WirelessBlockMap(multicastTag)=pairs(2,i);
                    end
                end
            end
        end




        function[srcNodes,dstNodes]=getSpecialBlockConnections(obj)
            keys=obj.SpecialBlockMap.keys;
            valueLen=length(cell2mat(obj.SpecialBlockMap.values));
            srcNodes=zeros(1,valueLen);
            dstNodes=zeros(1,valueLen);
            count=1;
            for i=1:obj.SpecialBlockMap.Count
                srcNode=keys{i};
                dstNode=obj.SpecialBlockMap(srcNode);
                len=length(dstNode);
                if len>1
                    srcNode=repelem(srcNode,len);
                end
                srcNodes(count:count+len-1)=srcNode;
                dstNodes(count:count+len-1)=dstNode;
                count=count+len;
            end
        end




        function[srcNodesWi,dstNodesWi]=getWirelessBlockConnections(obj)
            srcNodesWi=[];
            dstNodesWi=[];
            idx=1;
            keys=obj.WirelessBlockMap.keys;
            for i=1:obj.WirelessBlockMap.Count
                vec=obj.WirelessBlockMap(keys{i});
                if length(vec)<2

                    continue;
                end
                sNode=vec(1);
                srcBlock=get_param(sNode,'Parent');
                if~ismember(get_param(srcBlock,'BlockType'),{'Goto','EntityMulticast'})

                    continue;
                end
                dNodes=unique(vec(2:end),'stable');
                lenDstNode=length(dNodes);
                sNodes=repelem(sNode,lenDstNode);
                srcNodesWi(idx:idx+lenDstNode-1)=sNodes;
                dstNodesWi(idx:idx+lenDstNode-1)=dNodes;
                idx=idx+lenDstNode;
            end
        end



        function[srcNodes,dstNodes]=getInBlockConnections(obj)

            srcNodes=[];
            dstNodes=[];
            dstBlocks=obj.dstBlockMap.keys;
            nodeCount=1;
            for j=1:obj.dstBlockMap.Count
                block=dstBlocks{j};
                blockType=get_param(block,'BlockType');



                if~obj.srcBlockMap.isKey(block)||(strcmp(blockType,'SubSystem'))
                    continue;
                end
                inports=obj.dstBlockMap(block);
                outports=obj.srcBlockMap(block);
                srcPort=repelem(inports,length(outports));
                dstPort=repmat(outports,[1,length(inports)]);
                gap=length(srcPort);
                srcNodes(1,nodeCount:nodeCount+gap-1)=srcPort;
                dstNodes(1,nodeCount:nodeCount+gap-1)=dstPort;
                nodeCount=nodeCount+gap;
            end
        end



        function getNodeMap(obj)




            nodes=obj.NodeIndexMap.keys;
            for k=1:length(nodes)

                node=nodes{k};
                idx=obj.NodeIndexMap(node);
                obj.NodeMap(idx)=node;
            end
        end








        function segments=getSegmentsFromNodes(obj)
            len=length(obj.dstNodes);
            segments=cell(1,len);
            for i=1:len
                dstNode=obj.dstNodes(i);
                srcNode=obj.srcNodes(i);
                dstBlock=get_param(dstNode,'Parent');
                srcBlock=get_param(srcNode,'Parent');
                dstBlockType=get_param(dstBlock,'BlockType');
                srcBlockType=get_param(srcBlock,'BlockType');
                if strcmp(srcBlock,dstBlock)
                    segments{i}='Internal';
                elseif strcmp(dstBlockType,'Inport')||...
                    ismember(srcBlockType,{'Outport','Goto','EntityMulticast'})
                    segments{i}='Hidden';
                else
                    seg=get_param(dstNode,'line');
                    segment=sltrace.utils.getLineFromSegment(seg);
                    if isempty(segment)
                        segments{i}='Hidden';
                        continue;
                    end
                    segments{i}=segment;
                end
            end
        end



        function varargout=getBlocks(obj)
            bp=obj.BlockMap.values;
            bn=obj.BlockMap.keys;
            varargout{1}=[bp{:}];
            varargout{2}=[bn{:}];
        end



        function getDigraph(obj)
            segments=obj.getSegmentsFromNodes();
            edgeTable=table(segments','VariableNames',{'Segments'});
            srcNodeIndex=arrayfun(@(x)obj.NodeIndexMap(x),obj.srcNodes);
            dstNodeIndex=arrayfun(@(x)obj.NodeIndexMap(x),obj.dstNodes);
            value=digraph(srcNodeIndex,dstNodeIndex,edgeTable);


            [block,portNum,portType]=obj.parseNodeMap;
            keys=obj.NodeMap.keys;
            value.Nodes.NodeIndex=[keys{:}]';

            value.Nodes.Block=block';
            value.Nodes.PortNumber=portNum';
            value.Nodes.PortType=portType';
            obj.Digraph=value;
        end












        function[blocks,portNum,portType]=parseNodeMap(obj)

            len=obj.NodeMap.Count;
            portNum=zeros(1,len);
            portType=strings(1,len);
            blocks=zeros(0,len);
            if strcmp(obj.Option.EnableBlockPath,'on')
                blocks=Simulink.BlockPath.empty(0,len);
            end

            for i=1:len
                Node=obj.NodeMap(i);
                blockName=get_param(Node,'Parent');
                blockHandle=get_param(blockName,'Handle');

                if strcmp(obj.Option.EnableBlockPath,'on')
                    block=sltrace.utils.getBlockPathFromBlock(blockHandle,obj.LastActiveEditor);
                else
                    block=blockHandle;
                end

                if~obj.BlockMap.isKey(blockName)&&...
                    blockHandle~=obj.Option.OriginBlockHandle&&...
                    ismember(blockHandle,obj.BlockHandles)
                    obj.BlockMap(blockName)=block;
                end

                blocks(i)=block;
                portNum(i)=get_param(Node,'PortNumber');
                portType(i)=get_param(Node,'PortType');
            end
        end
    end
end




















