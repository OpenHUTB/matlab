function out=isEMLBlock(blkObj)



    hdl=blkObj.Handle;
    out=sfprivate('is_eml_chart_block',hdl);
end
