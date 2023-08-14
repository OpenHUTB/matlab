function out=util_is_analyzing_for_fixpt_tool




    out=false;
    if exist('slavteng','builtin')==5&&exist('sldvprivate','file')==2
        try
            testComp=Sldv.Token.get.getTestComponent;
            if~isempty(testComp)
                out=testComp.analysisInfo.fixptRangeAnalysisMode;
            end
        catch Mex %#ok<NASGU>
        end
    end
end
