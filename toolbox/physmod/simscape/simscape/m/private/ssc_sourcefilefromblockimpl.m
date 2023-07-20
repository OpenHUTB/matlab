function sourceFile=ssc_sourcefilefromblockimpl(blockObject)




    blockHandle=pmsl_getdoublehandle(blockObject);
    functionStringFromBlock=@simscape.compiler.sli.internal.functionstringfromblock;
    functionString=functionStringFromBlock(blockHandle);
    sourceFile=which(functionString);

end
