classdef ChannelGraph<linearize.advisor.graph.AbstractLinearizationGraph




    properties(Access=private)
CompiledRemovalData
CompiledNodes
    end
    properties(SetAccess=private)
    end
    methods
        phEdges=getPortConnectivity(this)
        this=processForSimscapeBlocks(this)

        function this=ChannelGraph(J,mdl,mdlHierInfo)
            this@linearize.advisor.graph.AbstractLinearizationGraph(mdl,mdlHierInfo);
            [adj,chnlnodes]=linearize.advisor.graph.getCompiledAdj(...
            J,mdl,mdlHierInfo);
            this.Adj=adj;
            this.Nodes=chnlnodes;
            this.CompiledNodes=chnlnodes;
            if isfield(J.Mi,'Replacements')
                reps=J.Mi.Replacements;
            else
                reps=[];
            end
            this.CompiledRemovalData=...
            linearize.advisor.graph.genCompiledRemovalData(...
            reps,J.Mi.BlockRemovalData);
            this=process(this);
        end
        function this=updateIOs(this,J,iostruct)
            [this.Adj,this.Nodes]=linearize.advisor.graph.getUpdatedAdj(...
            J,this.Model,this.MdlHierInfo,this.CompiledNodes,iostruct);
            this=process(this);
        end
        function idx=isChannelInGraph(this,blkh,chnl,type)
            handles=[this.Nodes.JacobianBlockHandle]';
            types=[this.Nodes.Type]';
            chnls=[this.Nodes.Channel]';
            idx=ismember(handles,blkh)&ismember(types,type)&ismember(chnls,chnl);
        end
        function idx=isInChannelInGraph(this,blkh,chnl)
            import linearize.advisor.graph.*
            idx=isChannelInGraph(this,blkh,chnl,NodeTypeEnum.INCHANNEL);
        end
        function idx=isOutChannelInGraph(this,blkh,chnl)
            import linearize.advisor.graph.*
            idx=isChannelInGraph(this,blkh,chnl,NodeTypeEnum.OUTCHANNEL);
        end
        function info=getSrcInfo(this,blkh)


            import linearize.advisor.graph.*
            rmap=getReachableMap(this);
            handles=[this.Nodes.JacobianBlockHandle]';
            types=[this.Nodes.Type]';
            uchnls=(handles==blkh)&(types==NodeTypeEnum.INCHANNEL);
            xidx=find(types==NodeTypeEnum.STATE);
            yidx=find(types==NodeTypeEnum.OUTCHANNEL);

            rx=any(rmap(uchnls,xidx),1);
            ru=any(rmap(uchnls,yidx),1);

            rx=xidx(rx);
            ru=yidx(ru);

            info.BlockStateNodes=this.Nodes((handles==blkh)&...
            (types==NodeTypeEnum.STATE));
            info.SrcStateNodes=this.Nodes(rx);
            info.SrcOutportNodes=this.Nodes(ru);
            info.PredNodes=this.Nodes(predecessors(this,uchnls));
        end
        function val=isBlockArticulatingByChannel(this,blkh)

























            import linearize.advisor.graph.*


            dg=matlab.internal.graph.MLDigraph(this.Adj');
            cp=weakConnectedComponents(dg)';
            val=false;
            if all(cp==1)
                return
            end
            handles=[this.Nodes.JacobianBlockHandle]';
            types=[this.Nodes.Type]';
            uchnls=(handles==blkh)&(types==NodeTypeEnum.INCHANNEL);
            ychnls=(handles==blkh)&(types==NodeTypeEnum.OUTCHANNEL);




            r=getIOReachableMap(this,uchnls,ychnls);
            if all(any(r))
                return;
            end

            ubins=unique(cp(uchnls));ybins=unique(cp(ychnls));

            n=numel(ubins);
            invalidubins=false(n,1);
            for i=1:n
                ubin=ubins(i);
                hasU=any((cp==ubin)&(types==NodeTypeEnum.INLINIO));
                invalidubins(i)=~hasU;
            end
            ubins(invalidubins)=[];

            n=numel(ybins);
            invalidybins=false(n,1);
            for i=1:n
                ybin=ybins(i);
                hasY=any((cp==ybin)&(types==NodeTypeEnum.OUTLINIO));
                invalidybins(i)=~hasY;
            end
            ybins(invalidybins)=[];

            if~(isempty(ubins)&&isempty(ybins))

                diffbins=setxor(ubins,ybins);
                if~isempty(diffbins)
                    val=true;
                end
            end
        end
        function[blks,bidx]=findPathBreakingSubsystems(this)




            import linearize.advisor.graph.*

            nodes=this.Nodes;
            types=[nodes.Type]';
            blks={};
            bidx=[];
            blocks={nodes.GraphicalBlockPath}';
            if isempty(this.CompiledRemovalData)
                repblocks={};
            else
                rd=this.CompiledRemovalData;
                br=[rd.BlockReplacements];
                repblocks={br.Name}';
            end

            n=numel(blocks);
            btypes=cell(n,1);
            for i=1:n
                try
                    btypes{i}=get_param(blocks{i},'blocktype');
                catch
                    btypes{i}='';
                end
            end
            ssidx=find(strcmp(btypes,'SubSystem')&...
            ~ismember(blocks,repblocks)&...
            types==NodeTypeEnum.INCHANNEL);
            for i=ssidx(:)'


                succ=successors(this,i);
                blk=blocks{i};
                if~any(succ)&&~ismember(blk,blks)
                    blks{end+1,1}=blk;%#ok<AGROW>
                    bidx(end+1,1)=i;%#ok<AGROW>
                end
            end
        end
    end
    methods(Access=private)
        this=addReplacements2Graph(this,rmdata)
        this=rmSynthNodes(this)

        function this=process(this)



            this=addReplacements2Graph(this,this.CompiledRemovalData);
            this=rmSynthNodes(this);
            if hasModelRefs(this)
                this=addMdlRefBoundaryNodes(this);
            end
            this=addActionSubsystemBoundaryNodes(this);
        end
        function this=addMdlRefBoundaryNodes(this)



            import linearize.advisor.graph.*
            types=[this.Nodes.Type]';
            innodeidx=find(ismember(types,...
            [NodeTypeEnum.INCHANNEL,NodeTypeEnum.OUTLINIO]));
            for idx=innodeidx(:)'
                innode=this.Nodes(idx);
                if~innode.IsMultiInstanced
                    [srcph,srcblk]=getModelSrc(innode);
                    if~isempty(srcblk)&&...
                        strcmp(get_param(srcblk,'BlockType'),'ModelReference')&&...
                        strcmp(get_param(srcblk,'SimulationMode'),'Normal')&&...
                        strcmp(get_param(srcblk,'Commented'),'off')

                        refmdl=get_param(srcblk,'ModelName');
                        portnum=get_param(srcph,'PortNumber');
                        outportblk=find_system(refmdl,'SearchDepth',1,...
                        'BlockType','Outport','Port',num2str(portnum));
                        outportblk=outportblk{1};
                        outportblkh=get_param(outportblk,'Handle');
                        ph=get_param(outportblk,'PortHandles');
                        ipph=ph.Inport(1);
                        chnl=innode.Channel;

                        newnode1=LinNode(NodeTypeEnum.INCHANNEL);
                        newnode1.JacobianBlockHandle=outportblkh;
                        newnode1.ParentMdl=get_param(refmdl,'Handle');
                        newnode1.BlockPath=outportblk;
                        newnode1.Name='';
                        newnode1.Channel=chnl;
                        newnode1.Port=1;
                        newnode1.CompiledPortHandle=ipph;
                        newnode1.IsSynth=false;
                        newnode1.OriginalBlock=[];

                        [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                        linearize.advisor.utils.getBlockPathInfo(...
                        this.Model,outportblkh,this.MdlHierInfo);
                        newnode1.IsMultiInstanced=isMultiInstanced;
                        newnode1.GraphicalBlockPath=gBlkPath;
                        newnode1.GraphicalParentBlockHandles=gParBlkPaths;

                        srcblkh=get_param(srcblk,'Handle');
                        newnode2=LinNode(NodeTypeEnum.OUTCHANNEL);
                        newnode2.JacobianBlockHandle=srcblkh;
                        newnode2.ParentMdl=innode.ParentMdl;
                        newnode2.BlockPath=getfullname(srcblk);
                        newnode2.Name='';
                        newnode2.Channel=chnl;
                        newnode2.Port=portnum;
                        newnode2.CompiledPortHandle=srcph;
                        newnode2.IsSynth=false;
                        newnode2.OriginalBlock=[];

                        [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                        linearize.advisor.utils.getBlockPathInfo(...
                        this.Model,srcblkh,this.MdlHierInfo);
                        newnode2.IsMultiInstanced=isMultiInstanced;
                        newnode2.GraphicalBlockPath=gBlkPath;
                        newnode2.GraphicalParentBlockHandles=gParBlkPaths;



                        pred=predecessors(this,idx);
                        this.Adj(idx,pred)=false;


                        this=addNodes(this,newnode1);
                        newnode1idx=numel(this.Nodes);
                        this.Adj(newnode1idx,pred)=true;


                        this=addNodes(this,newnode2);
                        newnode2idx=numel(this.Nodes);
                        this.Adj(newnode2idx,newnode1idx)=true;


                        this.Adj(idx,newnode2idx)=true;
                    end
                end
            end
        end
        function this=addActionSubsystemBoundaryNodes(this)









            import linearize.advisor.graph.*

            nodes=this.Nodes;
            types=[nodes.Type]';


            [~,ssidx]=findPathBreakingSubsystems(this);
            for i=ssidx(:)'
                blocks={nodes.GraphicalBlockPath}';
                ssblock=blocks{i};
                ssnode=nodes(i);



                cblks=find_system(ssblock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on');
                cblks(1)=[];


                cidx=ismember(blocks,cblks);
                cyidx=cidx&types==NodeTypeEnum.OUTCHANNEL;





                succ=successors(this,cyidx)&~cidx;

                ops=getBlockPorts(ssblock,'outport');



                visitedsrc=[];
                for op=ops(:)'

                    line=get_param(op,'line');
                    dports=get_param(line,'NonVirtualDstPorts');
                    dblks=get_param(dports,'parent');




                    didx=find(ismember(blocks,dblks)&succ);
                    for j=didx(:)'



                        k=find(predecessors(this,j));
                        if~ismember(k,visitedsrc)
                            visitedsrc(end+1)=k;%#ok<AGROW>

                            newnode=ssnode;
                            newnode.Type=NodeTypeEnum.OUTCHANNEL;
                            newnode.Channel=numel(visitedsrc);
                            newnode.CompiledPortHandle=op;
                            newnode.Port=get_param(op,'portnumber');

                            this=addNodes(this,newnode);

                            nodes=this.Nodes;
                            types=[nodes.Type]';
                        end

                        this.Adj(j,end)=true;
                    end
                end


                this.Adj(succ,cyidx)=false;
            end
        end
    end
end
