



classdef device<handle

    properties(SetAccess=private,Hidden)
graph
radio_name
        is_committed=false
blocks
        noc_block_list={}
    end

    methods(Hidden,Access={?handle})
        function graph=getGraph(obj)
            graph=obj.graph;
        end
    end


    methods
        function obj=device()

            wt.internal.uhd.mcos.setup();

            obj.graph=uhd.internal.Device;
            obj.blocks=containers.Map();
        end

        function makeDevice(obj,varargin)



            builtin('license','checkout','Wireless_Testbench');
            builtin('license','checkout','Communication_Toolbox');
            builtin('license','checkout','Signal_Blocks');
            builtin('license','checkout','Signal_Toolbox');


            if nargin<=1
                args="";
            else
                args=varargin{1};
            end
            try
                obj.graph.makeDevice(args);
            catch ME
                rethrow(ME);
            end
            obj.radio_name=obj.graph.deviceAddr(args);
        end

        function addEdge(obj,nodePair,varargin)

            first_block_name=nodePair{1};
            first_port=nodePair{2};
            second_block_name=nodePair{3};
            second_port=nodePair{4};
            if first_port>8
                error(message("wt:rfnoc:host:InvalidPort",first_block_name,first_port));
            end
            if second_port>8
                error(message("wt:rfnoc:host:InvalidPort",second_block_name,second_port));
            end

            first_block=obj.getNode(first_block_name);
            if isempty(varargin)
                addOutConnection(first_block,first_port,second_block_name,second_port);
            else
                addOutConnection(first_block,first_port,second_block_name,second_port,varargin{1});
            end

            second_block=obj.getNode(second_block_name);
            addInConnection(second_block,first_block_name,first_port,second_port);
        end


        function rfnoc_block=makeNode(obj,noc_block)
            if contains(noc_block,"Radio","IgnoreCase",true)
                rfnoc_block=wt.internal.uhd.mcos.radio_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"Replay","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.replay_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"DUC","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.duc_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"DDC","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.ddc_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"NullSrcSink","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.nullsrcsink_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"SigGen","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.siggen_block(obj.radio_name,noc_block);
            elseif(contains(noc_block,"TX_STREAM","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.tx_stream(noc_block,obj.radio_name);
            elseif(contains(noc_block,"RX_STREAM","IgnoreCase",true))
                rfnoc_block=wt.internal.uhd.mcos.rx_stream(noc_block,obj.radio_name);
            else
                rfnoc_block=wt.internal.uhd.mcos.custom_block(obj.radio_name,noc_block);
            end
        end

        function node=getNode(obj,noc_block)
            if isKey(obj.blocks,noc_block)
                node=obj.blocks(noc_block);
            else
                obj.blocks(noc_block)=makeNode(obj,noc_block);
                node=obj.blocks(noc_block);
            end
        end

        function defineGraph(obj,blockNames,varargin)




            if length(blockNames)==1
                obj.getBlock(cellstr(blockNames));

            elseif~iscell(blockNames)
                obj.noc_block_list=cell(1,4*(length(blockNames)-1));
                n=1;
                for idx=1:length(blockNames)-1
                    obj.noc_block_list{n}=blockNames(idx);
                    obj.noc_block_list{n+1}=0;
                    obj.noc_block_list{n+2}=blockNames(idx+1);
                    obj.noc_block_list{n+3}=0;
                    n=n+4;
                end
            else
                obj.noc_block_list=blockNames;
            end
            obj.populateBlocks(obj.noc_block_list);
        end


        function populateBlocks(obj,blockList,varargin)

            if length(blockList)==1

                getNode(obj,blockList{1});
            else
                if~mod(length(blockList),4)
                    for n=1:4:length(blockList)
                        nodePair=blockList(n:n+3);
                        obj.addEdge(nodePair);
                    end
                else
                    error(message("wt:rfnoc:host:InvalidGraph"));
                end
            end
        end

        function connectGraph(obj,node)

            for n=1:getOutCount(node)
                [sourcePort,nextBlock,destinationPort,propertyPropagation]=node.getOutConnection(n);
                blockToBlock=isa(node,'wt.internal.uhd.mcos.block')&&...
                isa(obj.getNode(nextBlock),'wt.internal.uhd.mcos.block');
                blockToStreamer=isa(node,'wt.internal.uhd.mcos.block')&&...
                isa(obj.getNode(nextBlock),'wt.internal.uhd.mcos.stream');


                args={node.name,sourcePort,nextBlock,destinationPort};
                try
                    if blockToBlock
                        args{end+1}=~propertyPropagation;%#ok<AGROW>
                        obj.graph.connect_block(args{:});
                    elseif blockToStreamer
                        streamer=obj.getBlock(nextBlock);
                        streamer.connectStreamBlocks(node.name,sourcePort,destinationPort);
                    else
                        streamer=obj.getBlock(node.name);
                        streamer.connectStreamBlocks(nextBlock,destinationPort,sourcePort);
                    end
                catch ME
                    rethrow(ME);
                end
            end
        end

        function stream=getTransmitStream(obj,streamBlock,varargin)









            stream=obj.blocks(streamBlock);
            num_channels=getOutCount(stream);
            stream.getTxStream(num_channels,varargin{:});
        end

        function stream=getReceiveStream(obj,streamBlock,varargin)









            stream=obj.blocks(streamBlock);
            num_channels=getInCount(stream);
            stream.getRxStream(num_channels,varargin{:});
        end

        function buildGraph(obj)
            cellfun(@obj.connectGraph,values(obj.blocks));

            obj.graph.buildGraph();
            obj.is_committed=true;
        end

        function writeRegister(obj,blockName,reg,regVal,varargin)

            block=obj.blocks(blockName);
            block.writeRegister(reg,regVal,varargin{:});
        end

        function regVal=readRegister(obj,blockName,reg,varargin)

            block=obj.blocks(blockName);
            regVal=block.readRegister(reg,varargin{:});
        end













        function rfnoc_block=getBlock(obj,NocBlock)
            rfnoc_block=getNode(obj,NocBlock);
        end

        function block_list=getAvailableBlocks(obj)
            block_list=obj.graph.getAvailableBlocks();
            block_list=string(reshape(block_list,1,length(block_list)));
        end

        function tf=doesCustomBlockExist(obj,id)
            block_list=getAvailableBlocks(obj);
            for n=1:length(block_list)
                block=block_list(n);
                if~any(regexp(block,"/Block#"))
                    continue
                end
                noc_id=obj.graph.getNocId(block);
                if noc_id==uint32(hex2dec(id))
                    tf=true;
                    return
                end
            end
            tf=false;
        end

        function destroyGraph(obj)
            if~isempty(obj.radio_name)
                if obj.is_committed
                    obj.graph.destroyGraph();
                    obj.is_committed=false;
                end
                obj.graph.disconnectGraph();
            end
        end

        function[tf,id]=hasBlockName(obj,name)
            info=obj.graph.hasBlockName(name);
            if~isempty(info{1})
                tf=info{1};
                id=dec2hex(info{2});
            else
                tf=false;
                id=[];
            end
        end

        function[tf,name]=hasBlockID(obj,id)
            info=obj.graph.hasBlockID(uint32(hex2dec(id)));
            if~isempty(info{1})
                tf=true;
                name=info{2};
            else
                tf=false;
                name=[];
            end
        end

        function id=hasBlock(obj,noc_block)
            if~isKey(obj.blocks,noc_block)
                id=false;
            else
                id=true;
            end
        end
    end
end


