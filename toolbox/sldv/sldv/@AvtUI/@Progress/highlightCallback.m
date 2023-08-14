function highlightCallback(dlgSrc,dialogH)%#ok<INUSD>




    if slavteng('feature','IncrementalHighlighting')
        modelH=dlgSrc.testComp.analysisInfo.designModelH;
        session=sldvprivate('sldvGetActiveSession',modelH);
        if~isempty(session)
            session.toggleHighlighting();
        end
        return;
    end

    if(~isempty(dlgSrc.testComp)&&ishandle(dlgSrc.testComp)&&...
        isa(dlgSrc.testComp,'SlAvt.TestComponent'))


        dlgSrc.highlightPartialResults();
    end

end
