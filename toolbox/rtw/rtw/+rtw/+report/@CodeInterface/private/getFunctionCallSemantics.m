

function out=getFunctionCallSemantics(fcnInfo)
    timing=fcnInfo.Timing;
    switch timing.TimingMode
    case 'ONESHOT'
        out=DAStudio.message('RTW:codeInfo:reportCallSemanticsOnce');
    case 'PERIODIC'
        period=timing.SamplePeriod;
        if period==1
            out=DAStudio.message('RTW:codeInfo:reportCallSemanticsPerSecond');
        else
            out=DAStudio.message('RTW:codeInfo:reportCallSemanticsNSeconds',num2str(timing.SamplePeriod));
        end
    case 'INHERITED'
        out=DAStudio.message('RTW:codeInfo:reportCallSemanticsInherited');
    otherwise
        out=DAStudio.message('RTW:codeInfo:reportCallSemanticsUnknown');
    end

end
