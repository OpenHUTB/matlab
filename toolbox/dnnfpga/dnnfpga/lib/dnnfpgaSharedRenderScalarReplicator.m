function dnnfpgaSharedRenderScalarReplicator(gcb,width)



    if(isempty(width))
        return;
    end

    muxPath=[gcb,'/Mux'];
    try
        lh=get_param(muxPath,'LineHandles');
        delete_line(lh.Inport);
    catch me %#ok<NASGU>
    end
    try
        redrawScalarReplicator(gcb,width);
    catch me
    end
end

function redrawScalarReplicator(curGcb,width)
    set_param([curGcb,'/Mux'],'Inputs',num2str(width));
    for i=1:width
        add_line(curGcb,'In/1',['Mux/',num2str(i)],'autorouting','on');
    end
end

