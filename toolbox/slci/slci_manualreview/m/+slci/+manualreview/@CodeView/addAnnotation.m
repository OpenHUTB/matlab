


function addAnnotation(obj,anno)


    lines=anno.lines;
    assert(numel(lines)==2);
    start_line_no=lines(1);
    end_line_no=lines(2);


    mr_manager=slci.manualreview.Manager.getInstance;
    mr=mr_manager.getManualReview(obj.fStudio);
    mr.addData(anno.file,start_line_no,end_line_no);

end