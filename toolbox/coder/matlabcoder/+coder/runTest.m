function runTest(varargin)








































    narginchk(2,3);
    nargoutchk(0,0);
    try
        isMexInEntryPtPath=false;
        isEntryPtCompiled=true;
        tbExecCfg=coder.internal.TestBenchExecConfig(isMexInEntryPtPath,isEntryPtCompiled);
    catch ME
        ME.throwAsCaller();
    end
    coder.internal.ddux.logger.logCoderEventData("coderRuntestCli");
    coder.internal.runTest(tbExecCfg,varargin{:})
end
