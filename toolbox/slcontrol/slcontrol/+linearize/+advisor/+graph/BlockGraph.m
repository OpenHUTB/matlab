classdef BlockGraph<linearize.advisor.graph.AbstractLinearizationGraph
    methods
        function this=BlockGraph(cg)



            import linearize.advisor.graph.*
            assert(isa(cg,'linearize.advisor.graph.ChannelGraph'),'BlockGraph can only be created from a ChannelGraph');
            this=this@linearize.advisor.graph.AbstractLinearizationGraph(cg.Model,cg.MdlHierInfo);


            types=[cg.Nodes.Type]';
            uioidx=types==NodeTypeEnum.INLINIO;
            yioidx=types==NodeTypeEnum.OUTLINIO;
            ioidx=uioidx|yioidx;
            blkhandles=[cg.Nodes.JacobianBlockHandle]';

            fblkidx=find(~ioidx);
            fiosidx=find(ioidx);

            blkhandles_blk=blkhandles(fblkidx);

            [~,ublkhandles_blk_idx]=unique(blkhandles_blk);
            fblkidx=fblkidx(ublkhandles_blk_idx);

            idx=[fblkidx;fiosidx];

            nodes=cg.Nodes(idx);
            blkhandles_=[nodes.JacobianBlockHandle]';
            types_=[nodes.Type]';
            uioidx_=types_==NodeTypeEnum.INLINIO;
            yioidx_=types_==NodeTypeEnum.OUTLINIO;
            ioidx_=uioidx_|yioidx_;
            n=numel(idx);
            adj=false(n);

            for i=1:n

                node=nodes(i);
                blkh=node.JacobianBlockHandle;

                if ioidx_(i)
                    nodeidx=(blkhandles==blkh)&ioidx;
                else
                    nodeidx=(blkhandles==blkh)&~ioidx;
                    nodes(i).Type=NodeTypeEnum.BLOCK;
                    nodes(i).CompiledPortHandle=[];
                    nodes(i).Name='';
                    nodes(i).Channel=[];
                    nodes(i).Port=[];
                end

                pred=predecessors(cg,nodeidx);
                succ=successors(cg,nodeidx);

                prediosidx=pred&uioidx;
                succiosidx=succ&yioidx;
                predblkidx=pred&~ioidx;
                succblkidx=succ&~ioidx;

                prediosnodes=cg.Nodes(prediosidx);
                succiosnodes=cg.Nodes(succiosidx);
                predblknodes=cg.Nodes(predblkidx);
                succblknodes=cg.Nodes(succblkidx);

                prediosh=[prediosnodes.JacobianBlockHandle];
                succiosh=[succiosnodes.JacobianBlockHandle];
                predblkh=[predblknodes.JacobianBlockHandle];
                succblkh=[succblknodes.JacobianBlockHandle];





                prediosidx_=ismember(blkhandles_,prediosh)&uioidx_;
                succiosidx_=ismember(blkhandles_,succiosh)&yioidx_;
                predblkidx_=ismember(blkhandles_,predblkh)&~ioidx_;
                succblkidx_=ismember(blkhandles_,succblkh)&~ioidx_;

                pidx=prediosidx_|predblkidx_;
                sidx=succiosidx_|succblkidx_;

                adj(i,pidx)=true;
                adj(sidx,i)=true;

            end

            adj(logical(eye(n)))=false;
            this.Adj=adj;
            this.Nodes=nodes;

        end
        function blks=getBlocksOnPath(this)
            sIdx=this.Nodes.getInIOIdx;
            tIdx=this.Nodes.getOutIOIdx;
            rIdx=getReachableNodes(this);

            rIdx(sIdx|tIdx)=0;
            blks=[this.Nodes(rIdx).JacobianBlockHandle]';
        end
        function val=isBlockArticulating(this,blkh)
            import linearize.advisor.graph.*
            types=[this.Nodes.Type]';
            blkhandles=[this.Nodes.JacobianBlockHandle]';


            blkhandles(types~=NodeTypeEnum.BLOCK)=0;
            [nodeIdx,inblkh]=ismember(blkhandles,blkh);
            val=isNodeArticulating(this,nodeIdx);



            inblkh(inblkh==0)=[];
            val(inblkh)=val;
        end
    end
end


