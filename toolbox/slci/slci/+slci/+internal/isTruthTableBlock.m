function out=isTruthTableBlock(blkObj)



    hdl=blkObj.Handle;
    out=sfprivate('is_truth_table_chart_block',hdl);
end
