function prepareForComparison(leftFile,rightFile)



    slreq.internal.comparisons.checkoutSLREQLicense();


    slreq.internal.comparisons.unpackOPCImages(leftFile);
    slreq.internal.comparisons.unpackOPCImages(rightFile);
end