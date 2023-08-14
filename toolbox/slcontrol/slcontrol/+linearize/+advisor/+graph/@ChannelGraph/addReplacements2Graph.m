function this=addReplacements2Graph(this,rmdata)

    nreps=numel(rmdata);
    for i=1:nreps
        r=rmdata(i).BlockReplacements;
        rmd=rmdata(i).BlockRemovalData;
        yinfo=rmdata(i).OutputInfo;
        uinfo=rmdata(i).InputInfo;
        this=LocalAddRep2Graph(this,r,rmd,yinfo,uinfo);
    end

    function this=LocalAddRep2Graph(this,rep,rmd,yinfo,uinfo)

        blkh=rmd.Block;
        rsys=rep.Value;
        if any(rmd.OutputHandles==blkh)||any(rmd.InputHandles==blkh)
            this=LocalAddBlock2GraphNonVirtual(this,blkh,rsys);
        else
            this=LocalAddBlock2GraphVirtual(this,blkh,rsys,rmd,yinfo,uinfo);
        end

        function this=LocalAddBlock2GraphVirtual(this,blkh,rsys,rmd,yinfo,uinfo)

            import linearize.advisor.graph.*
            sys=ss(rsys);
            nx=order(sys);
            [ny,nu]=size(sys);
            repnodes=linearize.advisor.graph.LinNode.empty(nx+ny+nu,0);

            for i=1:nx
                repnodes(i)=linearize.advisor.graph.LinNode(NodeTypeEnum.STATE);
                repnodes(i).JacobianBlockHandle=blkh;
                repnodes(i).BlockPath=getfullname(blkh);
                repnodes(i).Name='';
                repnodes(i).Channel=i;
                repnodes(i).Port=0;
                repnodes(i).IsSynth=0;
                repnodes(i).ParentMdl=bdroot(blkh);
                repnodes(i).CompiledPortHandle=0;
                [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                linearize.advisor.utils.getBlockPathInfo(this.Model,blkh,this.MdlHierInfo);
                repnodes(i).IsMultiInstanced=isMultiInstanced;
                repnodes(i).GraphicalBlockPath=gBlkPath;
                repnodes(i).GraphicalParentBlockHandles=gParBlkPaths;
            end
            for i=1:ny
                yIdx=nx+i;
                repnodes(yIdx)=linearize.advisor.graph.LinNode(NodeTypeEnum.OUTCHANNEL);
                repnodes(yIdx).JacobianBlockHandle=blkh;
                repnodes(yIdx).BlockPath=getfullname(blkh);
                repnodes(yIdx).Name='';
                repnodes(yIdx).Channel=i;
                repnodes(yIdx).Port=yinfo(i,3);
                repnodes(yIdx).IsSynth=0;
                repnodes(yIdx).ParentMdl=bdroot(blkh);
                repnodes(yIdx).CompiledPortHandle=LocalGetPortHandleFromNode(repnodes(yIdx));
                [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                linearize.advisor.utils.getBlockPathInfo(this.Model,blkh,this.MdlHierInfo);
                repnodes(yIdx).IsMultiInstanced=isMultiInstanced;
                repnodes(yIdx).GraphicalBlockPath=gBlkPath;
                repnodes(yIdx).GraphicalParentBlockHandles=gParBlkPaths;
            end
            for i=1:nu
                uIdx=nx+ny+i;
                repnodes(uIdx)=linearize.advisor.graph.LinNode(NodeTypeEnum.INCHANNEL);
                repnodes(uIdx).JacobianBlockHandle=blkh;
                repnodes(uIdx).BlockPath=getfullname(blkh);
                repnodes(uIdx).Name='';
                repnodes(uIdx).Channel=i;
                repnodes(uIdx).Port=uinfo(i,3);
                repnodes(uIdx).IsSynth=0;
                repnodes(uIdx).ParentMdl=bdroot(blkh);
                repnodes(uIdx).CompiledPortHandle=LocalGetPortHandleFromNode(repnodes(uIdx));
                [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                linearize.advisor.utils.getBlockPathInfo(this.Model,blkh,this.MdlHierInfo);
                repnodes(uIdx).IsMultiInstanced=isMultiInstanced;
                repnodes(uIdx).GraphicalBlockPath=gBlkPath;
                repnodes(uIdx).GraphicalParentBlockHandles=gParBlkPaths;
            end
            A=logical(sys.a);
            B=logical(sys.b);
            C=logical(sys.c);
            D=logical(sys.d);
            mdlAdj=this.Adj;
            blocks=[this.Nodes.JacobianBlockHandle]';
            types=[this.Nodes.Type]';

            uchnls=types==NodeTypeEnum.INCHANNEL;
            ychnls=types==NodeTypeEnum.OUTCHANNEL;


            uIdx=ismember(blocks,rmd.OutputHandles)&uchnls;
            yIdx=ismember(blocks,rmd.InputHandles)&ychnls;


            mdlAdj(:,yIdx)=0;














            n=size(mdlAdj,1);
            N=n+nx+ny+nu;

            uIdx=find(uIdx);
            yIdx=find(yIdx);

            xIdxNew=n+1:n+nx;
            yIdxNew=n+nx+1:n+nx+ny;
            uIdxNew=n+nx+ny+1:n+nx+ny+nu;

            newAdj=false(N);
            newAdj(1:n,1:n)=mdlAdj;

            assert(numel(uIdx)==numel(yIdxNew),'invalid indexing for replacements');
            assert(numel(yIdx)==numel(uIdxNew),'invalid indexing for replacements');
            newAdj(uIdx,yIdxNew)=eye(ny);
            newAdj(uIdxNew,yIdx)=eye(nu);

            newAdj(xIdxNew,xIdxNew)=A;
            newAdj(xIdxNew,uIdxNew)=B;
            newAdj(yIdxNew,xIdxNew)=C;
            newAdj(yIdxNew,uIdxNew)=D;

            this.Nodes=[this.Nodes,repnodes];
            this.Adj=newAdj;

            function this=LocalAddBlock2GraphNonVirtual(this,blkh,sys)

                import linearize.advisor.graph.*



                types=[this.Nodes.Type]';
                stateIdx=ismember(types,NodeTypeEnum.STATE);
                blocks=[this.Nodes.JacobianBlockHandle]';
                blkIdx=ismember(blocks,blkh);
                nodes2rm=blkIdx&stateIdx;
                this=rmNodes(this,nodes2rm);
                blkIdx(nodes2rm)=[];

                sys=ss(sys);
                nx=order(sys);

                statenodes=linearize.advisor.graph.LinNode.empty(nx,0);


                for i=1:nx
                    statenodes(i)=linearize.advisor.graph.LinNode(NodeTypeEnum.STATE);
                    statenodes(i).JacobianBlockHandle=blkh;
                    statenodes(i).BlockPath=getfullname(blkh);
                    statenodes(i).Name='';
                    statenodes(i).Channel=i;
                    statenodes(i).Port=0;
                    statenodes(i).IsSynth=0;
                    statenodes(i).ParentMdl=bdroot(blkh);
                    statenodes(i).CompiledPortHandle=0;

                    [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                    linearize.advisor.utils.getBlockPathInfo(this.Model,blkh,this.MdlHierInfo);
                    statenodes(i).IsMultiInstanced=isMultiInstanced;
                    statenodes(i).GraphicalBlockPath=gBlkPath;
                    statenodes(i).GraphicalParentBlockHandles=gParBlkPaths;
                end


                A=logical(double(sys.a));
                B=logical(double(sys.b));
                C=logical(double(sys.c));
                D=logical(double(sys.d));

                mdlAdj=this.Adj;
                types=[this.Nodes.Type]';


                inchnlIdx=ismember(types,NodeTypeEnum.INCHANNEL);
                uIdx=inchnlIdx&blkIdx;

                mdlAdj(:,uIdx)=0;


                outchnlIdx=ismember(types,NodeTypeEnum.OUTCHANNEL);
                yIdx=outchnlIdx&blkIdx;

                mdlAdj(yIdx,:)=0;












                n=size(mdlAdj,1);
                N=n+nx;
                xIdx=n+1:N;

                uIdx=find(uIdx);
                yIdx=find(yIdx);

                newAdj=zeros(N);

                newAdj(1:n,1:n)=mdlAdj;

                newAdj(xIdx,xIdx)=A;
                newAdj(xIdx,uIdx)=B;
                newAdj(yIdx,xIdx)=C;
                newAdj(yIdx,uIdx)=D;

                this.Nodes=[this.Nodes,statenodes];
                this.Adj=newAdj;

                function ph=LocalGetPortHandleFromNode(node)
                    ph=getPH(node);