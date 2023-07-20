function dnnfpgaSharedRenderScalarReplicatorByElements(gcb,inWidth,width)



    if(isempty(inWidth))
        return;
    end

    if(isempty(width))
        return;
    end

    muxPath=[gcb,'/Mux'];
    demuxPath=[gcb,'/Demux'];
    try
        lh=get_param(muxPath,'LineHandles');
        delete_line(lh.Inport);
        lh=get_param(demuxPath,'LineHandles');
        delete_line(lh.Outport);


        srs=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','ReferenceBlock','dnnfpgaSharedGenericlib/Scalar Replicator');
        delete_block(srs);
        redrawScalarReplicator(gcb,inWidth,width);
    catch me

        disp(me.message);
    end
end

function redrawScalarReplicator(curGcb,inWidth,width)
    scStartPos=[145,27,220,43];
    scSpacer=[0,30,0,30];
    set_param([curGcb,'/Demux'],'Outputs',num2str(inWidth));
    set_param([curGcb,'/Mux'],'Inputs',num2str(inWidth));
    for i=1:inWidth
        blkName=['Scalar Replicator',num2str(i)];
        blkPos=scStartPos+(i-1)*scSpacer;
        add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/',blkName],'MakeNameUnique','on','Position',blkPos,'width',num2str(width));
        add_line(curGcb,['Demux/',num2str(i)],[blkName,'/1'],'autorouting','on');
        add_line(curGcb,[blkName,'/1'],['Mux/',num2str(i)],'autorouting','on');
    end
end

