function chnlnodes=processIONodes(chnlnodes,J,nx,ny,nu,nY,nU,mdl,mdlHierInfo,map)

    import linearize.advisor.graph.*

    compiledIONodes=chnlnodes(nx+ny+nu+1:end);

    chnlnodes=chnlnodes(1:nx+ny+nu);





    cn=cell(1,nY+nU);
    ioCt=1;

    for i=1:nY
        [ph,bh,name,s]=...
        LocalGetBlockInfo(J.Mi.OutputPorts(i),chnlnodes,compiledIONodes,map);

        ln=LinNode(NodeTypeEnum.OUTLINIO);
        ln.CompiledPortHandle=ph;
        ln.JacobianBlockHandle=bh;
        ln.ParentMdl=s.ParentMdl;
        ln.BlockPath=J.Mi.OutputName{i};
        ln.Name=name;
        if i>1&&((bh==cn{i-1}.JacobianBlockHandle)&&...
            strcmp(ln.Name,cn{i-1}.Name))
            ioCt=ioCt+1;
        else
            ioCt=1;
        end
        ln.Channel=ioCt;
        if isempty(J.Mi.OutputPortNumbers)
            ln.Port=1;
        else
            ln.Port=J.Mi.OutputPortNumbers(i);
        end
        ln.IsSynth=0;
        ln.OriginalBlock=[];

        ln.IsMultiInstanced=s.isMultiInstanced;
        ln.GraphicalBlockPath=s.gBlkPath;
        ln.GraphicalParentBlockHandles=s.gParBlkPaths;

        cn{i}=ln;
    end

    ioCt=1;

    for i=1:nU
        [ph,bh,name,s]=...
        LocalGetBlockInfo(J.Mi.InputPorts(i),chnlnodes,compiledIONodes,map);

        ln=LinNode(NodeTypeEnum.INLINIO);
        ln.CompiledPortHandle=ph;
        ln.JacobianBlockHandle=bh;
        ln.ParentMdl=s.ParentMdl;
        ln.BlockPath=J.Mi.InputName{i};
        ln.Name=name;
        if i>1&&((bh==cn{i-1}.JacobianBlockHandle)&&...
            strcmp(ln.Name,cn{i-1}.Name))
            ioCt=ioCt+1;
        else
            ioCt=1;
        end
        ln.Channel=ioCt;
        if isempty(J.Mi.InputPortNumbers)
            ln.Port=1;
        else
            ln.Port=J.Mi.InputPortNumbers(i);
        end

        ln.IsSynth=0;
        ln.OriginalBlock=[];

        ln.IsMultiInstanced=s.isMultiInstanced;
        ln.GraphicalBlockPath=s.gBlkPath;
        ln.GraphicalParentBlockHandles=s.gParBlkPaths;

        cn{i+nY}=ln;
    end

    chnlnodes=horzcat(chnlnodes,cn{:});

    function[ph,bh,name,s]=LocalGetBlockInfo(ph,chnlnodes,compiledIONodes,map)
        if isempty(compiledIONodes)

            bh=get_param(get_param(ph,'parent'),'handle');
            name=getfullname(bh);
            s=getBlockPathInfo(map,bh);
        else

            nodes=[chnlnodes(:);compiledIONodes(:)];
            compiledPortHandles=[nodes.CompiledPortHandle]';


            phidx=ismember(compiledPortHandles,ph);

            if any(phidx)
                phidx=find(phidx,1);
                node=nodes(phidx);
                bh=node.JacobianBlockHandle;
                name=node.Name;

                s.fullname=node.BlockPath;
                s.ParentMdl=node.ParentMdl;
                s.gBlkPath=node.GraphicalBlockPath;
                s.isMultiInstanced=node.IsMultiInstanced;
                s.gParBlkPaths=node.GraphicalParentBlockHandles;
                s.isSynth=node.IsSynth;
                s.origBlk=node.OriginalBlock;

            else


                error('Cannot find a matching compiled port handle');
            end
        end