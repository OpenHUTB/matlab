function dnnfpgaConvlibRenderConvXDb(curGcb,OpSize,ImgSizeLimit,FifoLength,Width)



    if(isempty(OpSize))
        return;
    end

    if(~isequal(size(OpSize),size(ImgSizeLimit)))
        return;
    end

    convPath=[curGcb,'/Conv'];
    pos=get_param(convPath,'Position');
    try
        lh=get_param(convPath,'LineHandles');
        delete_block(convPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        dnnfpgaConvlibRedrawConvXDb(convPath,pos,OpSize,ImgSizeLimit,FifoLength,Width);
        add_line(curGcb,'pixelIn/1','Conv/1','autorouting','on');
        add_line(curGcb,'resultIn/1','Conv/2','autorouting','on');
        add_line(curGcb,'coefDBOff/1','Conv/3','autorouting','on');
        add_line(curGcb,'coefLoadDBOff/1','Conv/4','autorouting','on');
        add_line(curGcb,'modeInDBOff/1','Conv/5','autorouting','on');
        add_line(curGcb,'fifoLength/1','Conv/6','autorouting','on');
        add_line(curGcb,'Conv/1','pixelTerm/1','autorouting','on');
        add_line(curGcb,'Conv/2','resultOut/1','autorouting','on');
        add_line(curGcb,'Conv/3','coefTerm/1','autorouting','on');
        add_line(curGcb,'Conv/4','coefLoadTerm/1','autorouting','on');
        add_line(curGcb,'Conv/5','modeTerm/1','autorouting','on');
    catch me
    end
end
