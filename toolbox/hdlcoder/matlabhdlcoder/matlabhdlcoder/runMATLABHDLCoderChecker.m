function runMATLABHDLCoderChecker(topFcnName,cgDirName,launchReport,dbgLevel,errorCheckReport,suppress_report,do_rethrow)



    if(nargin<6)
        suppress_report=false;
    end
    if(nargin<7)
        do_rethrow=true;
    end

    hs=emlhdlcoder.EmlChecker.HDLScreener(topFcnName,cgDirName,launchReport,dbgLevel,errorCheckReport);
    try
        hs.doIt(suppress_report);
    catch mEx
        [~,hdlCfg]=hdlismatlabmode();
        if(hdlCfg.DebugLevel>0)


            disp(mEx);
            arrayfun(@disp,mEx.stack);
        end
        if(do_rethrow)
            rethrow(mEx)
        end
    end
