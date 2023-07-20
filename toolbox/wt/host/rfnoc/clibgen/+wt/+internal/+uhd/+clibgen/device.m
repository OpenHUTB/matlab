classdef device<handle




    properties(Access=private)
blocks

graph

isGraphCommitted
    end

    methods(Hidden,Access={?handle})
        function graph=getGraph(obj)
            graph=obj.graph;
        end
    end

    methods(Access=protected)
        function node=makeNode(obj,name)

            import wt.internal.uhd.clibgen.*
            if contains(name,"Radio","IgnoreCase",true)
                node=radio_block(obj.graph,name);
            elseif(contains(name,"Replay","IgnoreCase",true))
                node=replay_block(obj.graph,name);
            elseif(contains(name,"DUC","IgnoreCase",true))
                node=duc_block(obj.graph,name);
            elseif(contains(name,"DDC","IgnoreCase",true))
                node=ddc_block(obj.graph,name);
            elseif(contains(name,"NullSrcSink","IgnoreCase",true))
                node=nullsrcsink_block(obj.graph,name);
            elseif(contains(name,"SigGen","IgnoreCase",true))
                node=siggen_block(obj.graph,name);
            elseif(contains(name,"TX_STREAM","IgnoreCase",true))
                node=tx_stream(name);
            elseif(contains(name,"RX_STREAM","IgnoreCase",true))
                node=rx_stream(name);
            else
                node=block(obj.graph,name);
            end
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

        function node=getNode(obj,name)
            if isKey(obj.blocks,name)
                node=obj.blocks(name);
            else
                obj.blocks(name)=obj.makeNode(name);
                node=obj.blocks(name);
            end
        end

        function connectGraph(obj,node)
            sourceID=getID(node);

            for n=1:getOutCount(node)
                [sourcePort,nextBlock,destinationPort,propertyPropagation]=node.getOutConnection(n);
                destinationID=getID(obj.blocks(nextBlock));
                args={sourceID,sourcePort,destinationID,destinationPort};
                blockToBlock=isa(node,'wt.internal.uhd.clibgen.block')&&...
                isa(obj.getNode(nextBlock),'wt.internal.uhd.clibgen.block');


                if blockToBlock
                    args{end+1}=~propertyPropagation;%#ok<AGROW>
                end
                obj.graph.connect(args{:});
            end
        end

    end
    methods
        function obj=device()

            wt.internal.uhd.clibgen.setup();
            obj.blocks=containers.Map();
            obj.isGraphCommitted=false;
        end

        function makeDevice(obj,varargin)



            builtin('license','checkout','Wireless_Testbench');
            builtin('license','checkout','Communication_Toolbox');
            builtin('license','checkout','Signal_Blocks');
            builtin('license','checkout','Signal_Toolbox');


            libIsLoaded=clibgen.internal.clibpackageisLoaded("wt_uhd");
            if~libIsLoaded
                disp(message("wt:rfnoc:host:LoadingUHDLibs").getString);


                [~]=help("clib.wt_uhd");
                disp(message("wt:rfnoc:host:UHDLibsLoaded").getString);
            end

            if nargin>1
                dev=clib.wt_uhd.uhd.device_addr_t(varargin{1});
            else
                dev=clib.wt_uhd.uhd.device_addr_t();
            end
            obj.graph=clib.wt_uhd.uhd.rfnoc.rfnoc_graph.make(dev);
        end

        function defineGraph(obj,blockNames,varargin)
            if length(blockNames)==1
                list=cellstr(blockNames);

            elseif~iscell(blockNames)
                list=cell(1,4*(length(blockNames)-1));
                n=1;
                for idx=1:length(blockNames)-1
                    list{n}=blockNames(idx);
                    list{n+1}=0;
                    list{n+2}=blockNames(idx+1);
                    list{n+3}=0;
                    n=n+4;
                end
            else
                list=blockNames;
            end
            obj.populateBlocks(list);
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
        function buildGraph(obj)
            cellfun(@obj.connectGraph,values(obj.blocks));
            obj.graph.commit();
            obj.isGraphCommitted=true;
        end

        function destroyGraph(obj)


            if obj.isGraphCommitted
                obj.graph.release();
                obj.isGraphCommitted=false;
            end
            edges=obj.graph.enumerate_active_connections();
            for n=1:edges.Dimensions
                e=edges(n);



                if eq(e.edge,clib.wt_uhd.uhd.rfnoc.graph_edge_t.edge_t.TX_STREAM)
                    obj.graph.disconnect(e.src_blockid,e.src_port);
                elseif eq(e.edge,clib.wt_uhd.uhd.rfnoc.graph_edge_t.edge_t.RX_STREAM)
                    obj.graph.disconnect(e.dst_blockid,e.dst_port);
                else
                    obj.graph.disconnect(clib.wt_uhd.uhd.rfnoc.block_id_t(e.src_blockid),...
                    e.src_port,...
                    clib.wt_uhd.uhd.rfnoc.block_id_t(e.dst_blockid),...
                    e.dst_port);
                end
            end

            obj.blocks=containers.Map();
        end

        function blockList=getAvailableBlocks(obj)
            rfnoc_blocks=obj.graph.find_blocks("");
            blockList=strings(1,rfnoc_blocks.Dimensions);
            for n=1:rfnoc_blocks.Dimensions
                rfnoc_block=rfnoc_blocks(n);
                blockList(n)=rfnoc_block.to_string;
            end
            clibRelease(rfnoc_blocks);
        end



        function block_ctrl=getControl(obj,name,varargin)
            block=makeNode(obj,name);
            block_ctrl=getControl(block,varargin{:});

        end

        function block=getBlock(obj,name,varargin)
            if isKey(obj.blocks,name)
                block=obj.blocks(name);
            else
                error(message("wt:rfnoc:host:BlockNotFound",name));
            end
        end

        function[tf,id]=hasBlockName(obj,name)
            block_id=clib.wt_uhd.uhd.rfnoc.block_id_t(name);
            tf=obj.graph.has_block(block_id);
            if tf
                noc_block=obj.graph.get_block(block_id);
                noc_id=noc_block.get_noc_id();
                id=dec2hex(noc_id);
                clibRelease(noc_block);
            else
                id=[];
            end
        end

        function[tf,name]=hasBlockID(obj,id)
            blockList=getAvailableBlocks(obj);
            for n=1:length(blockList)
                blockName=blockList(n);
                noc_block=obj.graph.get_block(clib.wt_uhd.uhd.rfnoc.block_id_t(blockName));
                noc_id=noc_block.get_noc_id();
                clibRelease(noc_block);
                if noc_id==uint32(hex2dec(id))
                    tf=true;
                    name=blockName;
                    return
                end
            end
            tf=false;
            name=[];
        end

        function writeRegister(obj,blockName,reg,regVal,varargin)
            block=obj.blocks(blockName);
            block.writeRegister(reg,regVal,varargin{:});
        end

        function regVal=readRegister(obj,blockName,reg,varargin)
            block=obj.blocks(blockName);
            regVal=block.readRegister(reg,varargin{:});
        end

        function setArg(obj,blockName,arg,argVal,varargin)
            block=obj.blocks(blockName);
            block.setArg(arg,argVal,varargin{:});
        end

        function argVal=getArg(obj,blockName,arg,varargin)
            block=obj.blocks(blockName);
            argVal=block.getArg(arg,varargin{:});
        end

        function stream=getReceiveStream(obj,streamName,varargin)
            narginchk(2,inf);
            stream=obj.blocks(streamName);
            num_channels=getInCount(stream);
            if nargin==2
                cpu="sc16";
                otw="sc16";
                custom_params=varargin;
            elseif nargin>=4
                cpu=varargin{1};
                otw=varargin{2};
                custom_params=varargin(3:end);
            else
                error(message("wt:rfnoc:host:IncorrectStreamParameters"));
            end
            stream.make(obj.graph,num_channels,cpu,otw,custom_params{:});
        end

        function stream=getTransmitStream(obj,streamName,varargin)
            narginchk(2,inf);
            stream=obj.blocks(streamName);
            num_channels=getOutCount(stream);
            if nargin==2
                cpu="sc16";
                otw="sc16";
                custom_params=varargin;
            elseif nargin>=4
                cpu=varargin{1};
                otw=varargin{2};
                custom_params=varargin(3:end);
            else
                error(message("wt:rfnoc:host:IncorrectStreamParameters"));
            end
            stream.make(obj.graph,num_channels,cpu,otw,custom_params{:});
        end
    end
end
