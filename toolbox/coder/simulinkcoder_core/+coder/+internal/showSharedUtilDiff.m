function showSharedUtilDiff(modelStructString,folderStructString,artifact1,artifact2)






    cleanupString='';
    coder.internal.invokeComparison(modelStructString,folderStructString,artifact1,artifact2,cleanupString,cleanupString);

end
