function splitterPos=calc_splitter_pos(axesExtent,figBuffer)




    splitterPos=[axesExtent(1)+axesExtent(3),axesExtent(2),0,axesExtent(4)]+...
    [0.375,0,0.25,0]*figBuffer;
