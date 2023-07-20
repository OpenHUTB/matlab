function sat=getIntegersSaturateOnOverflow(blockPath)





    chartH=internal.ml2pir.mlfb.getChartHandle(blockPath);
    sat=chartH.SaturateOnIntegerOverflow;

end
