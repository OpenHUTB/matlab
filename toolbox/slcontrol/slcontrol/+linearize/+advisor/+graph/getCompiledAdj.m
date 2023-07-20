function[adj,chnlnodes]=getCompiledAdj(J,mdl,mdlHierInfo)


    import linearize.advisor.graph.*
    [adj,nx,ny,nu,nY,nU]=linearize.advisor.utils.J2Adj(J);



    map=BlockPathInfoStorage(mdl,mdlHierInfo);


    cn=cell(1,nx+nu+ny);
    stateCt=1;

    for xIdx=1:nx
        bh=LocalGetStateBlockHandle(xIdx,J);

        s=getBlockPathInfo(map,bh);

        ln=LinNode(NodeTypeEnum.STATE);
        ln.JacobianBlockHandle=bh;
        ln.ParentMdl=s.ParentMdl;
        ln.BlockPath=s.fullname;
        ln.Name=J.stateName{xIdx};

        if xIdx>1&&(bh==cn{xIdx-1}.JacobianBlockHandle)
            stateCt=stateCt+1;
        else
            stateCt=1;
        end
        ln.Channel=stateCt;
        ln.Port=0;
        ln.CompiledPortHandle=0;

        ln.IsSynth=s.isSynth;
        ln.OriginalBlock=s.origBlk;

        ln.IsMultiInstanced=s.isMultiInstanced;
        ln.GraphicalBlockPath=s.gBlkPath;
        ln.GraphicalParentBlockHandles=s.gParBlkPaths;

        cn{xIdx}=ln;
    end


    for i=1:ny
        yIdx=i+nx;
        bh=J.Mi.OutputInfo(i,1);

        s=getBlockPathInfo(map,bh);

        ln=LinNode(NodeTypeEnum.OUTCHANNEL);
        ln.JacobianBlockHandle=bh;
        ln.ParentMdl=s.ParentMdl;
        ln.BlockPath=s.fullname;
        ln.Name='';
        ln.Channel=J.Mi.OutputInfo(i,2);
        ln.Port=J.Mi.OutputInfo(i,3);
        ln.CompiledPortHandle=getPH(ln);

        ln.IsSynth=s.isSynth;
        ln.OriginalBlock=s.origBlk;

        ln.IsMultiInstanced=s.isMultiInstanced;
        ln.GraphicalBlockPath=s.gBlkPath;
        ln.GraphicalParentBlockHandles=s.gParBlkPaths;

        cn{yIdx}=ln;
    end


    for i=1:nu
        uIdx=i+nx+ny;
        bh=J.Mi.InputInfo(i,1);

        s=getBlockPathInfo(map,bh);

        ln=LinNode(NodeTypeEnum.INCHANNEL);
        ln.JacobianBlockHandle=bh;
        ln.ParentMdl=s.ParentMdl;
        ln.BlockPath=s.fullname;
        ln.Name='';
        ln.Channel=J.Mi.InputInfo(i,2);
        ln.Port=J.Mi.InputInfo(i,3);
        ln.CompiledPortHandle=getPH(ln);

        ln.IsSynth=s.isSynth;
        ln.OriginalBlock=s.origBlk;

        ln.IsMultiInstanced=s.isMultiInstanced;
        ln.GraphicalBlockPath=s.gBlkPath;
        ln.GraphicalParentBlockHandles=s.gParBlkPaths;

        cn{uIdx}=ln;
    end
    chnlnodes=horzcat(cn{:});

    chnlnodes=linearize.advisor.graph.processIONodes(...
    chnlnodes,J,nx,ny,nu,nY,nU,mdl,mdlHierInfo,map);

    function h=LocalGetStateBlockHandle(xidx,J)

        d=diff(J.Mi.StateIdx);
        idx=find(d);
        d=d(idx);
        q=zeros(sum(d),1);
        ct=0;
        for i=1:numel(d)
            q(ct+1:ct+d(i))=idx(i);
            ct=ct+d(i);
        end
        h=J.Mi.BlockHandles(q(xidx));

