function phEdges=getPortConnectivity(this)


    import linearize.advisor.graph.*

    phEdges=[];
    edges=this.Edges;
    nodes=this.Nodes;
    n=size(edges,1);
    for i=1:n
        edge=edges(i,:);
        headNode=nodes(edge(1));
        tailNode=nodes(edge(2));
        if LocalCheckHeadTailNode(headNode,tailNode)




            headNodes=LocalHandleMultiInstanceNode(this,headNode);
            tailNode=LocalHandleMultiInstanceNode(this,tailNode);
            for hIdx=1:numel(headNodes)
                headNode=headNodes(hIdx);
                if LocalCheckHeadTailNode(headNode,tailNode)
                    phHead=LocalGetPHFromNode(this,headNode);
                    phTail=LocalGetPHFromNode(this,tailNode);

                    if~isempty(phHead)&&~isempty(phTail)
                        phEdges(end+1,1:2)=[phHead,phTail];%#ok<AGROW>

                        headMdl=headNode.ParentMdl;
                        tailMdl=tailNode.ParentMdl;
                        if headMdl~=tailMdl
                            headDepth=numel(headNode.GraphicalParentBlockHandles);
                            tailDepth=numel(tailNode.GraphicalParentBlockHandles);
                            if headDepth>tailDepth


                                phEdges=LocalAddEdgesForPortsAcrossModelBoundaries(phEdges,phHead,phTail);
                            end
                        end
                    end
                end
            end
        end
    end

    phEdges=unique(phEdges,'rows');

    function val=LocalCheckHeadTailNode(headNode,tailNode)



        import linearize.advisor.graph.*
        headjh=LocalGetJacobianHandle(headNode);
        tailjh=LocalGetJacobianHandle(tailNode);
        val=(headjh~=tailjh)&&...
        ~(headNode.Type==NodeTypeEnum.STATE||tailNode.Type==NodeTypeEnum.STATE)&&...
        ~(headNode.IsMultiInstanced&&tailNode.IsMultiInstanced);

        function node=LocalHandleMultiInstanceNode(this,node)


            import linearize.advisor.graph.*
            isMI=node.IsMultiInstanced;
            if isMI

                blkPath=node.GraphicalBlockPath;
                blkh=get_param(blkPath,'handle');
                node.JacobianBlockHandle=blkh;

                parBlkH=node.GraphicalParentBlockHandles(end);

                ph=LocalGetPHFromNode(this,node);

                switch node.Type
                case{NodeTypeEnum.INCHANNEL,NodeTypeEnum.OUTLINIO}

                    portnums=LocalRecursiveFindMdlRefBlkInports([],ph);
                case{NodeTypeEnum.OUTCHANNEL,NodeTypeEnum.INLINIO}



                    portnums=LocalRecursiveFindMdlRefBlkOutports([],ph);
                end


                node.JacobianBlockHandle=parBlkH;
                node.BlockPath=getfullname(parBlkH);
                node.ParentMdl=bdroot(parBlkH);
                node.GraphicalBlockPath=node.BlockPath;
                node.GraphicalParentBlockHandles(end)=[];
                node.IsMultiInstanced=isNodeMemberOfMultiInstancedMdl(this,node);
                for i=1:numel(portnums)
                    node.Port=portnums(i);

                    node=LocalHandleMultiInstanceNode(this,node);
                end
            end

            function inportNums=LocalRecursiveFindMdlRefBlkInports(inportNums,ph)

                line=get_param(ph,'Line');
                srcBlk=get_param(line,'SrcBlockHandle');

                if any(strcmp(get_param(srcBlk,'BlockType'),{'Inport','InportShadow'}))
                    inportNums(end+1,1)=str2double(get_param(srcBlk,'Port'));
                else
                    ph=get_param(srcBlk,'PortHandles');
                    inPortHandles=ph.Inport;
                    for ip=inPortHandles
                        inportNums=LocalRecursiveFindMdlRefBlkInports(inportNums,ip);
                    end
                end

                function outportNums=LocalRecursiveFindMdlRefBlkOutports(outportNums,ph)

                    line=get_param(ph,'Line');
                    dstBlks=get_param(line,'DstBlockHandle');
                    if iscell(dstBlks)
                        dstBlks=cell2mat(dstBlks);
                    end
                    for i=1:numel(dstBlks)
                        dstBlk=dstBlks(i);
                        if strcmp(get_param(dstBlk,'BlockType'),'Outport')
                            outportNums(end+1,1)=str2double(get_param(dstBlk,'Port'));%#ok<AGROW>
                        else
                            ph=get_param(dstBlk,'PortHandles');
                            outPortHandles=ph.Outport;
                            for op=outPortHandles
                                outportNums=LocalRecursiveFindMdlRefBlkOutports(outportNums,op);
                            end
                        end
                    end

                    function edges=LocalAddEdgesForPortsAcrossModelBoundaries(edges,head,tail)


                        tailblk=get_param(tail,'Parent');
                        tailblktype=get_param(tailblk,'BlockType');
                        if strcmp(tailblktype,'ModelReference')
                            outerrefoutport=tail;
                        else
                            outerrefoutport=LocalRecursiveFindUpstreamMdlRefPort([],[],tail);
                            edges(end+1,1:2)=[outerrefoutport,tail];
                        end


                        portnum=get_param(outerrefoutport,'PortNumber');

                        refblk=get_param(outerrefoutport,'Parent');
                        refmdl=get_param(refblk,'ModelName');

                        if~isempty(refmdl)
                            outportblk=find_system(refmdl,'SearchDepth',1,...
                            'BlockType','Outport','Port',num2str(portnum));
                            ph=get_param(outportblk{1},'PortHandles');
                            innerrefoutport=ph.Inport;
                            if~isempty(innerrefoutport)
                                edges(end+1,1:2)=[head,innerrefoutport];
                            end
                        end

                        function[refport,visitedPh]=LocalRecursiveFindUpstreamMdlRefPort(refport,visitedPh,ph)


                            line=get_param(ph,'Line');
                            srcPh=get_param(line,'SrcPortHandle');
                            srcBlk=get_param(line,'SrcBlockHandle');

                            if strcmp(get_param(srcBlk,'BlockType'),'ModelReference')
                                refport(end+1,1)=srcPh;
                            else
                                ph=get_param(srcBlk,'PortHandles');
                                inports=ph.Inport;
                                for ip=inports


                                    if~ismember(ip,visitedPh)
                                        visitedPh=[visitedPh;ip];%#ok<AGROW>
                                        [refport,visitedPh]=...
                                        LocalRecursiveFindUpstreamMdlRefPort(refport,visitedPh,ip);
                                    end
                                end
                            end

                            refport=unique(refport);

                            function[jh,port]=LocalGetJacobianHandle(node)
                                jh=getOriginalJacobianHandle(node);
                                if isempty(node.OriginalBlock)
                                    port=node.Port;
                                else
                                    port=1;
                                end

                                function ph=LocalGetPHFromNode(~,node)
                                    ph=getPH(node);
