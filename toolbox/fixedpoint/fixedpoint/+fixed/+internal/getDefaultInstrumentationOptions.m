function opts=getDefaultInstrumentationOptions()



    opts.defaultDT=numerictype('double');
    opts.doHistogramLogging=false;
    opts.doLog2Display=false;
    opts.doOptimizeWholeNumbers=false;
    opts.doPrintable=false;
    opts.doProposeFL=false;
    opts.doProposeForTemps=false;
    opts.doProposeWL=false;
    opts.doShowCode=true;
    opts.doPrototypeTable=false;
    opts.doShowAttachedFimath=false;
    opts.prototypeFimath=[];
    opts.percentSafetyMargin=0;
end
